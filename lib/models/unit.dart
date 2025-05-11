import 'package:flutter/material.dart';
import 'package:realm_of_tactics/models/board_manager.dart';
import 'package:realm_of_tactics/models/combat_manager.dart';
import 'package:realm_of_tactics/models/summoned_unit.dart';
import 'package:realm_of_tactics/models/unit_stats.dart';
import 'dart:math';
import '../enums/item_type.dart';
import '../enums/damage_type.dart';
import 'item.dart';
import 'dart:async';
import 'game_manager.dart';
import 'board_position.dart';
import '../game_data/ability_data.dart';
import 'ability.dart';
import 'timed_effect.dart';

// Enum that defines what state the unit is in (idle, moving, etc.)
enum UnitState { idle, moving, attacking, casting, dead }

// Base class for all units, includes stats, combat logic, state, and equipment
class Unit extends ChangeNotifier {
  final String id;
  final String unitName;
  final String unitClass;
  final List<String> synergies;
  final int cost;
  int tier;
  final String imagePath;
  final List<String> classes;
  final List<String> origins;
  final UnitStats stats;
  final bool isFromShop;

  // Board info
  bool isOnBoard = false;
  int boardX = -1;
  int boardY = -1;
  int team = 0;

  // Unit flags and effects
  bool isSummon = false;
  bool appliesBattlemageDebuff = false;
  int attackCounter = 0;
  bool isManaLocked = false;
  Timer? _manaLockTimer;

  // Equipped item slots
  Item? _weapon;
  Item? _armor;
  Item? _trinket;

  // Expose current equipped items
  Item? get weapon => _weapon;
  Item? get armor => _armor;
  Item? get trinket => _trinket;

  UnitState state = UnitState.idle;
  Position position = const Position(0, 0);
  int? benchIndex = -1;

  // Targeting and movement fields
  String? currentTargetId;
  Position? movementTargetPos;
  double timeUntilNextAttack = 0.0;
  double movementProgress = 0.0;

  bool isStunned = false;
  double stunDuration = 0.0;

  Position? lastPosition;

  final String? abilityName;

  // Timers for effects

  // Whether this unit belongs to the enemy team
  bool _isEnemy = false;
  bool get isEnemy => _isEnemy;
  set isEnemy(bool value) {
    _isEnemy = value;
    notifyListeners();
  }

  // Main constructor
  Unit({
    required this.id,
    required this.unitName,
    required this.unitClass,
    required this.synergies,
    required this.cost,
    required this.tier,
    required this.stats,
    required this.imagePath,
    required this.classes,
    required this.origins,
    this.abilityName,
    this.team = 0,
    this.isSummon = false,
    this.appliesBattlemageDebuff = false,
    this.isFromShop = false,
  }) : _isEnemy = false {
    isOnBoard = false;
    boardX = -1;
    boardY = -1;
    state = UnitState.idle;
    position = const Position(0, 0);
    benchIndex = -1;
  }

  // Whether the unit is alive
  bool get isAlive => stats.currentHealth > 0;

  // Checks if the unit can equip a specific item
  bool canEquipItem(Item item) {
    if (this is SummonedUnit) {
      return false;
    }

    if (isEnemy) {
      return false;
    }

    // Check slot availability
    switch (item.type) {
      case ItemType.weapon:
        return _weapon == null;
      case ItemType.armor:
        return _armor == null;
      case ItemType.trinket:
        return _trinket == null;
    }
  }

  // Equips an item to the appropriate slot if possible
  bool equipItem(Item item, {bool enemyEquip = false}) {
    if (!enemyEquip && !canEquipItem(item)) {
      return false;
    }

    int healthBefore = stats.currentHealth;
    int maxHealthBefore = stats.maxHealth;

    switch (item.type) {
      case ItemType.weapon:
        _weapon = item;
        break;
      case ItemType.armor:
        _armor = item;
        break;
      case ItemType.trinket:
        _trinket = item;
        break;
    }

    stats.applyItemBonus(item.statsBonus);

    int maxHealthIncrease = stats.maxHealth - maxHealthBefore;
    int newCurrentHealth = healthBefore;
    if (maxHealthIncrease > 0) {
      newCurrentHealth += maxHealthIncrease;
    }

    stats.currentHealth = newCurrentHealth.clamp(0, stats.maxHealth);
    item.ownerUnitId = id;
    notifyListeners();
    return true;
  }

  // Unequips an item from a given slot and removes its stat bonuses
  Item? unequipItem(ItemType slotType) {
    Item? itemToReturn;
    switch (slotType) {
      case ItemType.weapon:
        itemToReturn = _weapon;
        _weapon = null;
        break;
      case ItemType.armor:
        itemToReturn = _armor;
        _armor = null;
        break;
      case ItemType.trinket:
        itemToReturn = _trinket;
        _trinket = null;
        break;
    }

    if (itemToReturn != null) {
      itemToReturn.ownerUnitId = null;
      stats.unapplyItemBonus(itemToReturn.statsBonus);

      stats.currentHealth = stats.currentHealth.clamp(0, stats.maxHealth);

      notifyListeners();
    }
    return itemToReturn;
  }

  // Returns a list of currently equipped items
  List<Item> getEquippedItems() {
    return [_weapon, _armor, _trinket].whereType<Item>().toList();
  }

  // Returns this unit's position on the board (null if not placed)
  Position? getBoardPosition() {
    if (!isOnBoard) return null;
    return Position(boardY, boardX);
  }

  // Handles applying damage to the unit, considering shields, armor, MR, and reduction
  void takeDamage(
    double rawDamage,
    Unit? source, [
    DamageType type = DamageType.physical,
    bool fromItem = false,
  ]) {
    if (!isAlive) return;

    // Handle shields first
    double remainingDamage = rawDamage;
    if (stats.currentShield > 0) {
      if (rawDamage >= stats.currentShield) {
        remainingDamage = rawDamage - stats.currentShield;
        stats.currentShield = 0;
      } else {
        stats.currentShield -= rawDamage.floor();
        remainingDamage = 0;
      }
    }

    if (remainingDamage <= 0) return;

    double mitigatedAmount = 0;
    double effectiveDamage = remainingDamage;

    if (type == DamageType.physical) {
      double mitigation =
          stats.armor <= -100 ? 1.0 : stats.armor / (stats.armor + 100.0);
      mitigatedAmount = remainingDamage * mitigation;
      effectiveDamage *= (1.0 - mitigation);
    } else if (type == DamageType.magic) {
      double mitigation =
          stats.magicResist <= -100
              ? 1.0
              : stats.magicResist / (stats.magicResist + 100.0);
      mitigatedAmount = remainingDamage * mitigation;
      effectiveDamage *= (1.0 - mitigation);
    }

    effectiveDamage *= (1.0 - stats.damageReduction);

    int finalDamage = effectiveDamage.floor();
    if (finalDamage <= 0) return;
    finalDamage = handleItemEffectsOnTakeDamage(
      this,
      finalDamage,
      type,
      mitigatedAmount,
    );
    int beforeHealth = stats.currentHealth;
    stats.currentHealth -= finalDamage;
    double appliedDamage =
        (beforeHealth - max(0, stats.currentHealth)).toDouble();

    if (source != null) {
      if (type == DamageType.physical) {
        source.stats.physicalDamageDone += finalDamage;
      } else if (type == DamageType.magic) {
        source.stats.magicDamageDone += finalDamage;
      }
      _handleItemEffectsOnDamageDealt(source, this, finalDamage);

      if (source.stats.lifesteal > 0 && !fromItem) {
        int healAmount = (finalDamage * source.stats.lifesteal).floor();
        if (healAmount > 0) {
          source.heal(source, healAmount);
        }
      }
    }

    if (type == DamageType.physical) {
      stats.physicalDamageBlocked += mitigatedAmount.floor();
    } else if (type == DamageType.magic) {
      stats.magicDamageBlocked += mitigatedAmount.floor();
    }

    // Mana gain from damage
    if (stats.maxMana > 0 && rawDamage > 0) {
      double manaFromRaw = rawDamage * 0.01;
      double manaFromMitigated = appliedDamage * 0.07;
      double totalMana = (manaFromRaw + manaFromMitigated).clamp(0.0, 42.5);
      if (totalMana > 0) {
        gainMana(totalMana.floor());
      }
    }

    // Die if health drops to zero
    if (stats.currentHealth <= 0) {
      stats.currentHealth = 0;
      if (source != null) {
        _handleItemEffectsOnKill(source);
        if (gameManager!.mapManager.playerBlessings.contains("Vampiric Bite")) {
          source.heal(source, 200);
        }
      }
      die();
    }
  }

