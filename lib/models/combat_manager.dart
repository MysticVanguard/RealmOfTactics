import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'unit.dart';
import 'board_manager.dart';
import 'synergy_manager.dart';
import '../enums/damage_type.dart';
import 'board_position.dart';
import 'timed_effect.dart';
import 'package:realm_of_tactics/models/summoned_unit.dart';

// A simple effect that repeats a given action on a unit at set intervals during combat
class CombatEffect {
  // who caused the effect, the unit being affected, how often the effect triggers, what the effect does,
  final String sourceId;
  final Unit targetUnit;
  final Duration interval;
  final Function(Unit, Unit) action;
  Duration timeSinceLastTick = Duration.zero;

  CombatEffect({
    required this.sourceId,
    required this.targetUnit,
    required this.interval,
    required this.action,
  });
}

// Enum for what state combat is in
enum CombatState { idle, running, finished }

class CombatManager extends ChangeNotifier {
  final BoardManager boardManager;
  final SynergyManager synergyManager;

  // All active timed buffs/debuffs on units
  final List<TimedEffect> _activeTimedEffects = [];

  // The two sides of the battle
  List<Unit> _playerUnits = [];
  List<Unit> _enemyUnits = [];

  // Periodic effects like damage over time, etc
  final List<CombatEffect> _activeEffects = [];

  // How long combat has been running, Current state of combat, Optional timer for real-time combat ticks
  Duration _combatTime = Duration.zero;
  CombatState _state = CombatState.idle;
  Timer? _combatTimer;

  // Tracks how many attacks each unit has done (for things like every 5th attack)
  final Map<String, int> _unitAttackCounters = {};

  CombatManager({required this.boardManager, required this.synergyManager});

  // Getters
  CombatState get state => _state;
  Duration get combatTime => _combatTime;
  List<Unit> get playerUnits => _playerUnits;
  List<Unit> get enemyUnits => _enemyUnits;
  List<CombatEffect> get activeEffects => _activeEffects;

  // Called each time a combat round starts
  void startCombat(List<Unit> playerUnitsFromBoard, List<Unit> enemyUnits) {
    if (_state == CombatState.running) {
      return;
    }
    _state = CombatState.running;
    _combatTime = Duration.zero;
    _activeEffects.clear();
    _unitAttackCounters.clear();

    _playerUnits = playerUnitsFromBoard;
    _enemyUnits = enemyUnits;

    for (var unit in enemyUnits) {
      boardManager.registerEnemyUnit(unit);
    }

    int ironvaleLevel = synergyManager.getSynergyLevel('Ironvale');
    SummonedUnit? ironvaleSummon;
    if (ironvaleLevel == 1) {
      ironvaleSummon = boardManager.addSummonedUnit(
        IronvaleDrone(),
        isEnemy: false,
      );
    } else if (ironvaleLevel == 2) {
      ironvaleSummon = boardManager.addSummonedUnit(
        IronvaleTurret(),
        isEnemy: false,
      );
    } else if (ironvaleLevel == 3) {
      ironvaleSummon = boardManager.addSummonedUnit(
        IronvaleTank(),
        isEnemy: false,
      );
    }
    synergyManager.setCurrentIronvaleSummon(ironvaleSummon, isEnemy: false);
    SummonedUnit.setEngineerBonusAlly(
      synergyManager.getSynergyLevel('Engineer'),
    );
    ironvaleSummon?.applyEngineerBonus();
    // Apply all synergy bonuses and start-of-combat buffs
    synergyManager.applyStartOfCombatEffects([..._playerUnits, ..._enemyUnits]);

    // Reset combat stats and refill HP
    for (var unit in [..._playerUnits, ..._enemyUnits]) {
      if (unit.isAlive) {
        int healthToAdd = unit.stats.maxHealth - unit.stats.currentHealth;
        if (healthToAdd > 0) {
          unit.stats.currentHealth += healthToAdd;
        }
        unit.stats.physicalDamageDone = 0;
        unit.stats.magicDamageDone = 0;
        unit.stats.magicDamageBlocked = 0;
        unit.stats.physicalDamageBlocked = 0;
        unit.stats.healingDone = 0;
        unit.stats.shieldingDone = 0;
        Unit.handleItemEffectsOnStartCombat(unit);
      }
    }

    notifyListeners();
  }

