import 'package:flutter/foundation.dart';
import 'unit.dart';
import 'game_manager.dart';
import 'item.dart';
import 'dart:math';
import '../game_data/items.dart';
import 'board_manager.dart';
import 'combat_manager.dart';
import 'board_position.dart';
import 'package:realm_of_tactics/models/summoned_unit.dart';

// Model for synergy tier data (how many units needed, description, and bonus value)
class SynergyTier {
  final int unitsRequired;
  final String description;
  final double bonusValue;

  const SynergyTier({
    required this.unitsRequired,
    required this.description,
    required this.bonusValue,
  });
}

// Represents a synergy, including its name, type (class/origin), and required tier breakpoints
class Synergy {
  final String name;
  final String type;
  final List<int> tiers;

  const Synergy({required this.name, required this.type, required this.tiers});
}

// Main class responsible for calculating and managing active synergies
class SynergyManager extends ChangeNotifier {
  // Singleton instance for global access
  static final SynergyManager _instance = SynergyManager._internal();

  // Factory constructor returns the singleton instance
  factory SynergyManager() => _instance;

  // References to game manager and currently spawned Ironvale summon units
  GameManager? _gameManager;
  Unit? _playerIronvaleSummon;
  Unit? _enemyIronvaleSummon;

  // Internal constructor for singleton setup
  SynergyManager._internal();

  // List of all synergies in the game
  final List<Synergy> _synergies = [];

  // Active synergy tracking by class and origin counts
  final Map<String, int> _activeClassCounts = {};
  final Map<String, int> _activeOriginCounts = {};
  Set<String> _activeSynergiesSet = {};

  final Map<String, (int count, int nextThreshold)> _activeSynergies = {};

  Set<String> _appliedOneTimeBonuses = {};

  final Map<String, int> _activeSynergyTiers = {};

  final Map<String, int> _synergyCounts = {};

  final List<Unit> _activeForgeheartUnits = [];
  final List<Item> _activeForgedItems = [];
  List<String> _availableForgedItemKeys = [];
  List<String> _predeterminedForgedItemKeys = [];
  final Random _random = Random();

  static const List<String> oneTimeBonusSynergies = [
    'Forgeheart',
    'Chronospark',
    'Greendale',
    'Ironvale',
    'Rifleman',
    'Scout',
    'Cleric',
    'Artillerist',
    'Battlemage',
    'Skyguard',
    'Deeprock',
    'Ironhide',
    'Emberhill',
  ];

  static const List<String> startOfCombatSynergies = [
    'Stormpeak',
    'Ironvale',
    'Frostward',
    'Stoneborn',
    'Tank',
    'Knight',
    'Engineer',
    'Spellblade',
    'Runesmith',
    'Defender',
    'Beast Rider',
    'Runebound',
  ];

  List<Synergy> get synergies => _synergies;
  Map<String, (int count, int nextThreshold)> get activeSynergies =>
      Map.unmodifiable(_activeSynergies);
  Set<String> get activeSynergiesSet => _activeSynergiesSet;
  Map<String, int> get synergyCounts => Map.unmodifiable(_synergyCounts);

  bool _isUpdatingSynergies = false;

  final Set<String> _unitsGrantedForgeheartItems = {};

  // Initializes all synergy definitions and prepares forged item pool
  void initialize() {
    _initializeSynergies();

    _availableForgedItemKeys = [
      'forged_zephyr_blade',
      'forged_archmage_staff',
      'forged_spirit_helm',
      'forged_guardian_plate',
      'forged_bloodthirst_locket',
      'forged_jeweled_scope',
    ];

    _determinePredeterminedForgedItems();
    _activeForgedItems.clear();
  }

