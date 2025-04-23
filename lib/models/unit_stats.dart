import 'package:flutter/material.dart';
import 'dart:math';
import 'item.dart';
import 'board_position.dart';

// Encapsulates special effects triggered when a unit attacks (e.g. mana gain, stat stacking)
@immutable
class OnAttackStats {
  final double manaGain;
  final int attackDamageStack;
  final int abilityPowerStack;

  const OnAttackStats({
    this.manaGain = 0.0,
    this.attackDamageStack = 0,
    this.abilityPowerStack = 0,
  });

  // Combines this with another OnAttackStats
  OnAttackStats combine(OnAttackStats? other) {
    if (other == null) return this;
    return OnAttackStats(
      manaGain: manaGain + other.manaGain,
      attackDamageStack: attackDamageStack + other.attackDamageStack,
      abilityPowerStack: abilityPowerStack + other.abilityPowerStack,
    );
  }

  // Empty/default instance
  static const empty = OnAttackStats();

  // Checks if any of the values are non-zero
  bool get hasEffects =>
      manaGain != 0.0 || attackDamageStack != 0 || abilityPowerStack != 0;
}

// Holds and calculates all of a unit's stats, including dynamic modifications
class UnitStats {
  // Base stats from the unit's definition
  int baseMaxHealth;
  int baseAttackDamage;
  double baseAttackSpeed;
  int baseArmor;
  int baseMagicResist;
  int baseAbilityPower;
  int baseRange;
  double baseCritChance;
  double baseCritDamage;
  double baseLifesteal;
  double baseMovementSpeed;
  int baseStartingMana;
  int baseMaxMana;
  double baseDamageAmp;
  double baseDamageReduction;
  OnAttackStats baseOnAttackStats;

  // In-combat tracking (damage, healing, etc.)
  int damageDealt = 0;
  int damageTaken = 0;
  int healingDone = 0;
  int shieldingDone = 0;

  // Bonuses from items
  int itemMaxHealth = 0;
  int itemAttackDamage = 0;
  double itemAttackSpeed = 0.0;
  int itemArmor = 0;
  int itemMagicResist = 0;
  int itemAbilityPower = 0;
  double itemCritChance = 0.0;
  double itemCritDamage = 0.0;
  int itemStartingMana = 0;
  double itemLifesteal = 0.0;
  double itemDamageAmp = 0.0;
  double itemDamageReduction = 0.0;
  OnAttackStats itemOnAttackStats = OnAttackStats.empty;

  // Bonuses applied dynamically (e.g. from synergies)
  int _bonusMaxHealth = 0;
  int bonusAttackDamage = 0;
  double bonusAttackSpeed = 0.0;
  int bonusArmor = 0;
  int bonusMagicResist = 0;
  int bonusAbilityPower = 0;
  double bonusCritChance = 0.0;
  double bonusCritDamage = 0.0;
  double bonusLifesteal = 0.0;
  double bonusMovementSpeedPercent = 0.0;
  int bonusStartingMana = 0;
  double bonusDamageAmp = 0.0;
  double bonusDamageReduction = 0.0;

  // Various synergy-specific bonus holders
  int spellbladeBonusAttackDamage = 0;
  double artilleristBonusDamagePercent = 0.0;
  int riflemanStackAmount = 0;
  double beastRiderCleavePercent = 0.0;
  bool hasScoutSpecialAttack = false;
  int scoutSpecialAttackInterval = 0;
  double scoutSpecialAttackTimer = 0.0;
  bool hasClericBuff = false;
  bool hasIronhideStun = false;
  bool hasEmberhillMovementBuff = false;
  double emberhillAttackSpeedBonus = 0.0;

  // Current in-combat state
  int currentHealth;
  int currentMana;
  int currentShield = 0;

  // Used to avoid health restoration loops when updating synergy stats
  bool _applyingSynergyBonuses = false;

  // Temporary stats reset at the start of each combat
  int combatStartHealthBonus = 0;
  int combatStartAttackDamageBonus = 0;
  int combatStartArmorBonus = 0;
  int combatStartMagicResistBonus = 0;
  int combatStartAbilityPowerBonus = 0;
  double combatStartAttackSpeedBonus = 0.0;
  double combatStartDamageResistanceBonus = 0.0;
  double combatStartManaOnAttackBonus = 0.0;
  int combatStartShieldBonus = 0;
  double combatStartLifestealBonus = 0.0;