  // Adds an amount of health to the unit, clamped at the max healthx
  void heal(Unit source, int amount) {
    if (stats.healingReduced) {
      amount = (amount * .6).toInt();
    }
    if (!isAlive || amount <= 0) return;
    int overheal = stats.currentHealth - (stats.currentHealth + amount);
    _handleItemEffectsOnHeal(this, amount, overheal);
    stats.currentHealth = (stats.currentHealth + amount).clamp(
      0,
      stats.maxHealth,
    );
    source.stats.healingDone += amount;
  }

  // Adds an amount of shield to the unit
  void shield(Unit source, int amount) {
    if (gameManager!.mapManager.playerBlessings.contains("Shields Up") &&
        !source._isEnemy) {
      amount *= 2;
    }
    if (!isAlive || amount <= 0) return;
    if (source.stats.canCriticallyShield) {
      double finalShield = amount as double;
      bool isCrit = Random().nextDouble() < source.stats.critChance;
      if (isCrit) {
        finalShield *= source.stats.critDamage;
        Unit.handleItemEffectsOnCrit(source, this);
      }
      if (finalShield < 0) finalShield = 0;
      amount = finalShield.toInt();
    }
    stats.currentShield += amount;
    source.stats.shieldingDone += amount;
  }

  // Adds mana and checks for ability cast
  void gainMana(int amount, {bool fromItem = false}) {
    if (isManaLocked || amount <= 0) return;

    stats.currentMana = (stats.currentMana + amount).clamp(0, stats.maxMana);
    if (!fromItem) {
      _handleItemEffectsOnManaGain(amount);
    }

    if (stats.currentMana >= stats.maxMana && stats.maxMana > 0 && !fromItem) {
      castAbility();
    }
  }

  // Executes the unit’s ability if ready and not stunned
  void castAbility() {
    if (isStunned || stats.currentMana < stats.maxMana) return;
    if (GameManager.instance == null) return;
    if (currentTargetId == null) return;

    Unit? target = GameManager.instance?.findUnitById(currentTargetId!);

    // Deeprock armor/mr shred
    if (stats.hasDeepRockStrike && target != null && target.isAlive) {
      int armorRed = min(stats.deeprockReductionAmount, target.stats.armor);
      int mrRed = min(stats.deeprockReductionAmount, target.stats.magicResist);
      target.stats.bonusArmor -= armorRed;
      target.stats.bonusMagicResist -= mrRed;
    }

    // Ironhide adjacent stun
    if (stats.hasIronhideStun) {
      final adjacentEnemies = getAdjacentUnits().where(
        (u) => u.team != team && u.isAlive,
      );
      for (var enemy in adjacentEnemies) {
        enemy.applyStun(3.0);
      }
    }

    // No ability assigned
    if (abilityName == null || !abilities.containsKey(abilityName)) return;

    final ability = abilities[abilityName!]!;

    // Apply ability effects to targets
    for (final effect in ability.effects) {
      final targets = _resolveEffectTargets(
        effect.targeting,
        effect.specifiedAbilityPosition,
      );
      for (final target in targets) {
        _applyAbilityEffect(this, target, effect);

        // Cleric bonus effect on heal
        if (effect.type == AbilityEffectType.heal && stats.hasClericBuff) {
          final tier = GameManager.instance!.synergyManager!.getSynergyLevel(
            "Cleric",
          );
          final bonus = tier == 2 ? 10 : (tier == 4 ? 20 : 0);
          target.applyStatModifier("attackDamage", bonus);
          target.applyStatModifier("abilityPower", bonus);
        }
      }
    }

    // Reset mana and lock casting temporarily
    stats.currentMana = 0;
    _handleItemEffectsOnCast(this);
    isManaLocked = true;
    _startManaLockTimer(duration: ability.manaLockDuration);
  }

  // Resolves a list of units to target based on the effect's targeting rule
  List<Unit> _resolveEffectTargets(
    TargetingRule rule,
    Position? specifiedPosition,
  ) {
    GameManager.instance!.allUnitsInCombat.where((u) => u.isAlive).toList();

    // Determine the origin position used for area-based targeting
    Position origin;
    switch (rule.selection) {
      case TargetSelection.self:
        origin = Position(boardY, boardX);
        break;
      case TargetSelection.target:
        Unit? currentTarget = GameManager.instance!.findUnitById(
          currentTargetId!,
        );
        if (currentTarget == null) return [];
        origin = Position(currentTarget.boardY, currentTarget.boardX);
        break;
      case TargetSelection.specifiedPosition:
        if (specifiedPosition == null) return [];
        origin = specifiedPosition;
        break;

      // For "mostCanHit", find the cluster of enemies where the ability will hit the most
      case TargetSelection.mostCanHit:
        final pool = _getUnitsByTeam(rule.targetTeam);
        return GameManager.instance!.boardManager!.getUnitsInArea(
          GameManager.instance!.boardManager!.getBestClusterTarget(
            rule.areaShape,
            rule.size,
            pool,
          ),
          rule.areaShape,
          rule.size,
          pool,
        );

      // Target the lowest/highest value for a given stat (e.g., lowest health)
      case TargetSelection.lowestStat:
      case TargetSelection.highestStat:
        if (rule.statName == null || rule.count == null) return [];
        final pool = _getUnitsByTeam(rule.targetTeam);
        pool.sort((a, b) {
          final aVal = _getStatValue(a, rule.statName!);
          final bVal = _getStatValue(b, rule.statName!);
          return rule.selection == TargetSelection.lowestStat
              ? aVal.compareTo(bVal)
              : bVal.compareTo(aVal);
        });
        final selected = pool.take(rule.count!).toList();
        return rule.includeSelf
            ? selected
            : selected.where((u) => u.id != id).toList();
    }

    // Default area-based targeting using calculated origin
    final candidates = _getUnitsByTeam(rule.targetTeam);
    final results = GameManager.instance!.boardManager!.getUnitsInArea(
      origin,
      rule.areaShape,
      rule.size,
      candidates,
    );

    return rule.includeSelf
        ? results
        : results.where((u) => u.id != id).toList();
  }

  // Returns all alive units matching the specified team filter
  List<Unit> _getUnitsByTeam(TargetTeam teamFilter) {
    final all = GameManager.instance!.allUnitsInCombat;
    return all.where((u) {
      if (!u.isAlive) return false;
      if (teamFilter == TargetTeam.allies) return u.team == team;
      if (teamFilter == TargetTeam.enemies) return u.team != team;
      return true;
    }).toList();
  }

  // Applies a stat buff or bonus to this unit during combat
  void applyStatModifier(String stat, num amount) {
    switch (stat) {
      case "attackDamage":
        stats.combatStartAttackDamageBonus += amount.toInt();
        break;
      case "armor":
        stats.combatStartArmorBonus += amount.toInt();
        break;
      case "magicResist":
        stats.combatStartMagicResistBonus += amount.toInt();
        break;
      case "abilityPower":
        stats.combatStartAbilityPowerBonus += amount.toInt();
        break;
      case "maxHealth":
        stats.combatStartHealthBonus += amount.toInt();
        stats.currentHealth += amount.toInt();
        break;
      case "lifesteal":
        stats.combatStartLifestealBonus += amount.toDouble() / 100;
        break;
      case "damageReduction":
        stats.combatStartDamageResistanceBonus += amount.toDouble() / 100;
        break;
      case "attackSpeed":
        stats.combatStartAttackSpeedBonus += amount.toDouble() / 100;
        break;
      default:
    }
  }