  // Effect visuals, maps unit names to projectile or melee effect image
  final Map<String, List<String>> rangedProjectileEffects = {
    'images/effects/projectile_cannonball.png': [
      'depthcharge_bomber',
      'tempest_cannoneer',
    ],
    'images/effects/projectile_bullet.png': [
      'ashen_hunter',
      'chrono_sniper',
      "clockbot",
      "cloudburst_gunner",
      "glacier_marksman",
      "glyph_bomber",
      "ironvale_drone",
      "ironvale_turret",
      "skyfire_sharpshooter",
    ],
    'images/effects/projectile_dagger.png': [
      'blazestep_ranger',
      'northwind_tracker',
      "seedtinker",
    ],
    'images/effects/projectile_magic.png': [
      'borealis_arcanist',
      'clockmaker',
      "clockwork_medic",
      "cogsmith",
      "enigmancer",
      "firework_artisan",
      "flamespeaker",
      "frostscribe_mystic",
      "iron_turret",
      "mechwright",
      "rune_architect",
      "snowfall_priest",
      "spring_sage",
      "stonebinder",
      "thunder_caller",
      "timecarver",
      "zephyr_mage",
    ],
  };

  final Map<String, List<String>> meleeHitEffects = {
    'images/effects/melee_slash.png': [
      'cavern_raider',
      'cinderblade',
      "inferno_fencer",
      "mountainbreaker",
      "oathsworn",
      "spark_duelist",
      "stormlord",
      "winterblade_guardian",
    ],
    'images/effects/melee_pummel.png': [
      'cloudbreaker',
      'earthshaper',
      "emberforger",
      "epoch_guardian",
      "fireworkbot",
      "gearbot",
      "gearcaster",
      "granite_guard",
      "hearthguard",
      "highrock_bulwark",
      "ironclad",
      "ironvale_tank",
      "rimebound_vanguard",
      "runic_enforcer",
      "sigil_keeper",
      "stoneweaver",
      "stormcarver",
      "titan_sentinel",
      "veggiebot",
    ],
    'images/effects/melee_poke.png': [
      'colossus_rider',
      'farmland_protector',
      "fieldrunner",
      "flare_charger",
      "gearstep_agent",
      "harvest_warden",
      "icewall_sentinel",
      "nimbus_rider",
      "tunnel_rusher",
      "veilstrider",
      "windlance_champion",
    ],
  };

  // Returns the correct projectile sprite for a unit
  String? getRangedEffectSprite(String unitName) {
    for (final entry in rangedProjectileEffects.entries) {
      if (entry.value.contains(unitName.toLowerCase().replaceAll(" ", "_"))) {
        return entry.key;
      }
    }
    return null;
  }

  // Returns the correct melee sprite for a unit
  String? getMeleeEffectSprite(String unitName) {
    for (final entry in meleeHitEffects.entries) {
      if (entry.value.contains(unitName.toLowerCase().replaceAll(" ", "_"))) {
        return entry.key;
      }
    }
    return null;
  }

  // Returns a list of enemies directly adjacent to a unit
  List<Unit> _findAdjacentEnemies(
    Unit centerUnit,
    List<Unit> potentialTargets,
  ) {
    List<Unit> adjacentEnemies = [];
    if (!centerUnit.isOnBoard) return adjacentEnemies;

    int centerX = centerUnit.boardX;
    int centerY = centerUnit.boardY;

    for (var potentialTarget in potentialTargets) {
      if (potentialTarget.id == centerUnit.id ||
          !potentialTarget.isAlive ||
          !potentialTarget.isOnBoard) {
        continue;
      }

      int dx = (potentialTarget.boardX - centerX).abs();
      int dy = (potentialTarget.boardY - centerY).abs();

      if (dx <= 1 && dy <= 1) {
        adjacentEnemies.add(potentialTarget);
      }
    }
    return adjacentEnemies;
  }

  // Gets all living enemies for a unit
  List<Unit> getValidTargets(Unit unit) {
    if (!unit.isAlive || _state != CombatState.running) return [];

    List<Unit> enemies =
        _playerUnits.contains(unit) ? _enemyUnits : _playerUnits;

    return enemies.where((enemy) => enemy.isAlive).toList();
  }

  // Adds a timed buff/debuff
  void addTimedEffect(TimedEffect effect) {
    _activeTimedEffects.add(effect);
    effect.apply();
  }

  // Ticks through and removes expired timed effects
  void _updateTimedEffects() {
    final now = DateTime.now();
    _activeTimedEffects.removeWhere((effect) {
      final expired = now.difference(effect.appliedAt) >= effect.duration;
      if (expired) {
        effect.expire();
      }
      return expired;
    });
  }