  String mainSpellScaling = 'AD';
  bool isStunned = false;
  double stunDuration = 0.0;
  Position? lastPosition;

  // Used to track board presence
  bool isOnBoard = false;
  int boardX = -1;
  int boardY = -1;

  set armor(int value) {
    baseArmor = value;
  }

  set magicResist(int value) {
    baseMagicResist = value;
  }

  int get bonusMaxHealth => _bonusMaxHealth;

  set bonusMaxHealth(int newBonusValue) {
    newBonusValue = max(0, newBonusValue);
    int oldMaxHealth = maxHealth;
    _bonusMaxHealth = newBonusValue;
    int newMaxHealth = maxHealth;

    if (!_applyingSynergyBonuses) {
      if (newMaxHealth > oldMaxHealth) {
        currentHealth += (newMaxHealth - oldMaxHealth);
        currentHealth = currentHealth.clamp(0, newMaxHealth);
      } else if (newMaxHealth < oldMaxHealth) {
        currentHealth = currentHealth.clamp(0, newMaxHealth);
      }
    }
  }

  void internalAddBonusMaxHealth(int amount) {
    _bonusMaxHealth += amount;
    _bonusMaxHealth = max(0, _bonusMaxHealth);
  }

  void startApplyingSynergyBonuses() {
    _applyingSynergyBonuses = true;
  }

  void endApplyingSynergyBonuses() {
    _applyingSynergyBonuses = false;
  }

  OnAttackStats bonusOnAttackStats = const OnAttackStats();

  void resetStartOfCombatStats() {
    combatStartHealthBonus = 0;
    combatStartAttackDamageBonus = 0;
    combatStartArmorBonus = 0;
    combatStartMagicResistBonus = 0;
    combatStartAbilityPowerBonus = 0;
    combatStartAttackSpeedBonus = 0.0;
    combatStartDamageResistanceBonus = 0.0;
    combatStartManaOnAttackBonus = 0.0;
    combatStartShieldBonus = 0;
    combatStartLifestealBonus = 0.0;
    riflemanStackAmount = 0;
    beastRiderCleavePercent = 0.0;

    scoutSpecialAttackTimer = 0.0;
    hasClericBuff = false;
    isStunned = false;
    stunDuration = 0.0;

    lastPosition = isOnBoard ? Position(boardY, boardX) : null;
  }

  // Computed stat accessors (final values)
  int get maxHealth =>
      baseMaxHealth + itemMaxHealth + _bonusMaxHealth + combatStartHealthBonus;
  int get attackDamage =>
      baseAttackDamage +
      itemAttackDamage +
      bonusAttackDamage +
      combatStartAttackDamageBonus;
  int get armor => baseArmor + itemArmor + bonusArmor + combatStartArmorBonus;
  int get magicResist =>
      baseMagicResist +
      itemMagicResist +
      bonusMagicResist +
      combatStartMagicResistBonus;
  int get abilityPower =>
      baseAbilityPower +
      itemAbilityPower +
      bonusAbilityPower +
      combatStartAbilityPowerBonus;
  int get range => baseRange;
  double get critChance =>
      (baseCritChance + itemCritChance + bonusCritChance).clamp(0.0, 1.0);
  double get critDamage => baseCritDamage + itemCritDamage + bonusCritDamage;
  double get lifesteal => (baseLifesteal +
          itemLifesteal +
          bonusLifesteal +
          combatStartLifestealBonus)
      .clamp(0.0, 1.0);
  double get movementSpeed =>
      baseMovementSpeed * (1 + bonusMovementSpeedPercent);
  int get startingMana =>
      baseStartingMana + bonusStartingMana + itemStartingMana;
  int get maxMana => baseMaxMana;
  double get damageAmp => baseDamageAmp + itemDamageAmp + bonusDamageAmp;
  double get damageReduction => (baseDamageReduction +
          itemDamageReduction +
          bonusDamageReduction +
          combatStartDamageResistanceBonus)
      .clamp(0.0, 0.75);
  OnAttackStats get totalOnAttackStats =>
      baseOnAttackStats.combine(itemOnAttackStats).combine(bonusOnAttackStats);
  double get attackSpeed =>
      baseAttackSpeed +
      itemAttackSpeed +
      bonusAttackSpeed +
      combatStartAttackSpeedBonus;