  // Removes a previously applied stat modifier (inverse of applyStatModifier)
  void removeStatModifier(String stat, num amount) {
    applyStatModifier(stat, -amount);
  }

  // Finds a unit on the specified team with the highest or lowest value of a given stat
  Unit? _findStatTarget(int targetTeam, String stat, {required bool lowest}) {
    final candidates =
        GameManager.instance!.allUnitsInCombat
            .where((u) => u.team == targetTeam && u.isAlive)
            .toList();

    candidates.sort((a, b) {
      final aVal = _getStatValue(a, stat);
      final bVal = _getStatValue(b, stat);
      return lowest ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    });

    if (candidates.isNotEmpty) {
      return candidates.first;
    } else {
      return null;
    }
  }

  // Returns the numeric value of a requested stat for a given unit
  int _getStatValue(Unit unit, String stat) {
    switch (stat) {
      case "maxHealth":
        return unit.stats.maxHealth;
      case "currentHealth":
        return unit.stats.currentHealth;
      case "attackDamage":
        return unit.stats.attackDamage;
      case "armor":
        return unit.stats.armor;
      case "magicResist":
        return unit.stats.magicResist;
      case "abilityPower":
        return unit.stats.abilityPower;
      default:
        return 0;
    }
  }

  // Applies a single ability effect from the source unit to a target unit
  void _applyAbilityEffect(Unit source, Unit? target, AbilityEffect effect) {
    // Null guard
    if (target == null) {
      return;
    }

    // Get the tier index to use for scaling (0 = 1-star, 1 = 2-star, etc.)
    int tierIndex = (source.tier - 1).clamp(0, 2);

    // Get base amount from tier array if available
    int baseAmount =
        effect.baseAmountByTier != null
            ? effect.baseAmountByTier![tierIndex]
            : 0;

    // Get percent scaling from tier if available
    double scalingPercent =
        effect.scalingPercentByTier != null
            ? effect.scalingPercentByTier![tierIndex]
            : 0.0;

    // Determine stat value used for scaling
    int scalingStatValue = 0;
    if (effect.scalingStat != null) {
      switch (effect.scalingStat) {
        case "abilityPower":
          scalingStatValue = stats.abilityPower;
          break;
        case "attackDamage":
          scalingStatValue = stats.attackDamage;
          break;
        case "maxHealth":
          scalingStatValue = stats.maxHealth;
          break;
      }
    }

    // Final computed amount after applying base and scaling
    int finalAmount = (baseAmount + scalingStatValue * scalingPercent).round();

    // Handle each effect type
    switch (effect.type) {
      // Stun the target for a duration (in seconds)
      case AbilityEffectType.stun:
        if (effect.duration != null) {
          target.applyStun(effect.duration!.inSeconds.toDouble());
          if (target.stats.isStunned) {
            _showEffectVisual(target, effect);
          }
        }
        break;

      // Apply a shield to the target and track shielding done
      case AbilityEffectType.shield:
        target.shield(source, finalAmount);
        break;

      // Heal the target, track healing done, and clamp to maxHealth
      case AbilityEffectType.heal:
        target.heal(source, finalAmount);
        break;

      // Deal damage to the target, with support for DoT and lifesteal
      case AbilityEffectType.damage:
        _showEffectVisual(target, effect);

        if (source.stats.abilitiesCanCrit) {
          double finalDamage = finalAmount as double;
          double randDouble = Random().nextDouble();
          bool isCrit = randDouble < source.stats.critChance;
          if (isCrit) {
            finalDamage *= source.stats.critDamage;
            Unit.handleItemEffectsOnCrit(source, target);
            Unit.handleItemEffectsOnCritted(target);
          }

          finalDamage *= source.stats.damageAmp;
          if (finalDamage < 0) finalDamage = 0;
          finalAmount = finalDamage.toInt();
        }
        final damageType =
            effect.scalingStat == "attackDamage"
                ? DamageType.physical
                : DamageType.magic;
        if (effect.isDamageOverTime && effect.damageOverTimeDuration != null) {
          source.applyDamageOverTime(
            target,
            finalAmount,
            effect.damageOverTimeDuration!,
            type: damageType,
          );
        } else {
          target.takeDamage(finalAmount.toDouble(), source, damageType);
        }
        break;

      // Apply a temporary or permanent stat buff
      case AbilityEffectType.statBuff:
        if (effect.stat != null) {
          if (effect.duration != null) {
            _showEffectVisual(target, effect);
            GameManager.instance!.combatManager!.addTimedEffect(
              TimedEffect(
                target: target,
                stat: effect.stat!,
                amount: finalAmount,
                duration: effect.duration!,
              ),
            );
          } else {
            target.applyStatModifier(effect.stat!, finalAmount);
          }
        }
        break;

      // Apply a stat debuff (temporary or permanent negative stat)
      case AbilityEffectType.statDebuff:
        if (effect.stat != null) {
          if (effect.duration != null) {
            _showEffectVisual(target, effect);
            GameManager.instance!.combatManager!.addTimedEffect(
              TimedEffect(
                target: target,
                stat: effect.stat!,
                amount: -finalAmount,
                duration: effect.duration!,
              ),
            );
          } else {
            target.applyStatModifier(effect.stat!, -finalAmount);
          }
        }
        break;

      // Create a summoned unit with stats scaled from the source
      case AbilityEffectType.summon:
        if (effect.summonStats == null ||
            effect.summonUnitName == null ||
            effect.summonImagePath == null) {
          return;
        }

        // Compute each scaled stat based on provided multipliers
        Map<String, int> computedStats = {};
        for (final entry in effect.summonStats!.entries) {
          final statName = entry.key;
          final scaling = entry.value;
          final percent = scaling.percentByTier[tierIndex];
          int value;

          if (scaling.scalingStat == null) {
            value = percent.round();
          } else {
            int baseStat;
            switch (scaling.scalingStat) {
              case "ap":
              case "abilityPower":
                baseStat = source.stats.abilityPower;
                break;
              case "ad":
              case "attackDamage":
                baseStat = source.stats.attackDamage;
                break;
              case "maxHealth":
                baseStat = source.stats.maxHealth;
                break;
              default:
                baseStat = 0;
            }
            value = (baseStat * percent).round();
          }
          computedStats[statName] = value;
        }

        // Build the UnitStats for the summoned unit
        final summonStats = UnitStats(
          baseMaxHealth: computedStats["maxHealth"] ?? 1,
          baseAttackDamage: computedStats["attackDamage"] ?? 1,
          baseAttackSpeed: 0.7,
          baseArmor: computedStats["armor"] ?? 0,
          baseMagicResist: computedStats["magicResist"] ?? 0,
          baseRange: computedStats["range"] ?? 1,
          baseMaxMana: 0,
          baseStartingMana: 0,
          baseAbilityPower: computedStats["abilityPower"] ?? 0,
          baseCritChance: 0.25,
          baseCritDamage: 1.5,
          baseLifesteal: 0.0,
          baseMovementSpeed: computedStats["movementSpeed"]?.toDouble() ?? 1.0,
          baseDamageAmp: 1.0,
          baseOnAttackStats: OnAttackStats.empty,
        );

        final summon = SummonedUnit(
          id:
              "summon_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}",
          unitName: effect.summonUnitName!,
          stats: summonStats,
          summoner: source,
          imagePath: effect.summonImagePath!,
        );

        summon.isEnemy = source.isEnemy;
        summon.applyEngineerBonus();

        GameManager.instance!.boardManager!.addSummonedUnit(
          summon,
          isEnemy: summon.isEnemy,
        );
        break;

      // Moves the unit (toward or away from target) by a given number of tiles
      case AbilityEffectType.dash:
        final dashRange = effect.dashRange ?? 1;
        final dashAway = effect.dashAway ?? false;

        final enemyUnits =
            GameManager.instance!.allUnitsInCombat
                .where((u) => u.team != team && u.isAlive)
                .toList();

        Position targetPosition = Position(boardY, boardX);

        if (dashAway) {
          targetPosition = _findDashPositionAway(enemyUnits, dashRange);
        } else {
          final targetUnit = _findDashTarget(effect.targeting, enemyUnits);
          if (targetUnit != null) {
            currentTargetId = targetUnit.id;
            targetPosition = _findDashPositionToward(targetUnit, dashRange);
          }
        }

        GameManager.instance!.boardManager?.moveUnitOnBoard(
          this,
          targetPosition,
        );
        break;

      // Launches a projectile across a path that applies effects along the way or on impact
      case AbilityEffectType.projectile:
        final targets = _resolveEffectTargets(effect.targeting, null);
        if (targets.isEmpty) return;

        final targetUnit = targets.first;
        final targetPosition = Position(targetUnit.boardY, targetUnit.boardX);

        final bm = GameManager.instance!.boardManager!;
        final gm = GameManager.instance!;
        final tileSize = gm.tileSize ?? 48.0;

        final path = _computeProjectilePath(
          targetPosition,
          effect.projectileWidth ?? 1,
        );
        final projectileSpeed = effect.projectileTravelSpeed ?? 5.0;
        final delayPerTile = Duration(milliseconds: (1000 ~/ projectileSpeed));

        final sprite = effect.projectileSpritePath;
        if (sprite != null) {
          final from = gm.boardTileToScreenOffset(
            boardY,
            boardX,
            tileSize,
            "ranged",
          );

          final totalDistance = max(
            (targetPosition.row - boardY).abs(),
            (targetPosition.col - boardX).abs(),
          );
          final duration = Duration(
            milliseconds: (1000 * totalDistance ~/ projectileSpeed),
          );

          gm.showProjectileEffectFollowing(
            from: from,
            target: targetUnit,
            imagePath: sprite,
            duration: duration,
          );
        }

        final encountered = <String>{};

        Future<void> processProjectile() async {
          for (int i = 0; i < path.length; i++) {
            final pos = path[i];
            await Future.delayed(delayPerTile);

            final unitAtPos = bm.getUnitAt(pos);
            if (unitAtPos != null &&
                unitAtPos.isAlive &&
                !encountered.contains(unitAtPos.id)) {
              encountered.add(unitAtPos.id);

              // Apply pass-through effects
              if (effect.passThroughEffects != null) {
                for (final pass in effect.passThroughEffects!) {
                  _applyAbilityEffect(this, unitAtPos, pass);
                }
              }

              // If projectile stops at first enemy, apply impact effects and exit
              if (effect.projectileStopsAtFirstHit && unitAtPos.team != team) {
                if (effect.impactEffects != null) {
                  final impactTargets = bm.getUnitsInArea(
                    targetPosition,
                    effect.targeting.areaShape,
                    effect.targeting.size,
                    _getUnitsByTeam(effect.targeting.targetTeam),
                  );
                  for (final unit in impactTargets) {
                    for (final impact in effect.impactEffects!) {
                      _applyAbilityEffect(this, unit, impact);
                    }
                  }
                }
                return;
              }
            }
          }

          // If projectile reached the end, apply area impact effects
          if (effect.impactEffects != null) {
            final impactTargets = bm.getUnitsInArea(
              targetPosition,
              effect.targeting.areaShape,
              effect.targeting.size,
              _getUnitsByTeam(effect.targeting.targetTeam),
            );
            for (final unit in impactTargets) {
              for (final impact in effect.impactEffects!) {
                _applyAbilityEffect(this, unit, impact);
              }
            }
          }
        }

        processProjectile();
        break;
    }
  }