  // Populates allSynergies with predefined origin and class synergy data
  void _initializeSynergies() {
    _synergies.addAll([
      const Synergy(name: 'Frostward', type: 'Origin', tiers: [2, 4, 6, 8]),
      const Synergy(name: 'Stormpeak', type: 'Origin', tiers: [3, 5, 7]),
      const Synergy(name: 'Runebound', type: 'Origin', tiers: [2, 4, 6]),
      const Synergy(name: 'Emberhill', type: 'Origin', tiers: [2, 4, 6]),
      const Synergy(name: 'Ironvale', type: 'Origin', tiers: [2, 4, 6]),
      const Synergy(name: 'Greendale', type: 'Origin', tiers: [2, 4, 5]),
      const Synergy(name: 'Chronospark', type: 'Origin', tiers: [2, 4]),
      const Synergy(name: 'Skyguard', type: 'Origin', tiers: [2, 3, 4]),
      const Synergy(name: 'Deeprock', type: 'Origin', tiers: [2, 4]),
      const Synergy(name: 'Stoneborn', type: 'Origin', tiers: [1, 2, 4]),
      const Synergy(name: 'Forgeheart', type: 'Origin', tiers: [1, 2, 3]),
      const Synergy(name: 'Ironhide', type: 'Origin', tiers: [2]),
    ]);

    _synergies.addAll([
      const Synergy(name: 'Defender', type: 'Class', tiers: [2, 4, 6]),
      const Synergy(name: 'Tank', type: 'Class', tiers: [2, 4, 6]),
      const Synergy(name: 'Beast Rider', type: 'Class', tiers: [1, 3, 5]),
      const Synergy(name: 'Knight', type: 'Class', tiers: [2, 4, 6]),
      const Synergy(name: 'Scout', type: 'Class', tiers: [2, 3, 4]),
      const Synergy(name: 'Spellblade', type: 'Class', tiers: [2, 4]),
      const Synergy(name: 'Battlemage', type: 'Class', tiers: [2, 4, 6]),
      const Synergy(name: 'Artillerist', type: 'Class', tiers: [2, 4]),
      const Synergy(name: 'Rifleman', type: 'Class', tiers: [2, 4]),
      const Synergy(name: 'Runesmith', type: 'Class', tiers: [1, 2, 3, 4, 5]),
      const Synergy(name: 'Cleric', type: 'Class', tiers: [2, 4]),
      const Synergy(name: 'Engineer', type: 'Class', tiers: [3, 6]),
    ]);
  }

  // Recalculates all active synergies based on current board units
  void updateSynergies([List<Unit>? activeUnits]) {
    if (_isUpdatingSynergies) {
      return;
    }

    bool isActiveCombat =
        _gameManager?.combatManager?.state == CombatState.running &&
        (_gameManager?.combatManager?.combatTime.inMilliseconds ?? 0) > 0;
    if (isActiveCombat) {
      return;
    }

    List<Unit> boardUnits =
        activeUnits ?? _gameManager!.boardManager!.getAllBoardUnits();

    List<Unit> playerUnits = boardUnits.where((unit) => !unit.isEnemy).toList();

    Map<String, int> newUnitCounts = {};
    for (var unit in boardUnits) {
      if (!unit.isSummon) {
        String key = unit.isEnemy ? "enemy_${unit.unitName}" : unit.unitName;
        newUnitCounts[key] = (newUnitCounts[key] ?? 0) + 1;
      }
    }

    bool shouldUpdate = false;

    for (var entry in newUnitCounts.entries) {
      if ((newUnitCounts[entry.key] ?? 0) != (_synergyCounts[entry.key] ?? 0)) {
        shouldUpdate = true;
        break;
      }
    }

    if (!shouldUpdate) {
      for (var entry in _synergyCounts.entries) {
        if ((newUnitCounts[entry.key] ?? 0) != entry.value) {
          shouldUpdate = true;
          break;
        }
      }
    }

    if (!shouldUpdate) {
      return;
    }

    _isUpdatingSynergies = true;

    try {
      Map<String, int> newPlayerSynergyCounts = {};
      Set<String> newActiveSynergiesSet = {};
      Map<String, int> newActiveSynergyTiers = {};

      for (var unit in boardUnits) {
        unapplySynergyEffectsFromUnit(unit);
      }

      _processTeamSynergies(
        playerUnits,
        newPlayerSynergyCounts,
        newActiveSynergiesSet,
        newActiveSynergyTiers,
      );

      _synergyCounts.clear();

      for (var entry in newPlayerSynergyCounts.entries) {
        _synergyCounts[entry.key] = entry.value;
      }

      _activeSynergiesSet = newActiveSynergiesSet;
      _activeSynergyTiers.clear();
      _activeSynergyTiers.addAll(newActiveSynergyTiers);

      notifyListeners();
    } finally {
      _isUpdatingSynergies = false;
    }
  }