  // Main update function called each tick to simulate combat
  void tick(Duration timeDelta) {
    if (_state != CombatState.running) return;

    _combatTime += timeDelta;
    double dt = timeDelta.inMilliseconds / 1000.0;

    _updateTimedEffects();
    List<Unit> unitsToRemove = [];
    List<Unit> allUnits = [..._playerUnits, ..._enemyUnits];

    for (var unit in allUnits) {
      if (!unit.isAlive) {
        unitsToRemove.add(unit);
        continue; // skip dead unit updating
      }
      if (unit.currentTargetId != null) {
        Unit? currentTarget = findUnitInstanceById(unit.currentTargetId!);
        if (currentTarget == null ||
            !currentTarget.isAlive ||
            !currentTarget.isOnBoard) {
          unit.currentTargetId = null;
          unit.movementTargetPos = null;
          unit.movementProgress = 0.0;
        }
      }
      unit.update(timeDelta.inMilliseconds.toDouble() / 1000);
      if (unit.hasSkyguardEvasion && unit.skyguardEvasionTimer > 0) {
        unit.skyguardEvasionTimer = max(0, unit.skyguardEvasionTimer - dt);
        if (unit.skyguardEvasionTimer <= 0) {}
      }
    }

    for (var unit in unitsToRemove) {
      if (unit.isOnBoard) {
        boardManager.remove(unit);
      }
      _enemyUnits.remove(unit);
    }

    for (var effect in List.from(_activeEffects)) {
      Unit? currentUnitInstance = findUnitInstanceById(effect.targetUnit.id);
      Unit? applierUnitInstance = findUnitInstanceById(effect.sourceId);
      if (currentUnitInstance == null || !currentUnitInstance.isAlive) continue;

      effect.timeSinceLastTick += timeDelta;
      if (effect.timeSinceLastTick >= effect.interval) {
        effect.action(currentUnitInstance, applierUnitInstance);
        effect.timeSinceLastTick -= effect.interval;
      }
    }

    Random random = Random();

    for (var unit in allUnits) {
      if (!unit.isAlive) continue;

      if (unit.timeUntilNextAttack > 0) {
        unit.timeUntilNextAttack -= dt;
      }

      unit.applyVitalFocusAura(unit);

      List<Unit> enemies =
          (_playerUnits.contains(unit)) ? _enemyUnits : _playerUnits;

      enemies = enemies.where((e) => e.isAlive && e.isOnBoard).toList();

      Unit? currentTarget =
          unit.currentTargetId != null
              ? findUnitInstanceById(unit.currentTargetId!)
              : null;

      Map<Unit, int> distances = {
        for (var enemy in enemies)
          enemy: BoardManager.calculateDistance(unit, enemy),
      };

      if (distances.isEmpty) {
        unit.currentTargetId = null;
        unit.movementTargetPos = null;
        unit.movementProgress = 0.0;
        continue;
      }

      int minDistance = distances.values.reduce(min);

      List<Unit> closestEnemies =
          distances.entries
              .where((entry) => entry.value == minDistance)
              .map((entry) => entry.key)
              .toList();

      bool needsNewTarget = false;
      if (currentTarget == null ||
          !currentTarget.isAlive ||
          !currentTarget.isOnBoard) {
        needsNewTarget = true;
      } else {
        int distance = BoardManager.calculateDistance(unit, currentTarget);
        if (distance > unit.stats.range + 2 &&
            !closestEnemies.contains(currentTarget)) {
          needsNewTarget = true;
        }
      }

      if (needsNewTarget) {
        if (enemies.isEmpty) {
          unit.currentTargetId = null;
          unit.movementTargetPos = null;
          unit.movementProgress = 0.0;
          continue;
        }

        Unit chosen =
            closestEnemies.isNotEmpty
                ? closestEnemies[Random().nextInt(closestEnemies.length)]
                : enemies[Random().nextInt(enemies.length)];

        unit.currentTargetId = chosen.id;
        unit.movementTargetPos = null;
        unit.movementProgress = 0.0;
        currentTarget = chosen;
      }

      if (currentTarget == null ||
          !currentTarget.isAlive ||
          !currentTarget.isOnBoard) {
        unit.currentTargetId = null;
        unit.movementTargetPos = null;
        unit.movementProgress = 0.0;
        continue;
      }

      int distance = BoardManager.calculateDistance(unit, currentTarget);

      if (distance <= unit.stats.range) {
        unit.movementTargetPos = null;
        unit.movementProgress = 0.0;
        if (unit.timeUntilNextAttack <= 0) {
          double baseDamage = unit.stats.attackDamage.toDouble();
          double finalDamage = baseDamage;
          bool isCrit = random.nextDouble() < unit.stats.critChance;
          if (isCrit) {
            finalDamage *= unit.stats.critDamage;
            Unit.handleItemEffectsOnCrit(unit, currentTarget);
            Unit.handleItemEffectsOnCritted(currentTarget);
          }

          finalDamage *= unit.stats.damageAmp;
          if (finalDamage < 0) finalDamage = 0;
          bool attackProceeded = unit.attackTarget(currentTarget, finalDamage);

          if (attackProceeded) {
            List<Unit> targets = [currentTarget];

            if (unit.stats.beastRiderCleavePercent > 0) {
              List<Unit> adjacentEnemies = _findAdjacentEnemies(
                currentTarget,
                enemies,
              );
              if (adjacentEnemies.isNotEmpty) {
                targets.addAll(adjacentEnemies);
              }
            }

            if (unit.stats.beastRiderCleavePercent > 0 && targets.length > 1) {
              _applyDamageToTargets(
                unit,
                [currentTarget],
                finalDamage,
                DamageType.physical,
              );

              double cleaveDamage =
                  finalDamage * unit.stats.beastRiderCleavePercent;
              List<Unit> cleaveTargets =
                  targets.where((t) => t.id != currentTarget?.id).toList();
              if (cleaveTargets.isNotEmpty) {
                _applyDamageToTargets(
                  unit,
                  cleaveTargets,
                  cleaveDamage,
                  DamageType.physical,
                );
              }
            }

            _handleAttackLanded(unit, currentTarget);

            if (!currentTarget.isAlive) {}

            unit.timeUntilNextAttack = 1.0 / unit.stats.attackSpeed;
          }
        }
      } else {
        unit.movementProgress += dt;

        _processMovement(unit, currentTarget);
      }
    }

    bool playerTeamAlive = _playerUnits.any((u) => u.isAlive);
    bool enemyTeamAlive = _enemyUnits.any((u) => u.isAlive);

    if (!playerTeamAlive || !enemyTeamAlive) {
      finishCombat(playerTeamAlive);
    }

    if (_state == CombatState.running) {
      notifyListeners();
    }
  }