  // Constructor initializes core stats and sets current health/mana
  UnitStats({
    required this.baseMaxHealth,
    required this.baseAttackDamage,
    required this.baseAttackSpeed,
    required this.baseArmor,
    required this.baseMagicResist,
    required this.baseAbilityPower,
    required this.baseRange,
    required this.baseCritChance,
    required this.baseCritDamage,
    required this.baseLifesteal,
    required this.baseMovementSpeed,
    required this.baseStartingMana,
    required this.baseMaxMana,
    required this.baseDamageAmp,
    this.baseDamageReduction = 0.0,
    required this.baseOnAttackStats,
  }) : currentHealth = baseMaxHealth.toInt(),
       currentMana = baseStartingMana;

  // Copies over dynamic state
  UnitStats copyWith({
    int? baseMaxHealth,
    int? baseAttackDamage,
    double? baseAttackSpeed,
    int? baseArmor,
    int? baseMagicResist,
    int? baseAbilityPower,
    int? baseRange,
    double? baseCritChance,
    double? baseCritDamage,
    double? baseLifesteal,
    double? baseMovementSpeed,
    int? baseStartingMana,
    int? baseMaxMana,
    double? baseDamageAmp,
    double? baseDamageReduction,
    OnAttackStats? baseOnAttackStats,
    int? currentHealth,
    int? currentMana,
    int? currentShield,
    int? bonusMaxHealth,
  }) {
    var newStats = UnitStats(
      baseMaxHealth: baseMaxHealth ?? this.baseMaxHealth,
      baseAttackDamage: baseAttackDamage ?? this.baseAttackDamage,
      baseAttackSpeed: baseAttackSpeed ?? this.baseAttackSpeed,
      baseArmor: baseArmor ?? this.baseArmor,
      baseMagicResist: baseMagicResist ?? this.baseMagicResist,
      baseAbilityPower: baseAbilityPower ?? this.baseAbilityPower,
      baseRange: baseRange ?? this.baseRange,
      baseCritChance: baseCritChance ?? this.baseCritChance,
      baseCritDamage: baseCritDamage ?? this.baseCritDamage,
      baseLifesteal: baseLifesteal ?? this.baseLifesteal,
      baseMovementSpeed: baseMovementSpeed ?? this.baseMovementSpeed,
      baseStartingMana: baseStartingMana ?? this.baseStartingMana,
      baseMaxMana: baseMaxMana ?? this.baseMaxMana,
      baseDamageAmp: baseDamageAmp ?? this.baseDamageAmp,
      baseDamageReduction: baseDamageReduction ?? this.baseDamageReduction,
      baseOnAttackStats: baseOnAttackStats ?? this.baseOnAttackStats,
    );

    newStats.itemMaxHealth = itemMaxHealth;
    newStats.itemAttackDamage = itemAttackDamage;
    newStats.itemAttackSpeed = itemAttackSpeed;
    newStats.itemArmor = itemArmor;
    newStats.itemMagicResist = itemMagicResist;
    newStats.itemAbilityPower = itemAbilityPower;
    newStats.itemCritChance = itemCritChance;
    newStats.itemCritDamage = itemCritDamage;
    newStats.itemStartingMana = itemStartingMana;
    newStats.itemLifesteal = itemLifesteal;
    newStats.itemDamageAmp = itemDamageAmp;
    newStats.itemDamageReduction = itemDamageReduction;
    newStats.itemOnAttackStats = itemOnAttackStats;

    newStats._bonusMaxHealth = bonusMaxHealth ?? _bonusMaxHealth;
    newStats.bonusAttackDamage = bonusAttackDamage;
    newStats.bonusAttackSpeed = bonusAttackSpeed;
    newStats.bonusArmor = bonusArmor;
    newStats.bonusMagicResist = bonusMagicResist;
    newStats.bonusAbilityPower = bonusAbilityPower;
    newStats.bonusCritChance = bonusCritChance;
    newStats.bonusCritDamage = bonusCritDamage;
    newStats.bonusLifesteal = bonusLifesteal;
    newStats.bonusMovementSpeedPercent = bonusMovementSpeedPercent;
    newStats.bonusStartingMana = bonusStartingMana;
    newStats.bonusDamageAmp = bonusDamageAmp;
    newStats.bonusDamageReduction = bonusDamageReduction;
    newStats.spellbladeBonusAttackDamage = spellbladeBonusAttackDamage;
    newStats.artilleristBonusDamagePercent = artilleristBonusDamagePercent;
    newStats.riflemanStackAmount = riflemanStackAmount;
    newStats.beastRiderCleavePercent = beastRiderCleavePercent;
    newStats.scoutSpecialAttackTimer = scoutSpecialAttackTimer;
    newStats.hasClericBuff = hasClericBuff;
    newStats.hasScoutSpecialAttack = hasScoutSpecialAttack;
    newStats.scoutSpecialAttackInterval = scoutSpecialAttackInterval;
    newStats.hasIronhideStun = hasIronhideStun;
    newStats.hasEmberhillMovementBuff = hasEmberhillMovementBuff;
    newStats.emberhillAttackSpeedBonus = emberhillAttackSpeedBonus;

    newStats.currentHealth = currentHealth ?? this.currentHealth;
    newStats.currentMana = currentMana ?? this.currentMana;
    newStats.currentShield = currentShield ?? this.currentShield;

    return newStats;
  }