  // Returns the synergy tier thresholds for a given synergy
  List<int> getSynergyThresholds(String synergyName) {
    final synergy = _synergies.firstWhere(
      (s) => s.name == synergyName,
      orElse: () => const Synergy(name: '', type: '', tiers: []),
    );
    return List<int>.from(synergy.tiers);
  }

  // Gets the player's synergy level for a given synergy name
  int getSynergyLevel(String synergy) {
    if (!_activeSynergiesSet.contains(synergy)) {
      return 0;
    }

    final synergyObj = _synergies.firstWhere(
      (s) => s.name == synergy,
      orElse: () => const Synergy(name: '', type: '', tiers: []),
    );
    final count = _synergyCounts[synergy] ?? 0;
    for (int i = synergyObj.tiers.length - 1; i >= 0; i--) {
      if (count >= synergyObj.tiers[i]) {
        return i + 1;
      }
    }

    return 0;
  }

  // Gets the enemy team's synergy level during combat
  int getEnemySynergyLevel(String synergyName, List<Unit> enemyUnits) {
    final synergy = _synergies.firstWhere(
      (s) => s.name == synergyName,
      orElse: () => const Synergy(name: '', type: '', tiers: []),
    );

    if (synergy.name.isEmpty) return 0;

    int count =
        enemyUnits
            .where(
              (unit) =>
                  !unit.isSummon &&
                  (unit.classes.contains(synergyName) ||
                      unit.origins.contains(synergyName)),
            )
            .length;

    for (int i = synergy.tiers.length - 1; i >= 0; i--) {
      if (count >= synergy.tiers[i]) {
        return i + 1;
      }
    }

    return 0;
  }

  void setGameManager(GameManager manager) {
    _gameManager = manager;
  }

  // Used for summoning synergy-specific units (Ironvale)
  void setCurrentIronvaleSummon(Unit? summon, {required bool isEnemy}) {
    if (isEnemy) {
      _enemyIronvaleSummon = summon;
    } else {
      _playerIronvaleSummon = summon;
    }
  }

  // Clears all synergy-related state, used after combat or game reset
  void reset() {
    _activeClassCounts.clear();
    _activeOriginCounts.clear();
    _synergyCounts.clear();
    _activeSynergiesSet.clear();
    _activeSynergies.clear();
    _playerIronvaleSummon = null;
    _enemyIronvaleSummon = null;
    _activeForgedItems.clear();
    _unitsGrantedForgeheartItems.clear();
    _activeForgedItems.clear();
    _activeForgeheartUnits.clear();
    _determinePredeterminedForgedItems();
    notifyListeners();
  }

  void _determinePredeterminedForgedItems() {
    List<String> shuffledKeys = List.from(_availableForgedItemKeys)
      ..shuffle(_random);
    _predeterminedForgedItemKeys = shuffledKeys.take(3).toList();
  }

  void applySynergyEffects(
    List<Unit> units,
    String synergyName,
    int tierValue,
  ) {
    if (oneTimeBonusSynergies.contains(synergyName)) {
      _applyOneTimeBonus(units, synergyName, tierValue);
    }
  }

