import 'package:realm_of_tactics/enums/damage_type.dart';
import 'package:realm_of_tactics/models/board_position.dart';
import 'package:realm_of_tactics/models/game_manager.dart';
import 'package:realm_of_tactics/models/unit.dart';
import 'package:realm_of_tactics/models/unit_stats.dart';
import '../enums/item_type.dart';
import 'item.dart';

// Base class for all summoned units (like drones, turrets, tanks). Inherits from Unit.
class SummonedUnit extends Unit {
  static double engineerStatBonusAlly = 0.0;
  static double engineerStatBonusEnemy = 0.0;

  // Tracks if Engineer bonuses have already been applied to avoid duplicate stacking
  bool hasAppliedEngineerBonus = false;

  Unit? summoner;
  get getHasAppliedEngineerBonus => hasAppliedEngineerBonus;

  // Setter for engineer bonus flag with a notifier trigger
  set setHasAppliedEngineerBonus(bool value) {
    hasAppliedEngineerBonus = value;
    notifyListeners();
  }

  // Constructor for summoned units with default summon-related values
  SummonedUnit({
    required super.id,
    required super.unitName,
    required this.summoner,
    required super.stats,
    required super.imagePath,
  }) : super(
         unitClass: 'Summon',
         synergies: [],
         cost: 0,
         tier: 1,
         classes: [],
         origins: [],
         isSummon: true,
       );

  // Static method to set bonus stats for enemy Engineer synergy
  static void setEngineerBonusEnemy(int tier) {
    engineerStatBonusEnemy =
        tier >= 4
            ? 0.4
            : tier >= 2
            ? 0.2
            : 0.0;
  }

  // Static method to set bonus stats for ally Engineer synergy
  static void setEngineerBonusAlly(int tier) {
    engineerStatBonusAlly =
        tier >= 4
            ? 0.4
            : tier >= 2
            ? 0.2
            : 0.0;
  }

  // Applies Engineer synergy bonuses to the summon’s stats
  void applyEngineerBonus() {
    double engineerBonus =
        !isEnemy ? engineerStatBonusAlly : engineerStatBonusEnemy;
    if (hasAppliedEngineerBonus || engineerBonus <= 0) return;

    int healthBonus = ((stats.baseMaxHealth * engineerBonus).floor());
    int adBonus = ((stats.baseAttackDamage * engineerBonus).floor());
    int armorBonus = ((stats.baseArmor * engineerBonus).floor());
    int mrBonus = ((stats.baseMagicResist * engineerBonus).floor());
    int apBonus = ((stats.baseAbilityPower * engineerBonus).floor());

    stats.combatStartHealthBonus += healthBonus;
    stats.combatStartAttackDamageBonus += adBonus;
    stats.combatStartArmorBonus += armorBonus;
    stats.combatStartMagicResistBonus += mrBonus;
    stats.combatStartAbilityPowerBonus += apBonus;

    stats.currentHealth = stats.maxHealth;

    hasAppliedEngineerBonus = true;
  }

  // Allows creating a modified clone of the summon with optional overrides
  @override
  SummonedUnit copyWith({
    String? id,
    String? unitName,
    String? unitClass,
    List<String>? synergies,
    int? cost,
    int? tier,
    UnitStats? stats,
    String? imagePath,
    List<String>? classes,
    List<String>? origins,
    UnitState? state,
    Position? position,
    Unit? currentTarget,
    bool? isOnBoard,
    int? boardX,
    int? boardY,
    int? benchIndex,
    double? damageResistance,
    Item? weapon,
    Item? armor,
    Item? trinket,
    bool? isSummon,
    bool? appliesBattlemageDebuff,
    bool? isEnemy,
    bool? hasAppliedEngineerBonus,
    bool? isFromShop,
  }) {
    String newId = id ?? this.id;

    SummonedUnit newSummon = SummonedUnit(
      id: newId,
      unitName: unitName ?? this.unitName,
      stats: stats ?? this.stats.copyWith(),
      imagePath: imagePath ?? this.imagePath,
      summoner: this.summoner,
    );

    newSummon
      ..state = state ?? this.state
      ..position = position ?? this.position
      ..isOnBoard = isOnBoard ?? this.isOnBoard
      ..boardX = boardX ?? this.boardX
      ..boardY = boardY ?? this.boardY
      ..benchIndex = -1
      ..hasAppliedEngineerBonus =
          hasAppliedEngineerBonus ?? this.hasAppliedEngineerBonus
      ..appliesBattlemageDebuff =
          appliesBattlemageDebuff ?? this.appliesBattlemageDebuff
      ..isEnemy = isEnemy ?? this.isEnemy;

    return newSummon;
  }

  // Summoned units do not upgrade—override returns self
  @override
  Unit upgrade() {
    return this;
  }