  // Copies over dynamic state
  void resetBonusStats() {
    _bonusMaxHealth = 0;
    bonusAttackDamage = 0;
    bonusAttackSpeed = 0.0;
    bonusArmor = 0;
    bonusMagicResist = 0;
    bonusAbilityPower = 0;
    bonusCritChance = 0.0;
    bonusCritDamage = 0.0;
    bonusLifesteal = 0.0;
    bonusMovementSpeedPercent = 0.0;
    bonusStartingMana = 0;
    bonusDamageAmp = 0.0;
    bonusDamageReduction = 0.0;

    spellbladeBonusAttackDamage = 0;
    artilleristBonusDamagePercent = 0.0;

    bonusOnAttackStats = const OnAttackStats();

    hasScoutSpecialAttack = false;
    scoutSpecialAttackInterval = 0;
    scoutSpecialAttackTimer = 0.0;
  }

  // Applies an item's stat bonuses to the unit
  void applyItemBonus(ItemStatsBonus bonus) {
    itemMaxHealth += bonus.bonusMaxHealth.floor();

    itemAttackDamage += bonus.bonusAttackDamage.floor();
    itemAttackSpeed += bonus.bonusAttackSpeed;
    itemArmor += bonus.bonusArmor.floor();
    itemMagicResist += bonus.bonusMagicResist.floor();
    itemAbilityPower += bonus.bonusAbilityPower.floor();
    itemCritChance += bonus.bonusCritChance;
    itemCritDamage += bonus.bonusCritDamage;
    itemStartingMana += bonus.bonusStartingMana;
    itemLifesteal += bonus.bonusLifesteal;
    itemDamageAmp += bonus.bonusDamageAmp;
    itemDamageReduction += bonus.bonusDamageReduction;

    // Handle percent-based boosts
    if (bonus.bonusAttackDamagePercent > 0) {
      itemAttackDamage +=
          (baseAttackDamage * bonus.bonusAttackDamagePercent).floor();
    }
    if (bonus.bonusAttackSpeedPercent > 0) {
      itemAttackSpeed += bonus.bonusAttackSpeedPercent;
    }
    if (bonus.bonusAbilityPowerPercent > 0) {
      itemAbilityPower +=
          (baseAbilityPower * bonus.bonusAbilityPowerPercent).floor();
    }

    itemOnAttackStats = itemOnAttackStats.combine(bonus.onAttackStats);
  }