  // Applies one-time synergy bonuses (like Chronospark or Forgeheart)
  void _applyOneTimeBonus(List<Unit> units, String synergyName, int tierValue) {
    List<Unit> unitsCopy = List.from(units);

    for (var unit in unitsCopy) {
      if (unit.isSummon) continue;

      bool alreadyReceived = Set.from(_appliedOneTimeBonuses).contains(unit.id);

      if (alreadyReceived) {
        continue;
      }

      bool hasOrigin = unit.origins.contains(synergyName);
      bool hasClass = unit.classes.contains(synergyName);

      if (!hasOrigin && !hasClass) continue;

      switch (synergyName) {
        case 'Battlemage':
          if (unit.classes.contains('Battlemage')) {
            int apBonus = tierValue == 2 ? 20 : (tierValue == 4 ? 50 : 80);
            unit.stats.bonusAbilityPower += apBonus;
            unit.appliesBattlemageDebuff = true;
          }
          break;

        case 'Rifleman':
          if (unit.classes.contains('Rifleman')) {
            unit.stats.riflemanStackAmount = tierValue == 2 ? 5 : 10;
          }
          break;

        case 'Chronospark':
          if (unit.origins.contains('Chronospark')) {
            unit.appliesChronosparkHeal = true;
            unit.chronosparkHealInterval = tierValue == 4 ? 5.0 : 10.0;
            unit.chronosparkHealPercent = tierValue == 4 ? 0.10 : 0.05;
          }
          break;

        case 'Greendale':
          if (unit.origins.contains('Greendale')) {
            unit.appliesGreendaleGold = true;
          }
          break;

        case 'Forgeheart':
          if (synergyName == 'Forgeheart') {
            if (unit.origins.contains('Forgeheart')) {
              int defenseBonus =
                  tierValue == 1 ? 10 : (tierValue == 2 ? 20 : 30);
              unit.stats.bonusArmor += defenseBonus;
              unit.stats.bonusMagicResist += defenseBonus;

              if (!_activeForgeheartUnits.contains(unit)) {
                _activeForgeheartUnits.add(unit);

                int index = _activeForgeheartUnits.length - 1;

                if (index < _predeterminedForgedItemKeys.length) {
                  String itemKey = _predeterminedForgedItemKeys[index];
                  Item? forgedItem = allItems[itemKey]?.copyWith();

                  if (forgedItem != null && !unit.isEnemy) {
                    bool added = _gameManager!.addForgedItemToBench(forgedItem);
                    if (added) {
                      _activeForgedItems.add(forgedItem);
                    }
                  }
                }
              }
            }
          }

        case 'Scout':
          if (unit.classes.contains('Scout')) {
            double moveSpeedBonus =
                tierValue == 2 ? .25 : (tierValue == 3 ? .5 : 1);
            unit.stats.bonusMovementSpeedPercent += moveSpeedBonus;

            int specialAttackInterval =
                tierValue == 2 ? 8 : (tierValue == 3 ? 6 : 4);
            unit.stats.scoutSpecialAttackInterval = specialAttackInterval;
            unit.stats.hasScoutSpecialAttack = true;
          }
          break;

        case 'Cleric':
          if (unit.classes.contains('Cleric')) {
            unit.stats.bonusAbilityPower += tierValue;
          }
          break;

        case 'Artillerist':
          if (unit.classes.contains('Artillerist')) {
            double damagePercent =
                tierValue == 2 ? 0.5 : (tierValue == 4 ? 1.0 : 1.5);
            unit.stats.artilleristBonusDamagePercent = damagePercent;
          }
          break;

        case 'Beast Rider':
          if (unit.classes.contains('Beast Rider')) {
            unit.stats.bonusAttackDamage += tierValue;
          }
          break;

        case 'Ironvale':
          if (_gameManager == null) {
            break;
          }

          if (unit.origins.contains('Ironvale')) {
            unit.generateScrap = true;
          }
          break;

        case 'Skyguard':
          if (unit.origins.contains('Skyguard')) {
            double duration =
                tierValue == 2 ? 5.0 : (tierValue == 3 ? 10.0 : 15.0);
            unit.hasSkyguardEvasion = true;
            unit.skyguardEvasionDuration = duration;
            unit.skyguardEvasionTimer = duration;
          }
          break;

        case 'Deeprock':
          if (unit.origins.contains('Deeprock')) {
            int reductionAmount =
                tierValue == 2 ? 20 : (tierValue == 4 ? 30 : 40);
            unit.hasDeepRockStrike = true;
            unit.deeprockReductionAmount = reductionAmount;
          }
          break;

        case 'Ironhide':
          if (unit.origins.contains('Ironhide')) {
            unit.hasIronhideStun = true;
          }
          break;

        case 'Emberhill':
          if (unit.origins.contains('Emberhill')) {
            double damageAmpBonus =
                tierValue == 2
                    ? 0.05
                    : tierValue == 4
                    ? 0.10
                    : 0.15;
            unit.stats.bonusDamageAmp += damageAmpBonus;

            unit.hasEmberhillMovementBuff = true;
            unit.emberhillAttackSpeedBonus = damageAmpBonus;
            unit.lastPosition =
                unit.isOnBoard ? Position(unit.boardY, unit.boardX) : null;
          }
          break;
      }

      Set<String> updatedBonuses = Set.from(_appliedOneTimeBonuses)
        ..add(unit.id);
      _appliedOneTimeBonuses = updatedBonuses;

      unit.notifyListeners();
    }

    notifyListeners();
  }