  // Adds a passive effect like DoT
  void addCombatEffect(CombatEffect effect) {
    _activeEffects.add(effect);
  }

  // Handles movement logic for a unit trying to path to a target
  void _processMovement(Unit unit, Unit target) {
    double speed = unit.stats.movementSpeed;
    if (speed <= 0) return;

    while (unit.isAlive && unit.currentTargetId != null) {
      int currentX = unit.boardX;
      int currentY = unit.boardY;

      int distance = BoardManager.calculateDistance(unit, target);
      if (distance <= unit.stats.range) {
        unit.movementProgress = 0.0;
        break;
      }

      Position? bestMove = _findBestMove(unit, target);
      if (bestMove == null) {
        unit.movementProgress = 0.0;
        break;
      }

      bool isDiagonal = (bestMove.col != currentX && bestMove.row != currentY);
      double timeForStep = (isDiagonal ? 1.5 : 1.0) / speed;

      if (unit.movementProgress >= timeForStep) {
        unit.movementProgress -= timeForStep;
        bool moved = boardManager.moveUnitOnBoard(unit, bestMove);
        if (moved) {
          Unit? updatedTarget = findUnitInstanceById(target.id);
          if (updatedTarget == null || !updatedTarget.isAlive) {
            break;
          }
          target = updatedTarget;
        } else {
          unit.movementProgress = 0.0;
          break;
        }
      } else {
        break;
      }
    }
  }