  // Summoned units can't equip items—always false
  @override
  bool canEquipItem(Item item) {
    return false;
  }

  // Summoned units can't equip items—always false
  @override
  bool equipItem(Item item) {
    return false;
  }

  // Summoned units don't have unequippable items—always null
  @override
  Item? unequipItem(ItemType slotType) {
    return null;
  }

  // Summoned units return an empty list when asked for equipped items
  @override
  List<Item> getEquippedItems() {
    return [];
  }

  @override
  void takeDamage(
    double rawDamage,
    Unit? source, [
    DamageType type = DamageType.physical,
  ]) {
    super.takeDamage(rawDamage, summoner, type);
  }

  @override
  bool attackTarget(Unit target, double damage) {
    if (timeUntilNextAttack > 0) {
      return false;
    }

    if (!target.isAlive) {
      currentTargetId = null;
      return false;
    }

    // Play attack animation or effect
    GameManager.instance!.playAttackEffect(this, target);

    final OnAttackStats totalOnAttack = stats.totalOnAttackStats;

    // Apply on-hit stat bonuses
    if (totalOnAttack.manaGain > 0) {
      gainMana(totalOnAttack.manaGain.floor());
    }
    if (totalOnAttack.attackDamageStack > 0) {
      stats.bonusAttackDamage += totalOnAttack.attackDamageStack;
    }
    if (totalOnAttack.abilityPowerStack > 0) {
      stats.bonusAbilityPower += totalOnAttack.abilityPowerStack;
    }

    // Rifleman stacks
    if (stats.riflemanStackAmount > 0) {
      stats.combatStartAttackDamageBonus += stats.riflemanStackAmount;
    }

    target.takeDamage(damage, summoner, DamageType.physical);
    gainMana(10);
    notifyListeners();

    return true;
  }
}

// A basic melee summon for Ironvale synergy—low health/damage and short range
class IronvaleDrone extends SummonedUnit {
  IronvaleDrone({String? id})
    : super(
        id: id ?? 'ironvale_drone_${DateTime.now().millisecondsSinceEpoch}',
        summoner: null,
        unitName: 'Ironvale Drone',
        stats: UnitStats(
          baseMaxHealth: 200,
          baseAttackDamage: 20,
          baseAttackSpeed: 0.8,
          baseArmor: 15,
          baseMagicResist: 15,
          baseRange: 1,
          baseMaxMana: 0,
          baseAbilityPower: 0,
          baseCritChance: 0.25,
          baseCritDamage: 1.5,
          baseLifesteal: 0,
          baseMovementSpeed: 1.0,
          baseStartingMana: 0,
          baseDamageAmp: 1.0,
          baseOnAttackStats: OnAttackStats.empty,
        ),
        imagePath: 'assets/images/units/ironvale_drone.png',
      );
}

// A long-range stationary summon with moderate durability and high range
class IronvaleTurret extends SummonedUnit {
  IronvaleTurret({String? id})
    : super(
        id: id ?? 'ironvale_turret_${DateTime.now().millisecondsSinceEpoch}',
        summoner: null,
        unitName: 'Ironvale Turret',
        stats: UnitStats(
          baseMaxHealth: 400,
          baseAttackDamage: 35,
          baseAttackSpeed: 0.7,
          baseArmor: 25,
          baseMagicResist: 25,
          baseRange: 10,
          baseMaxMana: 0,
          baseAbilityPower: 0,
          baseCritChance: 0.25,
          baseCritDamage: 1.5,
          baseLifesteal: 0,
          baseMovementSpeed: 0.0,
          baseStartingMana: 0,
          baseDamageAmp: 1.0,
          baseOnAttackStats: OnAttackStats.empty,
        ),
        imagePath: 'assets/images/units/ironvale_turret.png',
      );
}

// A high-durability frontline summon for Ironvale synergy
class IronvaleTank extends SummonedUnit {
  IronvaleTank({String? id})
    : super(
        id: id ?? 'ironvale_tank_${DateTime.now().millisecondsSinceEpoch}',
        summoner: null,
        unitName: 'Ironvale Tank',
        stats: UnitStats(
          baseMaxHealth: 800,
          baseAttackDamage: 50,
          baseAttackSpeed: 0.6,
          baseArmor: 40,
          baseMagicResist: 40,
          baseRange: 1,
          baseMaxMana: 0,
          baseAbilityPower: 0,
          baseCritChance: 0.25,
          baseCritDamage: 1.5,
          baseLifesteal: 0,
          baseMovementSpeed: 1.0,
          baseStartingMana: 0,
          baseDamageAmp: 1.0,
          baseOnAttackStats: OnAttackStats.empty,
        ),
        imagePath: 'assets/images/units/ironvale_tank.png',
      );
}