  // Applies synergy effects like bonuses or spawn effects at combat start
  void applyStartOfCombatEffects(List<Unit> units) {
    for (var unit in units) {
      unit.stats.resetStartOfCombatStats();
    }

    List<Unit> playerUnits = units.where((unit) => !unit.isEnemy).toList();
    List<Unit> enemyUnits = units.where((unit) => unit.isEnemy).toList();

    Map<String, int> enemySynergyCounts = {};
    for (var unit in enemyUnits) {
      if (!unit.isSummon) {
        for (var unitClass in unit.classes) {
          enemySynergyCounts[unitClass] =
              (enemySynergyCounts[unitClass] ?? 0) + 1;
        }
        for (var origin in unit.origins) {
          enemySynergyCounts[origin] = (enemySynergyCounts[origin] ?? 0) + 1;
        }
      }
    }

    Set<String> appliedEnemySynergies = {};

    for (var synergy in _synergies) {
      if (oneTimeBonusSynergies.contains(synergy.name)) {
        final count = enemySynergyCounts[synergy.name] ?? 0;
        if (count > 0) {
          int? enemyActiveTier;
          for (var tier in synergy.tiers) {
            if (count >= tier) {
              enemyActiveTier = tier;
            }
          }

          if (enemyActiveTier != null) {
            _applyOneTimeBonus(enemyUnits, synergy.name, enemyActiveTier);
            appliedEnemySynergies.add(synergy.name);
          }
        }
      }
    }

    for (var synergyName in _activeSynergiesSet) {
      if (startOfCombatSynergies.contains(synergyName)) {
        final synergy = _synergies.firstWhere(
          (s) => s.name == synergyName,
          orElse: () => const Synergy(name: '', type: '', tiers: []),
        );

        if (synergy.name.isEmpty) continue;

        final playerCount =
            playerUnits
                .where(
                  (unit) =>
                      !unit.isSummon &&
                      (unit.classes.contains(synergyName) ||
                          unit.origins.contains(synergyName)),
                )
                .length;

        int? playerActiveTier;
        for (var tier in synergy.tiers) {
          if (playerCount >= tier) {
            playerActiveTier = tier;
          }
        }

        if (playerActiveTier != null) {
          _applyStartOfCombatEffect(playerUnits, synergyName, playerActiveTier);
        }
      }
    }

    for (var synergy in _synergies) {
      if (startOfCombatSynergies.contains(synergy.name)) {
        if (appliedEnemySynergies.contains(synergy.name)) {
          continue;
        }

        final count = enemySynergyCounts[synergy.name] ?? 0;
        if (count > 0) {
          int? enemyActiveTier;
          for (var tier in synergy.tiers) {
            if (count >= tier) {
              enemyActiveTier = tier;
            }
          }

          if (enemyActiveTier != null) {
            _applyStartOfCombatEffect(
              enemyUnits,
              synergy.name,
              enemyActiveTier,
            );
            appliedEnemySynergies.add(synergy.name);
          }
        }
      }
    }
  }