  // Applies periodic (tick-based) damage to a target over a set duration
  void applyDamageOverTime(
    Unit target,
    int totalDamage,
    Duration duration, {
    DamageType type = DamageType.magic,
  }) {
    final combatManager = GameManager.instance!.combatManager!;
    final tickInterval = Duration(seconds: 1);
    final tickCount = duration.inSeconds.clamp(1, duration.inSeconds);
    final damagePerTick = (totalDamage / tickCount).round();
    int ticksApplied = 0;

    combatManager.addCombatEffect(
      CombatEffect(
        sourceId: id,
        targetUnit: target,
        interval: tickInterval,
        action: (unit, source) {
          if (!unit.isAlive) return;

          unit.takeDamage(damagePerTick.toDouble(), source, type);
          ticksApplied++;

          if (ticksApplied >= tickCount) {
            combatManager.activeEffects.removeWhere(
              (e) => e.sourceId == id && e.targetUnit.id == unit.id,
            );
          }
        },
      ),
    );
  }

  // Computes all tile positions affected by a projectile from this unit to the target
  // Takes width into account for AoE or multi-tile projectiles
  List<Position> _computeProjectilePath(Position targetPos, int width) {
    List<Position> path = [];

    final deltaX = targetPos.col - boardX;
    final deltaY = targetPos.row - boardY;
    final steps = max(deltaX.abs(), deltaY.abs());

    for (int step = 1; step <= steps; step++) {
      final x = boardX + (deltaX * step ~/ steps);
      final y = boardY + (deltaY * step ~/ steps);

      for (int dx = -(width ~/ 2); dx <= width ~/ 2; dx++) {
        for (int dy = -(width ~/ 2); dy <= width ~/ 2; dy++) {
          final pos = Position(y + dy, x + dx);
          if (GameManager.instance!.boardManager!.isValidBoardPosition(pos)) {
            path.add(pos);
          }
        }
      }
    }

    return path;
  }

  // Finds the best position within a range to dash away from a group of enemies
  // Prefers furthest average distance from all enemies
  Position _findDashPositionAway(List<Unit> enemies, int range) {
    final bm = GameManager.instance!.boardManager!;
    int maxDistance = -1;
    Position bestPosition = Position(boardY, boardX);

    for (int dx = -range; dx <= range; dx++) {
      for (int dy = -range; dy <= range; dy++) {
        final newX = boardX + dx;
        final newY = boardY + dy;
        final newPosition = Position(newY, newX);

        if (!bm.isValidBoardPosition(newPosition)) continue;

        final isCurrent = newX == boardX && newY == boardY;
        final occupied = bm.getUnitAt(newPosition);
        if (!isCurrent && occupied != null) continue;

        final avgDist =
            enemies
                .map(
                  (e) => BoardManager.calculateDistanceCoords(
                    newX,
                    newY,
                    e.boardX,
                    e.boardY,
                  ),
                )
                .fold(0, (sum, dist) => sum + dist) /
            enemies.length;

        if (avgDist > maxDistance) {
          maxDistance = avgDist.round();
          bestPosition = newPosition;
        }
      }
    }

    return bestPosition;
  }

  // Displays a visual effect on the target unit, if the effect has an image
  void _showEffectVisual(Unit target, AbilityEffect effect) {
    if (effect.effectImagePath == null) {
      return;
    }
    final gm = GameManager.instance!;
    gm.showEffectOnUnit(
      target: target,
      imagePath: effect.effectImagePath!,
      duration: effect.duration,
    );
  }

  // Finds the nearest free tile adjacent to a target unit to dash toward
  Position _findDashPositionToward(Unit target, int range) {
    final adjacentPositions = target.getAdjacentFreePositions();

    if (adjacentPositions.isEmpty) {
      return Position(boardY, boardX);
    }

    // Sort by distance from this unit to target-adjacent positions
    adjacentPositions.sort((a, b) {
      final distA = BoardManager.calculateDistanceCoords(
        boardX,
        boardY,
        a.col,
        a.row,
      );
      final distB = BoardManager.calculateDistanceCoords(
        boardX,
        boardY,
        b.col,
        b.row,
      );
      return distA.compareTo(distB);
    });

    return adjacentPositions.first;
  }