  // Reverses a previously applied item bonus
  void unapplyItemBonus(ItemStatsBonus bonus) {
    itemMaxHealth -= bonus.bonusMaxHealth.floor();

    itemAttackDamage -= bonus.bonusAttackDamage.floor();
    itemAttackSpeed -= bonus.bonusAttackSpeed;
    itemArmor -= bonus.bonusArmor.floor();
    itemMagicResist -= bonus.bonusMagicResist.floor();
    itemAbilityPower -= bonus.bonusAbilityPower.floor();
    itemCritChance -= bonus.bonusCritChance;
    itemCritDamage -= bonus.bonusCritDamage;
    itemStartingMana -= bonus.bonusStartingMana;
    itemLifesteal -= bonus.bonusLifesteal;
    itemDamageAmp -= bonus.bonusDamageAmp;
    itemDamageReduction -= bonus.bonusDamageReduction;

    if (bonus.bonusAttackDamagePercent > 0) {
      itemAttackDamage -=
          (baseAttackDamage * bonus.bonusAttackDamagePercent).floor();
    }
    if (bonus.bonusAttackSpeedPercent > 0) {
      itemAttackSpeed -= bonus.bonusAttackSpeedPercent;
    }
    if (bonus.bonusAbilityPowerPercent > 0) {
      itemAbilityPower -=
          (baseAbilityPower * bonus.bonusAbilityPowerPercent).floor();
    }

    itemOnAttackStats = OnAttackStats.empty;
  }

  // Creates an upgraded version of the stats for a higher-tier unit
  UnitStats upgrade(int newTier) {
    double multiplier = pow(1.8, newTier - 1).toDouble();
    var upgraded = UnitStats(
      baseMaxHealth: (baseMaxHealth * multiplier).floor().toInt(),
      baseAttackDamage: (baseAttackDamage * multiplier).floor().toInt(),

      baseAttackSpeed: baseAttackSpeed,
      baseArmor: baseArmor,
      baseMagicResist: baseMagicResist,
      baseAbilityPower: baseAbilityPower,
      baseRange: baseRange,
      baseCritChance: baseCritChance,
      baseCritDamage: baseCritDamage,
      baseLifesteal: baseLifesteal,
      baseMovementSpeed: baseMovementSpeed,
      baseStartingMana: baseStartingMana,
      baseMaxMana: baseMaxMana,
      baseDamageAmp: baseDamageAmp,
      baseDamageReduction: baseDamageReduction,
      baseOnAttackStats: baseOnAttackStats,
    );

    return upgraded;
  }

  // Serializes base stats to JSON
  Map<String, dynamic> toJson() {
    return {
      'baseMaxHealth': baseMaxHealth,
      'baseAttackDamage': baseAttackDamage,
      'baseAttackSpeed': baseAttackSpeed,
      'baseArmor': baseArmor,
      'baseMagicResist': baseMagicResist,
      'baseAbilityPower': baseAbilityPower,
      'baseRange': baseRange,
      'baseCritChance': baseCritChance,
      'baseCritDamage': baseCritDamage,
      'baseLifesteal': baseLifesteal,
      'baseMovementSpeed': baseMovementSpeed,
      'baseStartingMana': baseStartingMana,
      'baseMaxMana': baseMaxMana,
      'baseDamageAmp': baseDamageAmp,
      'baseDamageReduction': baseDamageReduction,
    };
  }

  // Reconstructs a UnitStats instance from JSON
  factory UnitStats.fromJson(Map<String, dynamic> json) {
    return UnitStats(
      baseMaxHealth: json['baseMaxHealth'] as int,
      baseAttackDamage: json['baseAttackDamage'] as int,
      baseAttackSpeed: json['baseAttackSpeed'] as double,
      baseArmor: json['baseArmor'] as int,
      baseMagicResist: json['baseMagicResist'] as int,
      baseAbilityPower: json['baseAbilityPower'] as int,
      baseRange: json['baseRange'] as int,
      baseCritChance: json['baseCritChance'] as double,
      baseCritDamage: json['baseCritDamage'] as double,
      baseLifesteal: json['baseLifesteal'] as double,
      baseMovementSpeed: json['baseMovementSpeed'] as double,
      baseStartingMana: json['baseStartingMana'] as int,
      baseMaxMana: json['baseMaxMana'] as int,
      baseDamageAmp: json['baseDamageAmp'] as double,
      baseDamageReduction: json['baseDamageReduction'] as double,
      baseOnAttackStats: OnAttackStats.empty,
    );
  }
}