  // Applies stat bonuses or unit behavior modifications at the start of combat
  void _applyStartOfCombatEffect(
    List<Unit> units,
    String synergyName,
    int tierValue,
  ) {
    switch (synergyName) {
      case 'Runesmith':
        List<Unit> runesmiths =
            units
                .where(
                  (unit) =>
                      unit.classes.contains('Runesmith') && unit.isOnBoard,
                )
                .toList();

        for (var unit in units) {
          if (!unit.isOnBoard || unit.isSummon) continue;

          int adjacentRunesmiths = 0;
          for (var runesmith in runesmiths) {
            if (runesmith.id != unit.id) {
              int dx = (unit.boardX - runesmith.boardX).abs();
              int dy = (unit.boardY - runesmith.boardY).abs();
              if (dx <= 1 && dy <= 1) {
                adjacentRunesmiths++;
              }
            }
          }

          if (adjacentRunesmiths > 0) {
            int healthBonus = 100 * adjacentRunesmiths;
            int armorBonus = 10 * adjacentRunesmiths;
            int mrBonus = 10 * adjacentRunesmiths;
            int adBonus =
                (unit.stats.attackDamage * 0.1 * adjacentRunesmiths).floor();
            int apBonus = 10 * adjacentRunesmiths;
            double asBonus = 0.1 * adjacentRunesmiths;

            unit.stats.combatStartHealthBonus += healthBonus;
            unit.stats.combatStartArmorBonus += armorBonus;
            unit.stats.combatStartMagicResistBonus += mrBonus;
            unit.stats.combatStartAttackDamageBonus += adBonus;
            unit.stats.combatStartAbilityPowerBonus += apBonus;
            unit.stats.combatStartAttackSpeedBonus += asBonus;
          }
        }
        break;

      case 'Defender':
        int baseResist = tierValue == 2 ? 5 : (tierValue == 4 ? 15 : 25);

        for (var unit in units) {
          if (unit.isSummon) continue;

          int finalResist =
              unit.classes.contains('Defender') ? baseResist * 3 : baseResist;

          unit.stats.combatStartArmorBonus += finalResist;
          unit.stats.combatStartMagicResistBonus += finalResist;
        }
        break;

      case 'Tank':
        for (var unit in units) {
          if (unit.classes.contains('Tank')) {
            double healthPercent =
                tierValue == 2 ? 0.1 : (tierValue == 4 ? 0.2 : 0.4);
            int healthBonus = (unit.stats.maxHealth * healthPercent).floor();
            unit.stats.combatStartHealthBonus += healthBonus;

            double healthToAdConversion = 0.05;
            int tankAdBonus =
                (unit.stats.maxHealth * healthToAdConversion).floor();
            unit.stats.combatStartAttackDamageBonus += tankAdBonus;
          }
        }
        break;

      case 'Knight':
        for (var unit in units) {
          if (unit.classes.contains('Knight')) {
            double adPercent =
                tierValue == 2 ? 0.1 : (tierValue == 4 ? 0.2 : 0.3);
            int adBonus = (unit.stats.attackDamage * adPercent).floor();
            unit.stats.combatStartAttackDamageBonus += adBonus;

            double lifestealBonus =
                tierValue == 2 ? 0.05 : (tierValue == 4 ? 0.10 : 0.15);
            unit.stats.combatStartLifestealBonus += lifestealBonus;
          }
        }
        break;

      case 'Spellblade':
        for (var unit in units) {
          if (unit.classes.contains('Spellblade')) {
            double apToAdRatio = tierValue == 2 ? 1.0 : 0.5;
            int apToAdBonus = (unit.stats.abilityPower * apToAdRatio).floor();
            unit.stats.combatStartAttackDamageBonus += apToAdBonus;
          }
        }
        break;

      case 'Frostward':
        Map<Unit, List<Unit>> adjacentFrostwardUnits = {};

        List<Unit> frostwardUnits =
            units.where((unit) => unit.origins.contains('Frostward')).toList();

        for (var unit in frostwardUnits) {
          List<Unit> adjacentAllies = [];
          if (unit.isOnBoard) {
            for (var otherUnit in frostwardUnits) {
              if (unit != otherUnit && otherUnit.isOnBoard) {
                int rowDiff = (unit.boardY - otherUnit.boardY).abs();
                int colDiff = (unit.boardX - otherUnit.boardX).abs();
                if (rowDiff <= 1 &&
                    colDiff <= 1 &&
                    !(rowDiff == 0 && colDiff == 0)) {
                  adjacentAllies.add(otherUnit);
                }
              }
            }
          }
          adjacentFrostwardUnits[unit] = adjacentAllies;
        }

        for (var unit in frostwardUnits) {
          int adjacentCount = adjacentFrostwardUnits[unit]?.length ?? 0;

          int statBoost =
              tierValue == 2
                  ? 10
                  : (tierValue == 4 ? 15 : (tierValue == 6 ? 20 : 25));

          int armorBonus = statBoost * adjacentCount;
          int mrBonus = statBoost * adjacentCount;

          unit.stats.combatStartArmorBonus += armorBonus;
          unit.stats.combatStartMagicResistBonus += mrBonus;
        }
        break;

      case 'Stormpeak':
        for (var unit in units) {
          if (unit.origins.contains('Stormpeak')) {
            int totalArmor = unit.stats.armor;
            int totalMagicResist = unit.stats.magicResist;
            int totalAttackDamage = unit.stats.attackDamage;
            int totalAbilityPower = unit.stats.abilityPower;

            int healthBonus =
                ((totalArmor / 20.0) *
                        (tierValue == 3 ? 50 : (tierValue == 5 ? 100 : 150)))
                    .floor();

            double damageResistanceBonus =
                (totalMagicResist / 20.0) *
                (tierValue == 3 ? 0.01 : (tierValue == 5 ? 0.03 : 0.05));

            double attackSpeedBonus =
                (totalAttackDamage / 20.0) *
                (tierValue == 3 ? 0.01 : (tierValue == 5 ? 0.03 : 0.05));

            double manaOnAttackBonus =
                (totalAbilityPower / 20.0) *
                (tierValue == 3 ? 1 : (tierValue == 5 ? 2 : 3));

            unit.stats.combatStartHealthBonus += healthBonus;
            unit.stats.combatStartDamageResistanceBonus +=
                damageResistanceBonus;
            unit.stats.combatStartAttackSpeedBonus += attackSpeedBonus;
            unit.stats.combatStartManaOnAttackBonus += manaOnAttackBonus;
          }
        }
        break;

      case 'Stoneborn':
        for (var unit in units) {
          if (unit.origins.contains('Stoneborn')) {
            int adjacentAllies = _countSurroundingUnits(unit, units);
            if (adjacentAllies == 0) {
              double shieldPercent =
                  tierValue == 1
                      ? 0.20
                      : tierValue == 2
                      ? 0.40
                      : 0.60;
              int shieldAmount = (unit.stats.maxHealth * shieldPercent).round();
              unit.stats.currentShield += shieldAmount;
            }
          }
        }
        break;

      case 'Engineer':
        if (units[0].isEnemy) {
          SummonedUnit.setEngineerBonusEnemy(
            tierValue >= 6 ? 4 : (tierValue >= 3 ? 2 : 0),
          );
        } else {
          SummonedUnit.setEngineerBonusAlly(
            tierValue >= 6 ? 4 : (tierValue >= 3 ? 2 : 0),
          );
        }

        for (var unit in units) {
          if (unit is SummonedUnit && !unit.hasAppliedEngineerBonus) {
            unit.applyEngineerBonus();
          }
        }
        break;

      case 'Beast Rider':
        for (var unit in units) {
          if (unit.classes.contains('Beast Rider')) {
            double attackSpeedBonus =
                tierValue == 2 ? 0.2 : (tierValue == 4 ? 0.4 : 0.6);
            unit.stats.combatStartAttackSpeedBonus += attackSpeedBonus;

            unit.stats.beastRiderCleavePercent = 0.25;
          }
        }
        break;

      case 'Runebound':
        double multiplier = 0.2 * tierValue;

        for (var unit in units) {
          if (unit.origins.contains('Runebound')) {
            unit.stats.combatStartHealthBonus +=
                (unit.stats.itemMaxHealth * multiplier).floor();
            unit.stats.combatStartAttackDamageBonus +=
                (unit.stats.itemAttackDamage * multiplier).floor();
            unit.stats.combatStartArmorBonus +=
                (unit.stats.itemArmor * multiplier).floor();
            unit.stats.combatStartMagicResistBonus +=
                (unit.stats.itemMagicResist * multiplier).floor();
            unit.stats.combatStartAbilityPowerBonus +=
                (unit.stats.itemAbilityPower * multiplier).floor();
            unit.stats.combatStartAttackSpeedBonus +=
                unit.stats.itemAttackSpeed * multiplier;
          }
        }
        break;

      case 'Ironvale':
        final Unit? summon =
            units.first.isEnemy ? _enemyIronvaleSummon : _playerIronvaleSummon;

        if (summon != null) {
          int healthBonus = 5 * _gameManager!.ironvaleScrap;
          summon.stats.combatStartAttackDamageBonus +=
              1 * _gameManager!.ironvaleScrap;
          summon.stats.combatStartHealthBonus += healthBonus;
        }

        notifyListeners();
        break;
    }
  }

