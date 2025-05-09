import 'package:flutter/material.dart';
import 'package:realm_of_tactics/models/game_manager.dart';
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
  int physicalDamageDone = 0;
  int magicDamageDone = 0;
  int physicalDamageBlocked = 0;
  int magicDamageBlocked = 0;
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
  int itemRange = 0;
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
  bool appliesChronosparkHeal = false;
  bool appliesGreendaleGold = false;
  bool generateScrap = false;
  bool hasSkyguardBuff = false;
  double skyGuardBuffChance = 0.0;
  bool hasDeepRockStrike = false;
  int deeprockReductionAmount = 0;
  double chronosparkHealTimer = 0.0;
  double chronosparkHealInterval = 0;
  double chronosparkHealPercent = 0;

  // Effect flags and temporary bonuses (reset each combat)
  bool abilitiesCanCrit = false;
  bool canCriticallyShield = false;
  bool spikedVisorCritBonusActive = false;
  double spikedVisorCritBonusAmount = 0.0;
  bool healingReduced = false;
  bool hasArmorReduced = false;
  bool hasMRReduced = false;
  bool stunImmune = false;
  double channelingBowTimer = 0.0;
  int mysticHarnessBonus = 0;
  double combatStartCritDamageBonus = 0.0;
  bool hasWickedBroochCooldown = false;
  bool hasEternalCharmBonus = false;
  bool hasBalancedPlateBonus = false;
  bool hasTitanHideBonus = false;
  bool hasBattlePlateBonus = false;
  bool hasBulwarkShield = false;
  int nullplateBonus = 0;
  int huntersCoatStacks = 0;
  bool hasForgedArchmageBuff = false;

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
  double combatStartDamageAmp = 0.0;
  double combatStartCritChance = 0.0;
  int combatStartStartingMana = 0;

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
    combatStartDamageAmp = 0.0;
    combatStartCritChance = 0.0;
    combatStartStartingMana = 0;
    spellbladeBonusAttackDamage = 0;
    artilleristBonusDamagePercent = 0.0;
    riflemanStackAmount = 0;
    beastRiderCleavePercent = 0.0;
    hasScoutSpecialAttack = false;
    scoutSpecialAttackInterval = 0;
    scoutSpecialAttackTimer = 0.0;
    hasClericBuff = false;
    hasIronhideStun = false;
    hasEmberhillMovementBuff = false;
    emberhillAttackSpeedBonus = 0.0;
    appliesChronosparkHeal = false;
    appliesGreendaleGold = false;
    generateScrap = false;
    hasSkyguardBuff = false;
    skyGuardBuffChance = 0.0;
    hasDeepRockStrike = false;
    deeprockReductionAmount = 0;
    chronosparkHealTimer = 0.0;
    chronosparkHealInterval = 0;
    chronosparkHealPercent = 0;

    abilitiesCanCrit = false;
    canCriticallyShield = false;
    spikedVisorCritBonusActive = false;
    spikedVisorCritBonusAmount = 0.0;
    healingReduced = false;
    hasArmorReduced = false;
    hasMRReduced = false;
    stunImmune = false;
    channelingBowTimer = 0.0;
    mysticHarnessBonus = 0;
    combatStartCritDamageBonus = 0.0;
    hasWickedBroochCooldown = false;
    hasEternalCharmBonus = false;
    hasBalancedPlateBonus = false;
    hasTitanHideBonus = false;
    hasBattlePlateBonus = false;
    hasBulwarkShield = false;
    nullplateBonus = 0;
    huntersCoatStacks = 0;
    hasForgedArchmageBuff = false;

    lastPosition = isOnBoard ? Position(boardY, boardX) : null;
  }

  // Computed stat accessors (final values)
  int get maxHealth =>
      baseMaxHealth +
      itemMaxHealth +
      _bonusMaxHealth +
      combatStartHealthBonus +
      GameManager.instance!.overallMaxHealth;
  int get attackDamage =>
      baseAttackDamage +
      itemAttackDamage +
      bonusAttackDamage +
      (combatStartAttackDamageBonus / 100 * baseAttackDamage).floor() +
      GameManager.instance!.overallAttackDamage;
  int get armor =>
      baseArmor +
      itemArmor +
      bonusArmor +
      combatStartArmorBonus +
      GameManager.instance!.overallArmor;
  int get magicResist =>
      baseMagicResist +
      itemMagicResist +
      bonusMagicResist +
      combatStartMagicResistBonus +
      GameManager.instance!.overallMagicResist;
  int get abilityPower =>
      baseAbilityPower +
      itemAbilityPower +
      bonusAbilityPower +
      combatStartAbilityPowerBonus +
      GameManager.instance!.overallAbilityPower;
  int get range => baseRange + itemRange;
  double get critChance => (baseCritChance +
          itemCritChance +
          bonusCritChance +
          combatStartCritChance +
          GameManager.instance!.overallCritChance)
      .clamp(0.0, 1.0);
  double get critDamage =>
      baseCritDamage +
      itemCritDamage +
      bonusCritDamage +
      combatStartCritDamageBonus +
      GameManager.instance!.overallCritDamage;
  double get lifesteal => (baseLifesteal +
          itemLifesteal +
          bonusLifesteal +
          combatStartLifestealBonus +
          GameManager.instance!.overallLifesteal)
      .clamp(0.0, 1.0);
  double get movementSpeed =>
      baseMovementSpeed * (1 + bonusMovementSpeedPercent);
  int get startingMana =>
      baseStartingMana +
      bonusStartingMana +
      itemStartingMana +
      GameManager.instance!.overallStartingMana;
  int get maxMana => baseMaxMana;
  double get damageAmp =>
      baseDamageAmp +
      itemDamageAmp +
      bonusDamageAmp +
      combatStartDamageAmp +
      GameManager.instance!.overallMaxHealth;
  double get damageReduction => (baseDamageReduction +
          itemDamageReduction +
          bonusDamageReduction +
          combatStartDamageResistanceBonus +
          GameManager.instance!.overallDamageReduction)
      .clamp(0.0, 0.75);
  OnAttackStats get totalOnAttackStats =>
      baseOnAttackStats.combine(itemOnAttackStats).combine(bonusOnAttackStats);
  double get attackSpeed =>
      baseAttackSpeed +
      (itemAttackSpeed * baseAttackSpeed) +
      (bonusAttackSpeed * baseAttackSpeed) +
      (combatStartAttackSpeedBonus * baseAttackSpeed) +
      (GameManager.instance!.overallAttackSpeed * baseAttackSpeed);

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
    newStats.itemRange = itemRange;

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
    currentMana += bonus.bonusStartingMana;
    itemLifesteal += bonus.bonusLifesteal;
    itemDamageAmp += bonus.bonusDamageAmp;
    itemDamageReduction += bonus.bonusDamageReduction;
    itemRange += bonus.bonusRange;
    itemAttackSpeed += bonus.bonusAttackSpeedPercent;
    // Handle percent-based boosts
    if (bonus.bonusAttackDamagePercent > 0) {
      itemAttackDamage +=
          (baseAttackDamage * bonus.bonusAttackDamagePercent).floor();
    }
    if (bonus.bonusAbilityPowerPercent > 0) {
      itemAbilityPower +=
          (baseAbilityPower * bonus.bonusAbilityPowerPercent).floor();
    }

    itemOnAttackStats = itemOnAttackStats.combine(bonus.onAttackStats);
  }

  // Applies an item's stat bonuses to the unit only for the combat
  void applyItemBonusToCombatStart(ItemStatsBonus bonus) {
    combatStartHealthBonus += bonus.bonusMaxHealth.floor();
    combatStartAttackSpeedBonus += bonus.bonusAttackSpeed;
    combatStartArmorBonus += bonus.bonusArmor.floor();
    combatStartMagicResistBonus += bonus.bonusMagicResist.floor();
    combatStartAbilityPowerBonus += bonus.bonusAbilityPower.floor();
    combatStartCritChance += bonus.bonusCritChance;
    combatStartCritDamageBonus += bonus.bonusCritDamage;
    combatStartStartingMana += bonus.bonusStartingMana;
    currentMana += bonus.bonusStartingMana;
    combatStartLifestealBonus += bonus.bonusLifesteal;
    combatStartDamageAmp += bonus.bonusDamageAmp;
    combatStartDamageResistanceBonus += bonus.bonusDamageReduction;
    combatStartAttackSpeedBonus += bonus.bonusAttackSpeedPercent;
    if (bonus.bonusAttackDamagePercent > 0) {
      combatStartAttackDamageBonus +=
          (baseAttackDamage * bonus.bonusAttackDamagePercent).floor();
    }
    if (bonus.bonusAbilityPowerPercent > 0) {
      combatStartAbilityPowerBonus +=
          (baseAbilityPower * bonus.bonusAbilityPowerPercent).floor();
    }
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
    currentMana -= bonus.bonusStartingMana;
    itemLifesteal -= bonus.bonusLifesteal;
    itemDamageAmp -= bonus.bonusDamageAmp;
    itemDamageReduction -= bonus.bonusDamageReduction;
    itemRange -= bonus.bonusRange;

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
    double multiplier =
        newTier == 2
            ? 1.6
            : newTier == 3
            ? 1.6
            : 1.0;
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