  // Selects the best target to dash to, based on targeting rule
  Unit? _findDashTarget(TargetingRule rule, List<Unit> enemies) {
    switch (rule.selection) {
      case TargetSelection.highestStat:
        enemies.sort(
          (a, b) =>
              _getStatValue(b, rule.statName!) -
              _getStatValue(a, rule.statName!),
        );
        return enemies.firstOrNull;
      case TargetSelection.lowestStat:
        enemies.sort(
          (a, b) =>
              _getStatValue(a, rule.statName!) -
              _getStatValue(b, rule.statName!),
        );
        return enemies.firstOrNull;
      case TargetSelection.mostCanHit:
        enemies.sort(
          (a, b) => b.getAdjacentUnits().length - a.getAdjacentUnits().length,
        );
        return enemies.firstOrNull;
      case TargetSelection.target:
        return GameManager.instance?.findUnitById(currentTargetId!);
      default:
        return null;
    }
  }

  // Returns all adjacent empty tiles around this unit
  List<Position> getAdjacentFreePositions() {
    List<Position> positions = [];
    final bm = GameManager.instance!.boardManager!;

    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;

        final newX = boardX + dx;
        final newY = boardY + dy;
        final newPosition = Position(newY, newX);

        if (bm.isValidBoardPosition(newPosition) &&
            bm.getUnitAt(newPosition) == null) {
          positions.add(newPosition);
        }
      }
    }

    return positions;
  }

  // Temporarily prevents this unit from gaining mana after casting an ability
  void _startManaLockTimer({Duration duration = const Duration(seconds: 1)}) {
    _manaLockTimer?.cancel();
    _manaLockTimer = Timer(duration, () {
      isManaLocked = false;
      _manaLockTimer = null;
    });
  }

  // Handles executing a basic attack on the given target
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
    _handleItemEffectsOnAttack(this, target);
    target.takeDamage(damage, this, DamageType.physical);
    gainMana(10);
    notifyListeners();

    return true;
  }

  // Performs a special attack with a multiplier, used by things like Scout ult
  void performSpecialAttack(Unit target, Unit source, double damageMultiplier) {
    if (!target.isAlive) return;

    double baseDamage = stats.attackDamage * damageMultiplier;

    target.takeDamage(baseDamage, source, DamageType.physical);
  }

  // Marks this unit as dead
  void die() {
    state = UnitState.dead;
  }

  // Resets all dynamic runtime state back to default — useful for resetting between rounds
  void reset() {
    state = UnitState.idle;

    stats.resetBonusStats();

    stats.itemMaxHealth = 0;
    stats.itemAttackDamage = 0;
    stats.itemAttackSpeed = 0.0;
    stats.itemArmor = 0;
    stats.itemMagicResist = 0;
    stats.itemAbilityPower = 0;
    stats.itemCritChance = 0.0;
    stats.itemCritDamage = 0.0;
    stats.itemLifesteal = 0.0;
    stats.itemStartingMana = 0;
    stats.itemDamageAmp = 0.0;
    stats.itemDamageReduction = 0.0;
    stats.itemRange = 0;
    stats.itemOnAttackStats = OnAttackStats.empty;

    // Reapply bonuses from equipped items
    if (_weapon != null) stats.applyItemBonus(_weapon!.statsBonus);
    if (_armor != null) stats.applyItemBonus(_armor!.statsBonus);
    if (_trinket != null) stats.applyItemBonus(_trinket!.statsBonus);

    stats.currentHealth = stats.maxHealth;
    stats.currentMana = stats.startingMana;
    stats.currentShield = 0;
    appliesBattlemageDebuff = false;
    attackCounter = 0;
    currentTargetId = null;
    movementTargetPos = null;
    timeUntilNextAttack = 0.0;
    movementProgress = 0.0;

    isManaLocked = false;
    _manaLockTimer?.cancel();
    _manaLockTimer = null;

    // Reset engineer bonus flag if it's a summon
    if (this is SummonedUnit) {
      (this as SummonedUnit).setHasAppliedEngineerBonus = false;
    }
  }

  // Deep clone of this unit with optional overrides, including resetting stats
  Unit copyWith({
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
    bool? isFromShop,
  }) {
    String newId =
        id ??
        '${unitName ?? this.unitName}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000000)}';

    Unit newUnit =
        Unit(
            id: newId,
            unitName: unitName ?? this.unitName,
            unitClass: unitClass ?? this.unitClass,
            synergies: synergies ?? List.from(this.synergies),
            cost: cost ?? this.cost,
            tier: tier ?? this.tier,
            stats: stats ?? this.stats.copyWith(),
            abilityName: abilityName,
            imagePath: imagePath ?? this.imagePath,
            classes: classes ?? List.from(this.classes),
            origins: origins ?? List.from(this.origins),
            isSummon: isSummon ?? this.isSummon,
            appliesBattlemageDebuff:
                appliesBattlemageDebuff ?? this.appliesBattlemageDebuff,
            isFromShop: this.isFromShop,
          )
          ..state = state ?? this.state
          ..position = position ?? this.position
          ..isOnBoard = isOnBoard ?? this.isOnBoard
          ..boardX = boardX ?? this.boardX
          ..boardY = boardY ?? this.boardY
          ..benchIndex = benchIndex ?? this.benchIndex
          .._weapon = weapon ?? _weapon?.copyWith()
          .._armor = armor ?? _armor?.copyWith()
          .._trinket = trinket ?? _trinket?.copyWith()
          ..isEnemy = isEnemy ?? this.isEnemy;

    // If stats weren't passed in, reset and reapply items
    if (stats == null) {
      newUnit.stats.resetBonusStats();
      if (newUnit._weapon != null) {
        newUnit.stats.applyItemBonus(newUnit._weapon!.statsBonus);
      }
      if (newUnit._armor != null) {
        newUnit.stats.applyItemBonus(newUnit._armor!.statsBonus);
      }
      if (newUnit._trinket != null) {
        newUnit.stats.applyItemBonus(newUnit._trinket!.statsBonus);
      }
    }

    // Set board or bench placement
    if (isOnBoard ?? this.isOnBoard) {
      newUnit.benchIndex = -1;
      newUnit.boardX = boardX ?? this.boardX;
      newUnit.boardY = boardY ?? this.boardY;
    } else {
      newUnit.benchIndex = benchIndex ?? this.benchIndex;
      newUnit.boardX = -1;
      newUnit.boardY = -1;
    }

    return newUnit;
  }

  // Returns a new upgraded version of this unit at next tier
  Unit upgrade() {
    return Unit(
        id:
            '${unitName}_upgraded_${tier + 1}_${DateTime.now().millisecondsSinceEpoch}',
        unitName: unitName,
        unitClass: unitClass,
        synergies: synergies,
        cost: cost,
        tier: tier + 1,
        stats: stats.upgrade(tier + 1),
        imagePath: imagePath,
        classes: classes,
        origins: origins,
        isSummon: isSummon,
        abilityName: abilityName,
        appliesBattlemageDebuff: appliesBattlemageDebuff,
      )
      ..isOnBoard = isOnBoard
      ..boardX = boardX
      ..boardY = boardY
      ..benchIndex = benchIndex
      ..isEnemy = isEnemy;
  }

  // Called during unit combine to increase stats and remove items from sacrificed units
  List<Item> combineWith(List<Unit> otherCopies) {
    List<Item> unequippedItems = [];

    for (var unit in otherCopies) {
      if (unit.weapon != null) unequippedItems.add(unit.weapon!);
      if (unit.armor != null) unequippedItems.add(unit.armor!);
      if (unit.trinket != null) unequippedItems.add(unit.trinket!);
    }

    tier++;

    double multiplier =
        tier == 2
            ? 1.6
            : tier == 3
            ? 1.6
            : 1.0;

    int originalBaseHealth = stats.baseMaxHealth;
    int originalBaseAD = stats.baseAttackDamage;

    stats.baseMaxHealth = (originalBaseHealth * multiplier).floor();
    stats.baseAttackDamage = (originalBaseAD * multiplier).floor();

    stats.currentHealth = stats.maxHealth;

    return unequippedItems;
  }

  // Helper method for combine logic to determine which copy should become the upgraded unit
  static Unit findBaseUnitForCombine(List<Unit> copies) {
    if (copies.isEmpty) return copies[0];

    var boardUnits = copies.where((u) => u.isOnBoard).toList();
    if (boardUnits.isNotEmpty) {
      boardUnits.sort((a, b) {
        if (a.boardY != b.boardY) return a.boardY.compareTo(b.boardY);
        return a.boardX.compareTo(b.boardX);
      });
      return boardUnits.first;
    }

    var benchUnits = copies.where((u) => !u.isOnBoard).toList();
    benchUnits.sort((a, b) => a.benchIndex!.compareTo(b.benchIndex!));
    return benchUnits.first;
  }

  // Called every frame to update logic like stuns, healing over time, scout ults, etc
  void update(double deltaTime) {
    if (isStunned && stunDuration > 0) {
      stunDuration -= deltaTime;
      if (stunDuration <= 0) {
        isStunned = false;
        stunDuration = 0;
      }
    }

    // Check for Scout special attack trigger
    if (stats.hasScoutSpecialAttack) {
      stats.scoutSpecialAttackTimer += deltaTime;
      if (stats.scoutSpecialAttackTimer >= stats.scoutSpecialAttackInterval) {
        stats.scoutSpecialAttackTimer = 0.0;

        Unit? target = _findStatTarget(
          team == 0 ? 1 : 0,
          "currentHealth",
          lowest: false,
        );

        if (target != null) {
          performSpecialAttack(target, this, 1.5);
        }
      }
    }

    // Handle Chronospark periodic healing
    if (stats.appliesChronosparkHeal) {
      stats.chronosparkHealTimer += deltaTime;
      if (stats.chronosparkHealTimer >= stats.chronosparkHealInterval) {
        stats.chronosparkHealTimer = 0.0;

        final percentHeal = stats.chronosparkHealPercent;
        final healAmount = (stats.maxHealth * percentHeal).round();
        stats.currentHealth = (stats.currentHealth + healAmount).clamp(
          0,
          stats.maxHealth,
        );
      }
    }

    _handleItemEffectsOnUpdate(deltaTime);
  }

  // Applies a stun for a duration
  void applyStun(double duration) {
    if (!stats.stunImmune) {
      isStunned = true;
      stunDuration = duration;
      notifyListeners();
    }
  }

  // Returns true if unit can cast (not stunned and has a mana bar)
  bool canCastAbility() {
    return !isStunned && stats.maxMana > 0;
  }

  // Returns true if unit is able to perform a basic attack
  bool canAttack() {
    return !isStunned && isAlive;
  }

  // Handles bonus Emberhill attack speed after movement
  void checkEmberhillMovement() {
    if (!stats.hasEmberhillMovementBuff || !isOnBoard) {
      return;
    }

    Position currentPos = Position(boardY, boardX);

    if (lastPosition != null &&
        (currentPos.row != lastPosition!.row ||
            currentPos.col != lastPosition!.col)) {
      stats.combatStartAttackSpeedBonus += stats.emberhillAttackSpeedBonus;
    }
    lastPosition = currentPos;
  }

  // Getters/setters for GameManager singleton
  GameManager? get gameManager => GameManager.instance;
  set gameManager(GameManager? value) {
    GameManager.instance = value;
  }

  // Utility wrappers to get valid targets from CombatManager
  List<Unit> getValidTargets() {
    return GameManager.instance?.combatManager?.getValidTargets(this) ?? [];
  }

  List<Unit> getAdjacentUnits() {
    return GameManager.instance?.boardManager?.getAdjacentUnits(this) ?? [];
  }

  // Returns the value for this unit if sold
  int get sellValue {
    return GameManager.instance?.boardManager?.calculateSellValue(this) ?? 0;
  }

  // Static helper to deeply clone a unit — used for enemy unit spawning
  static Unit clone(Unit other) {
    var cloned = Unit(
      id:
          'clone_${other.unitName}_enemy_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000000)}',
      unitName: other.unitName,
      unitClass: other.unitClass,
      synergies: List<String>.from(other.synergies),
      cost: other.cost,
      tier: other.tier,
      stats: other.stats.copyWith(),
      imagePath: other.imagePath,
      classes: List<String>.from(other.classes),
      origins: List<String>.from(other.origins),
      isSummon: other.isSummon,
      appliesBattlemageDebuff: other.appliesBattlemageDebuff,
      abilityName: other.abilityName,
    );

    // Copy runtime state
    cloned.isOnBoard = other.isOnBoard;
    cloned.boardX = other.boardX;
    cloned.boardY = other.boardY;
    cloned.team = other.team;
    cloned.isEnemy = other.isEnemy;

    cloned.state = other.state;
    cloned.position = other.position;
    cloned.currentTargetId = other.currentTargetId;
    cloned.movementTargetPos = other.movementTargetPos;
    cloned.timeUntilNextAttack = other.timeUntilNextAttack;
    cloned.movementProgress = other.movementProgress;

    cloned.isStunned = other.isStunned;
    cloned.stunDuration = other.stunDuration;

    return cloned;
  }

  void _handleItemEffectsOnAttack(Unit attacker, Unit target) {
    final items = attacker.getEquippedItems();

    for (var item in items) {
      if (item.id.startsWith('item_twinfang_blade')) {
        final adjacentEnemies =
            attacker.getValidTargets().where((enemy) {
              return (enemy.boardX - target.boardX).abs() <= 1 &&
                  (enemy.boardY - target.boardY).abs() <= 1 &&
                  enemy.id != target.id;
            }).toList();
        for (var enemy in adjacentEnemies) {
          enemy.takeDamage(
            attacker.stats.attackDamage * 0.15,
            attacker,
            DamageType.physical,
          );
        }
      } else if (item.id.startsWith('item_bladed_repeater')) {
        if (attackCounter % 3 == 0) {
          target.takeDamage(
            attacker.stats.attackDamage * .5,
            attacker,
            DamageType.physical,
          );
        }
      } else if (item.id.startsWith('item_tempest_string')) {
        attacker.applyStatModifier("attackSpeed", 3);
      } else if (item.id.startsWith('item_spellshot_launcher')) {
        if (Random().nextDouble() < 0.5) {
          target.takeDamage(
            attacker.stats.abilityPower * 0.33,
            attacker,
            DamageType.magic,
          );
        }
      } else if (item.id.startsWith('item_leeching_arrows')) {
        Unit? lowestHealth = _findStatTarget(
          attacker.team,
          "CurrentHealth",
          lowest: true,
        );
        if (lowestHealth != null) {
          final healAmount = (lowestHealth.stats.maxHealth * 0.01).round();
          lowestHealth.heal(attacker, healAmount);
        }
      } else if (item.id.startsWith('item_mystic_harness')) {
        if (attacker.stats.mysticHarnessBonus < 50) {
          attacker.stats.combatStartArmorBonus += 5;
          attacker.stats.combatStartMagicResistBonus += 5;
          attacker.stats.mysticHarnessBonus += 5;
        }
      } else if (item.id.startsWith("item_forged_zephyr")) {
        attacker.stats.combatStartAbilityPowerBonus += 5;
      }
    }
  }

  void _handleItemEffectsOnDamageDealt(Unit attacker, Unit target, int damage) {
    final items = attacker.getEquippedItems();

    for (final item in items) {
      if (item.id.startsWith('item_arcblade')) {
        if (!target.stats.healingReduced) {
          final duration = Duration(seconds: 5);
          final startTime = DateTime.now();

          target.stats.healingReduced = true;
          // Apply 40% healing reduction to target (implement as a timed effect or flag)
          GameManager.instance?.combatManager?.addCombatEffect(
            CombatEffect(
              sourceId: attacker.id,
              targetUnit: target,
              interval: Duration(milliseconds: 250),
              action: (unit, source) {
                final now = DateTime.now();
                final expired = now.difference(startTime) >= duration;
                if (expired) {
                  unit.stats.healingReduced = false;
                  GameManager.instance?.combatManager?.activeEffects
                      .removeWhere(
                        (e) =>
                            e.sourceId == source.id &&
                            e.targetUnit.id == unit.id,
                      );
                }
              },
            ),
          );
        }
      } else if (item.id.startsWith('item_twin_conduits')) {
        // Reduce damage reduction by 10% temporarily
        GameManager.instance?.combatManager?.addTimedEffect(
          TimedEffect(
            target: target,
            stat: "damageReduction",
            amount: -10,
            duration: Duration(seconds: 4),
          ),
        );
      } else if (item.id.startsWith('item_swift_helm')) {
        if (!target.stats.hasArmorReduced) {
          final duration = Duration(seconds: 10);
          final startTime = DateTime.now();

          target.stats.hasArmorReduced = true;
          // Apply 40% healing reduction to target (implement as a timed effect or flag)
          GameManager.instance?.combatManager?.addCombatEffect(
            CombatEffect(
              sourceId: attacker.id,
              targetUnit: target,
              interval: Duration(milliseconds: 250),
              action: (unit, source) {
                final now = DateTime.now();
                final expired = now.difference(startTime) >= duration;
                if (expired) {
                  unit.stats.hasArmorReduced = false;
                  GameManager.instance?.combatManager?.activeEffects
                      .removeWhere(
                        (e) =>
                            e.sourceId == source.id &&
                            e.targetUnit.id == unit.id,
                      );
                }
              },
            ),
          );
        }
      } else if (item.id.startsWith('item_bloodstaff')) {
        final lowest = _findStatTarget(
          attacker.team,
          "CurrentHealth",
          lowest: true,
        );
        int bonusHeal = (damage * attacker.stats.lifesteal).floor();
        if (bonusHeal > 0 && lowest != attacker) {
          lowest?.heal(attacker, bonusHeal);
        }
      } else if (item.id.startsWith('item_magebane_plate')) {
        if (!target.stats.hasMRReduced) {
          final duration = Duration(seconds: 10);
          final startTime = DateTime.now();

          target.stats.hasMRReduced = true;
          // Apply 40% healing reduction to target (implement as a timed effect or flag)
          GameManager.instance?.combatManager?.addCombatEffect(
            CombatEffect(
              sourceId: attacker.id,
              targetUnit: target,
              interval: Duration(milliseconds: 250),
              action: (unit, source) {
                final now = DateTime.now();
                final expired = now.difference(startTime) >= duration;
                if (expired) {
                  unit.stats.hasMRReduced = false;
                  GameManager.instance?.combatManager?.activeEffects
                      .removeWhere(
                        (e) =>
                            e.sourceId == source.id &&
                            e.targetUnit.id == unit.id,
                      );
                }
              },
            ),
          );
        }
      }
    }
  }

  static void handleItemEffectsOnStartCombat(Unit unit) {
    final items = unit.getEquippedItems();

    for (final item in items) {
      if (item.id.startsWith('item_bloodpiercer') ||
          item.id.startsWith('item_chaos_prism') ||
          item.id.startsWith("item_forged_jeweledscope")) {
        // Allow physical ability damage to crit
        unit.stats.abilitiesCanCrit = true;
      } else if (item.id.startsWith('item_spiked_visor')) {
        // Enable crit shield flag and apply 25% crit chance buff when shielded (handled elsewhere when shield is applied)
        unit.stats.canCriticallyShield = true;
        unit.stats.spikedVisorCritBonusActive = false;
        unit.stats.spikedVisorCritBonusAmount = 0.25;
      } else if (item.id.startsWith('item_runed_helm')) {
        // Grant a 300% AP-based shield at start of combat
        int shieldAmount = (unit.stats.abilityPower * 3).floor();
        unit.shield(unit, shieldAmount);
      } else if (item.id.startsWith("item_forged_guardian")) {
        int shieldAmount = (unit.stats.abilityPower * 5).floor();
        unit.shield(unit, shieldAmount);
      } else if (item.id.startsWith("item_bladed_helm")) {
        if (!unit.stats.stunImmune) {
          final duration = Duration(seconds: 10);
          final startTime = DateTime.now();

          unit.stats.stunImmune = true;
          // Apply 40% healing reduction to target (implement as a timed effect or flag)
          GameManager.instance?.combatManager?.addCombatEffect(
            CombatEffect(
              sourceId: unit.id,
              targetUnit: unit,
              interval: Duration(milliseconds: 250),
              action: (unit, source) {
                final now = DateTime.now();
                final expired = now.difference(startTime) >= duration;
                if (expired) {
                  unit.stats.stunImmune = false;
                  GameManager.instance?.combatManager?.activeEffects
                      .removeWhere(
                        (e) =>
                            e.sourceId == source.id &&
                            e.targetUnit.id == unit.id,
                      );
                }
              },
            ),
          );
        }
      } else if (item.id.startsWith("item_guarded_saber")) {
        unit.stats.combatStartAttackDamageBonus +=
            (unit.stats.attackDamage / unit.stats.baseAttackDamage).toInt();
      }
    }
  }

  void _handleItemEffectsOnHeal(Unit recipient, int healAmount, int overheal) {
    final healedItems = recipient.getEquippedItems();

    for (final item in healedItems) {
      if (item.id.startsWith('item_vampiric_blade')) {
        // Overhealing creates shield (up to 10% max HP)
        if (overheal > 0) {
          int maxShield = (recipient.stats.maxHealth * 0.10).floor();
          int shieldAmount = overheal.clamp(
            0,
            max(maxShield - recipient.stats.currentShield, 0),
          );
          if (shieldAmount > 0) {
            recipient.shield(recipient, shieldAmount);
          }
        }
      } else if (item.id.startsWith('item_darkbinding_charm')) {
        // Heals gain 5 Magic Resist for 1s
        GameManager.instance?.combatManager?.addTimedEffect(
          TimedEffect(
            target: recipient,
            stat: "AbilityPower",
            amount: 5,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (item.id.startsWith('item_warlock_talisman')) {
        if (recipient.currentTargetId != null) {
          Unit? target = GameManager.instance!.findUnitById(
            recipient.currentTargetId!,
          );
          if (target != null) {
            target.takeDamage(
              healAmount * .5,
              recipient,
              DamageType.magic,
              true,
            );
          }
        }
      }
    }
  }

  static void handleItemEffectsOnCrit(Unit attacker, Unit target) {
    final items = attacker.getEquippedItems();

    for (final item in items) {
      if (item.id.startsWith('item_blood_charm')) {
        // Heal 3% of missing HP on crit
        final missingHP =
            attacker.stats.maxHealth - attacker.stats.currentHealth;
        final healAmount = (missingHP * 0.03).floor();
        attacker.heal(attacker, healAmount);
      } else if (item.id.startsWith('item_wardbreaker_gem')) {
        // Apply -10 MR to the target for 3s
        GameManager.instance?.combatManager?.addTimedEffect(
          TimedEffect(
            target: target,
            stat: "magicResist",
            amount: -10,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (item.id.startsWith('item_psychic_edge')) {
        attacker.gainMana(5, fromItem: true);
      }
    }
  }

  void _handleItemEffectsOnCast(Unit caster) {
    final items = caster.getEquippedItems();

    for (final item in items) {
      if (item.id.startsWith('item_focused_mind')) {
        // Gain 30% max mana on cast
        int bonusMana = (caster.stats.maxMana * 0.3).round();
        caster.gainMana(bonusMana);
      } else if (item.id.startsWith('item_aether_helm')) {
        // Gain 30 armor for 3s
        GameManager.instance?.combatManager?.addTimedEffect(
          TimedEffect(
            target: caster,
            stat: "armor",
            amount: 30,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (item.id.startsWith('item_mystic_charm')) {
        // Gain 100 HP shield
        caster.shield(caster, 100);
      } else if (item.id.startsWith('item_vital_core')) {
        // Heal 5% of missing HP
        final missing = caster.stats.maxHealth - caster.stats.currentHealth;
        final heal = (missing * 0.05).round();
        caster.heal(caster, heal);
      } else if (item.id.startsWith("item_forged_archmage")) {
        if (caster.stats.hasForgedArchmageBuff) {
          continue;
        } else {
          caster.stats.hasForgedArchmageBuff = true;
          caster.stats.combatStartAbilityPowerBonus += 100;
        }
      } else if (item.id.startsWith("item_forged_spirithelm")) {
        caster.heal(caster, (caster.stats.maxMana / 2).toInt());
      } else if (item.id.startsWith("item_vital_focus")) {
        caster.stats.combatStartAbilityPowerBonus += 10;
      } else if (item.id.startsWith("item_resonant_focus")) {}
      Unit? lowestHealth = _findStatTarget(
        caster.team,
        "CurrentHealth",
        lowest: true,
      );
      if (lowestHealth != null) {
        final healAmount = (caster.stats.abilityPower * 0.5).round();
        lowestHealth.heal(caster, healAmount);
      }
    }
  }

  void _handleItemEffectsOnManaGain(int mana) {
    final items = getEquippedItems();

    for (final item in items) {
      if (item.id.startsWith("item_runed_sabre")) {
        gainMana((mana * .2).toInt(), fromItem: true);
      }
    }
  }

  static void handleItemEffectsOnCritted(Unit target) {
    final items = target.getEquippedItems();
    for (final item in items) {
      if (item.id.startsWith('item_wicked_brooch')) {
        if (target.stats.hasWickedBroochCooldown == true) continue;
        final shield = (target.stats.maxHealth * 0.05).round();
        target.shield(target, shield);

        // Prevent re-triggering for 3s
        target.stats.hasWickedBroochCooldown = true;

        GameManager.instance?.combatManager?.addCombatEffect(
          CombatEffect(
            sourceId: target.id,
            targetUnit: target,
            interval: Duration(seconds: 3),
            action: (unit, _) {
              unit.stats.hasWickedBroochCooldown = false;
              GameManager.instance?.combatManager?.activeEffects.removeWhere(
                (e) =>
                    e.sourceId == unit.id &&
                    e.targetUnit.id == unit.id &&
                    e.interval == Duration(seconds: 3),
              );
            },
          ),
        );
      }
    }
  }

  void _handleItemEffectsOnKill(Unit killer) {
    final items = killer.getEquippedItems();

    for (final item in items) {
      if (item.id.startsWith('item_overflow_core')) {
        killer.gainMana(10);
        GameManager.instance?.combatManager?.addTimedEffect(
          TimedEffect(
            target: killer,
            stat: "damageAmp",
            amount: 5,
            duration: Duration(seconds: 6),
          ),
        );
      } else if (item.id.startsWith("item_forged_bloodlocket")) {
        killer.stats.combatStartHealthBonus += 100;
        killer.stats.currentHealth += 100;
      }
    }
  }

  void _handleItemEffectsOnUpdate(double deltaTime) {
    final items = getEquippedItems();

    for (final item in items) {
      if (item.id.startsWith('item_channeling_bow')) {
        stats.channelingBowTimer += deltaTime;
        if (stats.channelingBowTimer > 1.0) {
          stats.channelingBowTimer = 0.0;
          heal(this, (stats.attackSpeed * 500).toInt());
        }
      }
    }
  }

  void applyHealthStateEffects(Unit unit) {
    final items = unit.getEquippedItems();
    final healthPercent = unit.stats.currentHealth / unit.stats.maxHealth;

    for (final item in items) {
      if (item.id.startsWith('item_eternal_charm')) {
        if (healthPercent < 0.3 && !unit.stats.hasEternalCharmBonus) {
          unit.stats.combatStartLifestealBonus +=
              unit.stats.lifesteal; // Double it
          unit.stats.hasEternalCharmBonus = true;
        } else if (healthPercent >= 0.3 && unit.stats.hasEternalCharmBonus) {
          unit.stats.combatStartLifestealBonus -= unit.stats.lifesteal;
          unit.stats.hasEternalCharmBonus = false;
        }
      }
      if (item.id.startsWith('item_blood_vessel')) {
        if (healthPercent > 0.6) {
          GameManager.instance?.combatManager?.addCombatEffect(
            CombatEffect(
              sourceId: unit.id,
              targetUnit: unit,
              interval: Duration(seconds: 2),
              action: (u, _) {
                if (u.stats.currentHealth / u.stats.maxHealth <= 0.6) return;
                final healAmount = (u.stats.maxHealth * 0.03).round();
                u.heal(u, healAmount);
              },
            ),
          );
        }
      }
      if (item.id.startsWith('item_balanced_plate')) {
        if (healthPercent < 0.5 && !unit.stats.hasBalancedPlateBonus) {
          unit.stats.combatStartArmorBonus += 50;
          unit.stats.combatStartMagicResistBonus += 50;
          unit.stats.hasBalancedPlateBonus = true;
        }
      }
      if (item.id.startsWith('item_titan_hide')) {
        if (healthPercent > 0.6 && !unit.stats.hasTitanHideBonus) {
          unit.stats.combatStartDamageResistanceBonus += 0.10;
          unit.stats.hasTitanHideBonus = true;
        } else if (healthPercent <= 0.6 && unit.stats.hasTitanHideBonus) {
          unit.stats.combatStartDamageResistanceBonus -= 0.10;
          unit.stats.hasTitanHideBonus = false;
        }
      }
      if (item.id.startsWith('item_battle_plate')) {
        if (healthPercent < 0.5 && !unit.stats.hasBattlePlateBonus) {
          unit.stats.combatStartLifestealBonus += 0.10;
          unit.stats.hasBattlePlateBonus = true;
        } else if (healthPercent >= 0.5 && unit.stats.hasBattlePlateBonus) {
          unit.stats.combatStartLifestealBonus -= 0.10;
          unit.stats.hasBattlePlateBonus = false;
        }
      }
    }
    notifyListeners();
  }

  int handleItemEffectsOnTakeDamage(
    Unit unit,
    int damage,
    DamageType type,
    double mitigated,
  ) {
    final items = unit.getEquippedItems();
    double modifiedDamage = damage.toDouble();

    for (final item in items) {
      if (item.id.startsWith('item_iron_dome')) {
        if (type == DamageType.physical) {
          modifiedDamage *= 0.9;
        }
      } else if (item.id.startsWith('item_bulwarks_crown')) {
        if (!unit.stats.hasBulwarkShield) {
          final shieldAmount = 400;
          unit.shield(unit, shieldAmount);
          unit.stats.hasBulwarkShield = true;

          GameManager.instance?.combatManager?.addCombatEffect(
            CombatEffect(
              sourceId: unit.id,
              targetUnit: unit,
              interval: Duration(seconds: 5),
              action: (u, _) {
                u.stats.hasBulwarkShield = false;
                GameManager.instance?.combatManager?.activeEffects.removeWhere(
                  (e) =>
                      e.sourceId == u.id &&
                      e.targetUnit.id == u.id &&
                      e.interval == Duration(seconds: 5),
                );
              },
            ),
          );
        }
      } else if (item.id.startsWith('item_mystic_wrap')) {
        final heal = (mitigated * 0.15).floor();
        unit.heal(unit, heal);
      } else if (item.id.startsWith('item_hunters_coat')) {
        if (unit.stats.huntersCoatStacks < 20) {
          unit.stats.huntersCoatStacks += 1;
          unit.stats.combatStartAttackSpeedBonus += 0.01;
          unit.stats.combatStartAbilityPowerBonus += 1;
          unit.stats.combatStartAttackDamageBonus += 1;
        }
      } else if (item.id.startsWith('item_nullplate')) {
        if (unit.stats.nullplateBonus < 60) {
          unit.stats.nullplateBonus += 1;
          unit.stats.combatStartMagicResistBonus += 1;
        }
      }
    }

    return modifiedDamage.toInt();
  }
}