  int _countSurroundingUnits(Unit unit, List<Unit> allUnits) {
    if (!unit.isOnBoard) return 0;
    int count = 0;
    for (var other in allUnits) {
      if (other != unit && other.isOnBoard) {
        int distance = BoardManager.calculateDistance(unit, other);
        if (distance == 1) count++;
      }
    }
    return count;
  }

  void resetOneTimeBonuses() {
    _appliedOneTimeBonuses.clear();
  }

  // Handles awarding gold for units with the Greendale origin after combat
  void handleGreendaleGoldGeneration({bool didPlayerWin = true}) {
    if (_gameManager == null) return;

    int greendaleLevel = getSynergyLevel('Greendale');
    if (greendaleLevel == 0) return;

    int flagCount = 0;
    List<Unit> boardUnits = _gameManager!.boardManager!.getAllBoardUnits();
    for (var unit in boardUnits) {
      if (unit.appliesGreendaleGold) {
        flagCount++;
      }
    }

    int totalGold = flagCount;

    if (!didPlayerWin) {
      totalGold += greendaleLevel.clamp(1, 3);
    }

    if (totalGold > 0) {
      _gameManager!.addGold(totalGold);
    }
  }

  void unapplySynergyEffectsFromUnit(Unit unit) {
    _appliedOneTimeBonuses.remove(unit.id);

    unit.stats.resetBonusStats();

    if (_activeForgeheartUnits.contains(unit)) {
      _activeForgeheartUnits.remove(unit);

      if (_activeForgedItems.isNotEmpty) {
        final lastItem = _activeForgedItems.removeLast();
        _gameManager?.removeForgedItemFromUnit(unit, lastItem);
      }
    }
  }