  // Finds the optimal move location to approach the target
  Position? _findBestMove(Unit unit, Unit target) {
    if (!unit.isOnBoard || !target.isOnBoard) return null;

    int currentX = unit.boardX;
    int currentY = unit.boardY;
    int targetX = target.boardX;
    int targetY = target.boardY;

    List<Position> neighbors = [];
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        neighbors.add(Position(currentY + dy, currentX + dx));
      }
    }

    List<Position> validMoves =
        neighbors
            .where(
              (pos) =>
                  boardManager.isValidBoardPosition(pos) &&
                  boardManager.getUnitAt(pos) == null,
            )
            .toList();

    if (validMoves.isEmpty) {
      return null;
    }

    Position? bestMove;
    int minDistance = -1;

    for (Position move in validMoves) {
      int dist = BoardManager.calculateDistanceCoords(
        move.col,
        move.row,
        targetX,
        targetY,
      );

      if (bestMove == null || dist < minDistance) {
        minDistance = dist;
        bestMove = move;
      } else if (dist == minDistance) {
        bool currentBestIsDiagonal =
            (bestMove.col != currentX && bestMove.row != currentY);
        bool newMoveIsDiagonal = (move.col != currentX && move.row != currentY);
        if (!newMoveIsDiagonal && currentBestIsDiagonal) {
          bestMove = move;
        } else if (newMoveIsDiagonal && !currentBestIsDiagonal) {
        } else {
          if (Random().nextBool()) {
            bestMove = move;
          }
        }
      }
    }

    return bestMove;
  }

  // Applies damage to a group of targets and handles lifesteal + effects
  void _applyDamageToTargets(
    Unit attacker,
    List<Unit> targets,
    double damageAmount,
    DamageType type,
  ) {
    if (damageAmount <= 0) return;

    Set<String> hitTargetIds = {};

    for (var target in targets) {
      if (!target.isAlive || hitTargetIds.contains(target.id)) continue;
      hitTargetIds.add(target.id);

      if (target.hasSkyguardEvasion && target.skyguardEvasionTimer > 0) {
        if (attacker.stats.range <= 1) {
          continue;
        }
      }

      double damageToApply = damageAmount;
      if (target.appliesBattlemageDebuff) {
        damageToApply *= 0.7;
      }

      damageToApply *= (1.0 - target.stats.damageReduction);

      target.takeDamage(damageToApply, attacker, type);

      if (!target.isAlive) {
        boardManager.remove(target);
      }
    }
  }

  // Called whenever a unit lands a basic attack on another
  void _handleAttackLanded(Unit attacker, Unit target) {
    _unitAttackCounters[attacker.id] =
        (_unitAttackCounters[attacker.id] ?? 0) + 1;

    int currentAttackCount = _unitAttackCounters[attacker.id] ?? 0;
    if (currentAttackCount > 0 && currentAttackCount % 5 == 0) {
      _applyArtilleristAoE(attacker, target);
    }
  }

  // Applies AoE damage around target if attacker is an Artillerist
  void _applyArtilleristAoE(Unit attacker, Unit primaryTarget) {
    double bonusDamagePercent = attacker.stats.artilleristBonusDamagePercent;
    if (bonusDamagePercent <= 0) return;

    double bonusDamage = attacker.stats.attackDamage * bonusDamagePercent;

    List<Unit> enemiesToHit = [primaryTarget];
    List<Unit> enemyTeam =
        (_playerUnits.contains(primaryTarget)) ? _playerUnits : _enemyUnits;
    if (!primaryTarget.isOnBoard) {
    } else {
      int targetX = primaryTarget.boardX;
      int targetY = primaryTarget.boardY;

      for (var potentialTarget in enemyTeam) {
        if (potentialTarget.id == primaryTarget.id ||
            !potentialTarget.isAlive ||
            !potentialTarget.isOnBoard) {
          continue;
        }

        int dx = (potentialTarget.boardX - targetX).abs();
        int dy = (potentialTarget.boardY - targetY).abs();

        if (dx <= 1 && dy <= 1) {
          if (!enemiesToHit.any((u) => u.id == potentialTarget.id)) {
            enemiesToHit.add(potentialTarget);
          }
        }
      }
    }

    for (var enemy in enemiesToHit) {
      enemy.takeDamage(bonusDamage, attacker, DamageType.physical);
    }
  }

  // Returns a reference to a unit in combat by ID
  Unit? findUnitInstanceById(String unitId) {
    try {
      return _playerUnits.firstWhere((u) => u.id == unitId);
    } catch (e) {
      try {
        return _enemyUnits.firstWhere((u) => u.id == unitId);
      } catch (e) {
        return null;
      }
    }
  }

  // Ends combat and cleans up summoned units and state
  void finishCombat(bool playerWon) {
    if (_state != CombatState.running) return;

    _activeTimedEffects.clear();
    _state = CombatState.finished;
    _activeEffects.clear();

    _playerUnits.removeWhere((u) {
      if (u is SummonedUnit) {
        boardManager.remove(u);
        return true;
      }
      return false;
    });

    _enemyUnits.removeWhere((u) {
      if (u is SummonedUnit) {
        boardManager.remove(u);
        return true;
      }
      return false;
    });

    notifyListeners();
  }

  // Resets all combat state for a fresh round
  void reset() {
    _combatTimer?.cancel();
    _playerUnits.clear();
    _enemyUnits.clear();
    _activeEffects.clear();
    _unitAttackCounters.clear();
    _combatTime = Duration.zero;
    _state = CombatState.idle;
    notifyListeners();
  }
}