  // Applies any currently active synergies to a single unit
  void applyActiveSynergiesToUnit(Unit unit) {
    if (_isUpdatingSynergies) {
      Future.microtask(() => applyActiveSynergiesToUnit(unit));
      return;
    }

    _isUpdatingSynergies = true;
    try {
      if (unit.isSummon) return;

      Map<String, int> activeSynergiesCopy = Map.from(_activeSynergyTiers);

      for (var entry in activeSynergiesCopy.entries) {
        String synergyName = entry.key;
        int tierValue = entry.value;

        bool hasOrigin = unit.origins.contains(synergyName);
        bool hasClass = unit.classes.contains(synergyName);

        if (hasOrigin || hasClass) {
          if (oneTimeBonusSynergies.contains(synergyName)) {
            _applyOneTimeBonus([unit], synergyName, tierValue);
          }
        }
      }
    } finally {
      _isUpdatingSynergies = false;
    }
  }

  // Main logic for checking which synergies are active and applying effects
  void _processTeamSynergies(
    List<Unit> units,
    Map<String, int> synergyCounts,
    Set<String> activeSynergiesSet,
    Map<String, int> activeSynergyTiers,
  ) {
    Map<String, Unit> uniqueUnits = {};

    for (var unit in units) {
      if (!unit.isSummon) {
        if (!uniqueUnits.containsKey(unit.unitName)) {
          uniqueUnits[unit.unitName] = unit;

          for (var unitClass in unit.classes) {
            synergyCounts[unitClass] = (synergyCounts[unitClass] ?? 0) + 1;
          }

          for (var origin in unit.origins) {
            synergyCounts[origin] = (synergyCounts[origin] ?? 0) + 1;
          }
        }
      }
    }

    Set<String> processedSynergies = {};
    for (var synergy in _synergies) {
      var count = synergyCounts[synergy.name] ?? 0;
      if (count > 0 && !processedSynergies.contains(synergy.name)) {
        int? activeTier;
        for (var tier in synergy.tiers) {
          if (count >= tier) {
            activeTier = tier;
          }
        }

        if (activeTier != null) {
          activeSynergiesSet.add(synergy.name);
          activeSynergyTiers[synergy.name] = activeTier;

          List<Unit> validUnits =
              units
                  .where(
                    (unit) =>
                        !unit.isSummon &&
                        (unit.classes.contains(synergy.name) ||
                            unit.origins.contains(synergy.name)),
                  )
                  .toList();

          if (validUnits.isNotEmpty) {
            applySynergyEffects(validUnits, synergy.name, activeTier);
          }

          processedSynergies.add(synergy.name);
        }
      }
    }
  }
}
