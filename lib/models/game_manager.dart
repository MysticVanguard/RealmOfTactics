import 'dart:async';
import 'package:realm_of_tactics/models/round_data.dart';

import 'board_manager.dart';
import 'synergy_manager.dart';
import 'combat_manager.dart';
import 'unit.dart';
import 'item.dart';
import 'shop_manager.dart';
import 'board_position.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../game_data/units.dart';
import '../game_data/items.dart';
import 'map_manager.dart';

// Core states the game transitions between
enum GameState { chooseStart, map, shopping, combat, postCombat, gameOver }

// Represents a selectable game opening
class StartOption {
  final String name;
  final String description;

  const StartOption({required this.name, required this.description});
}

// All possible starting presets for the player to choose from
final allStartOptions = [
  StartOption(
    name: "Basic Start",
    description: "Level 3, 2 XP, 15 gold, 3 items",
  ),
  StartOption(
    name: "High Tier",
    description: "Level 3, 2 XP, 5x 3-cost units, 2 items",
  ),
  StartOption(
    name: "Full Bench",
    description: "Level 4, 0 XP, 4x 2-cost, 4x 1-cost, 2 item",
  ),
  StartOption(name: "Max Gold", description: "Level 1, 0 XP, 41 gold"),
  StartOption(name: "Equipped", description: "Level 3, 2 XP, 5 items, 5 gold"),
  StartOption(
    name: "Champion",
    description: "Level 3, 0 XP, 1x 4-cost unit, 2 items, 12 gold",
  ),
  StartOption(
    name: "Leveled Up",
    description: "Level 5, 0 XP, 2x 2-cost units, 3 1-cost units",
  ),
];

// Singleton GameManager class – oversees game lifecycle, economy, board, shop, and combat flow
class GameManager extends ChangeNotifier {
  int overallMaxHealth = 0;
  int overallAttackDamage = 0;
  double overallAttackSpeed = 0.0;
  int overallArmor = 0;
  int overallMagicResist = 0;
  int overallAbilityPower = 0;
  int overallRange = 0;
  double overallCritChance = 0.0;
  double overallCritDamage = 0.0;
  double overallLifesteal = 0.0;
  double overallMovementSpeed = 0.0;
  int overallStartingMana = 0;
  double overallDamageAmp = 0.0;
  double overallDamageReduction = 0.0;

  // UI reference for board layout positioning
  GlobalKey? boardKey;
  // Board/bench/unit logic
  BoardManager? _boardManager;
  // Handles trait bonuses
  SynergyManager? _synergyManager;
  // Controls combat flow
  CombatManager? _combatManager;
  // Controls unit shop
  ShopManager? _shopManager;
  // Combat ticking interval
  Timer? _combatTickTimer;
  // For visual effects
  OverlayState? overlayState;
  // Needed for animations
  TickerProvider? overlayTicker;
  // Controls enemy team generation
  late final OpponentManager _opponentManager;
  // Controls the map and it's generation
  late final MapManager _mapManager;

  static GameManager? instance;
  List<Item> getBasicItems() {
    return allItems.values.where((item) => item.isComponent).toList();
  }

  GameManager() {
    GameManager.instance = this;
  }

  double? _tileSize;
  double? get tileSize => _tileSize;
  void setTileSize(double size) {
    _tileSize = size;
  }

  void initializeItemPool() {
    for (final item in allItems.values) {
      if (item.isComponent) {
        itemPool[item.id] = maxPerItem;
      }
    }
  }

  final Map<String, int> itemPool = {};
  final int maxPerItem = 4;

  // Optional tile size for rendering the board/grid
  void setBoardKey(GlobalKey key) {
    boardKey = key;
  }

  // Controls the current global game state
  GameState _currentState = GameState.chooseStart;

  // Starting options presented to the player
  List<StartOption> currentStartOptions = [];
  int startRerolls = 1;

  // Generates a fresh set of randomized starting options
  void offerStartOptions() {
    final shuffled = [...allStartOptions]..shuffle();
    currentStartOptions = shuffled.take(3).toList();
    notifyListeners();
  }

  // Player's persistent stats
  int _gold = 0;
  int _playerLevel = 1;
  int _playerHealth = 100;
  int _playerXp = 0;
  int _currentStage = 0;
  int _ironvaleScrap = 0;

  // UI and round transition helpers
  bool isDragging = false;
  final List<Unit> _nextRoundEnemies = [];
  final Map<String, Position> _initialPlayerPositions = {};
  List<Unit> _originalPlayerUnits = [];
  bool _isRoundPrepared = false;

  // How much XP is needed to reach each level
  static const Map<int, int> xpBreakpoints = {
    2: 2,
    3: 8,
    4: 10,
    5: 14,
    6: 24,
    7: 40,
    8: 52,
    9: 80,
    10: 88,
  };

  // Various global game getters
  GameState get currentState => _currentState;
  void setCurrentState(GameState state) {
    _currentState = state;
  }

  int get gold => _gold;
  int get playerGold => _gold;
  int get playerLevel => _playerLevel;
  int get playerHealth => _playerHealth;
  int get currentStage => _currentStage;
  int get playerXp => _playerXp;
  int get ironvaleScrap => _ironvaleScrap;
  int get expForNextLevel => 4;
  BoardManager? get boardManager => _boardManager;
  CombatManager? get combatManager => _combatManager;
  ShopManager? get shopManager => _shopManager;
  SynergyManager? get synergyManager => _synergyManager;
  List<Unit> get nextRoundEnemies => _nextRoundEnemies;
  MapManager get mapManager => _mapManager;

  // How much XP is needed to reach the next level
  int get xpForNextLevel {
    if (_playerLevel >= 10) return 0;
    return xpBreakpoints[_playerLevel + 1] ?? 0;
  }

  // Current progress toward the next level
  int get currentXpProgress {
    if (_playerLevel >= 10) return 0;

    return _playerXp;
  }

  // Injects dependencies into GameManager
  void setBoardManager(BoardManager manager) {
    _boardManager = manager;
  }

  void setSynergyManager(SynergyManager manager) {
    _synergyManager = manager;
  }

  void setCombatManager(CombatManager manager) {
    _combatManager = manager;
  }

  void setShopManager(ShopManager manager) {
    _shopManager = manager;
  }

  // If player has a reroll available, replace the start options
  void useStartReroll() {
    if (startRerolls > 0) {
      startRerolls--;
      offerStartOptions();
    }
  }

  // Advance state from start screen to shop phase
  void transitionToShopping() {
    _currentState = GameState.shopping;
    notifyListeners();
  }

  // Fully resets all major game values and initializes managers and systems
  void initialize() {
    _gold = 0;
    _playerLevel = 1;
    _playerHealth = 100;
    _currentStage = 1;
    _ironvaleScrap = 0;
    _nextRoundEnemies.clear();

    _combatManager?.reset();
    _combatTickTimer?.cancel();
    _combatTickTimer = null;

    _boardManager?.initialize();
    _shopManager?.initialize();
    _synergyManager?.initialize();

    if (_combatManager == null &&
        _boardManager != null &&
        _synergyManager != null) {
      _combatManager = CombatManager(
        boardManager: _boardManager!,
        synergyManager: _synergyManager!,
      );
    }

    initializeItemPool();

    _opponentManager = OpponentManager();
    _mapManager = MapManager()..generateMap();

    _currentState = GameState.chooseStart;
    startRerolls = 1;
    offerStartOptions();
    mapManager.offerBlessings();
    notifyListeners();
  }

  // Used to set a map node to selected if it's valid
  void chooseMapNode(MapNode node) {
    _mapManager.selectNode(node);
    notifyListeners();
  }

  // Enters a node, adding the rounds and moving to the prep phase
  void enterSelectedMapNode() {
    final node = _mapManager.selectedNode;
    if (node == null) return;

    _mapManager.enterSelectedNode();

    _currentState = GameState.shopping;
    _prepareNextRound();
    notifyListeners();
  }

  // Applies effects from the chosen starting setup
  void applyStartOption(String optionKey) {
    final gm = GameManager.instance!;

    gm.addGold(-gm.gold); // Reset gold to 0 before applying rewards

    switch (optionKey) {
      case "Basic Start":
        gm._playerLevel = 3;
        gm._playerXp = 2;
        gm.addGold(15);
        addRandomBasicItems(3);
        break;
      case "High Tier":
        gm._playerLevel = 3;
        gm._playerXp = 2;
        gm.addGold(0);
        addRandomUnitsToBench(3, 5);
        addRandomBasicItems(2);
        break;
      case "Full Bench":
        gm._playerLevel = 4;
        gm._playerXp = 0;
        gm.addGold(0);
        addRandomUnitsToBench(2, 4);
        addRandomUnitsToBench(1, 4);
        addRandomBasicItems(2);
        break;
      case "Max Gold":
        gm._playerLevel = 1;
        gm._playerXp = 0;
        gm.addGold(41);
        break;
      case "Equipped":
        gm._playerLevel = 3;
        gm._playerXp = 2;
        gm.addGold(5);
        addRandomBasicItems(5);
        break;
      case "Champion":
        gm._playerLevel = 3;
        gm._playerXp = 0;
        gm.addGold(12);
        addRandomUnitsToBench(4, 1);
        addRandomBasicItems(2);
        break;
      case "Leveled Up":
        gm._playerLevel = 5;
        gm._playerXp = 0;
        gm.addGold(0);
        addRandomUnitsToBench(2, 2);
        addRandomUnitsToBench(1, 3);
        break;
    }

    _mapManager.generateMap();
    _currentState = GameState.map;
    gm.notifyListeners();
  }

  // Filters the master unit list by cost value
  List<Unit> getUnitsByCost(int cost) {
    return unitData.values.where((unit) => unit.cost == cost).toList();
  }

  // Pulls a random unit of a certain cost
  Unit getRandomUnitByCost(int cost) {
    final matching = getUnitsByCost(cost);
    if (matching.isEmpty) {
      throw Exception("No units found for cost $cost");
    }

    final rand = Random();
    final unitTemplate = matching[rand.nextInt(matching.length)];
    return unitTemplate.copyWith(
      id:
          '${unitTemplate.unitName}_${DateTime.now().millisecondsSinceEpoch}_${rand.nextInt(10000)}',
    );
  }

  // Adds several random units of a given cost to the player's bench
  void addRandomUnitsToBench(int cost, int count) {
    for (int i = 0; i < count; i++) {
      final unit = getRandomUnitByCost(cost);
      boardManager!.addUnitToBench(unit);
    }
  }

  // Selects a random base-level item from the component list
  Item getRandomBasicItem() {
    print(itemPool.entries);
    final poolEntries =
        itemPool.entries
            .where((e) => allItems.containsKey(e.key) && e.value > 0)
            .toList();
    print(poolEntries);
    if (poolEntries.isEmpty) {
      final basicItems = getBasicItems();
      if (basicItems.isEmpty) throw Exception("No tier 1 items found");

      final randomItem = basicItems[Random().nextInt(basicItems.length)];
      return randomItem.copyWith();
    }

    final weightedList = <String>[];
    for (final entry in poolEntries) {
      weightedList.addAll(List.filled(entry.value, entry.key));
    }
    final rand = Random();
    final selectedItemId = weightedList[rand.nextInt(weightedList.length)];

    itemPool[selectedItemId] = itemPool[selectedItemId]! - 1;

    return allItems[selectedItemId]!.copyWith();
  }

  Item getRandomItemByTier(int tier) {
    final matchingItems =
        allItems.values.where((item) => item.tier == tier).toList();
    if (matchingItems.isEmpty) throw Exception("No tier $tier items found");

    final rand = Random();
    return matchingItems[rand.nextInt(matchingItems.length)].copyWith();
  }

  // Adds random basic (tier 1) items to the bench
  void addRandomBasicItems(int count) {
    for (int i = 0; i < count; i++) {
      boardManager!.addItemToBench(getRandomBasicItem());
    }
  }

  // Adds gold and notifies listeners
  void addGold(int amount) {
    _gold += amount;
    notifyListeners();
  }

  void addHealth(int amount) {
    _playerHealth += amount;
  }

  // Tries to spend gold; returns true if successful
  bool spendGold(int amount) {
    if (_gold >= amount) {
      _gold -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Adds XP and checks for level up
  void addXp(int amount) {
    if (_playerLevel >= 10) return;

    _playerXp += amount;

    checkAndApplyLevelUp();

    notifyListeners();
  }

  // Applies level-ups based on XP thresholds
  void checkAndApplyLevelUp() {
    bool levelChanged = false;

    while (_playerLevel < 10) {
      int? neededXp = xpBreakpoints[_playerLevel + 1];
      if (neededXp == null || _playerXp < neededXp) break;

      _playerXp -= neededXp;
      _playerLevel++;
      levelChanged = true;
    }

    if (levelChanged) {
      notifyListeners();
    }
  }

  // Buys XP if the player has enough gold
  bool levelUp() {
    if (_playerLevel >= 10) return false;

    if (spendGold(4)) {
      addXp(4);
      return true;
    }
    return false;
  }

  // Deducts unit cost and adds unit to bench (called by shop)
  bool purchaseUnit(Unit unit) {
    if (_gold < unit.cost) {
      return false;
    }

    _gold -= unit.cost;
    notifyListeners();

    return true;
  }

  // Starts a combat round if in shopping phase
  void startCombatRound() {
    if (_currentState != GameState.shopping) return;

    if (!_isRoundPrepared) return;

    _isRoundPrepared = false;

    _currentState = GameState.combat;
    notifyListeners();

    _initialPlayerPositions.clear();
    List<Unit> playerUnits = _boardManager!.getAllBoardUnits();
    _originalPlayerUnits = List.from(playerUnits);
    for (var unit in playerUnits) {
      _initialPlayerPositions[unit.id] = Position(unit.boardY, unit.boardX);
    }

    final enemies = List<Unit>.from(_nextRoundEnemies);

    for (var unit in enemies) {
      unit.isEnemy = true;
      unit.team = 1;
      unit.isOnBoard = true;
    }

    _combatManager!.startCombat(_originalPlayerUnits, enemies);
    _startCombatTimer();
  }

  // Begins a timer that advances combat each tick
  void _startCombatTimer() {
    _combatTickTimer?.cancel();
    _combatTickTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (_currentState != GameState.combat) {
        timer.cancel();
        return;
      }

      _combatManager!.tick(const Duration(milliseconds: 100));

      if (_combatManager!.state == CombatState.finished) {
        _finishCombatRound();
      }
    });
  }

  // Triggers a visual attack effect (projectile or melee)
  void playAttackEffect(Unit attacker, Unit target) {
    final rangedSprite = combatManager!.getRangedEffectSprite(
      attacker.unitName,
    );
    final meleeSprite = combatManager!.getMeleeEffectSprite(attacker.unitName);
    if (rangedSprite != null) {
      showProjectileEffectFollowing(
        from: boardTileToScreenOffset(
          attacker.boardY,
          attacker.boardX,
          tileSize!,
          "ranged",
        ),
        target: target,
        imagePath: rangedSprite,
      );
    } else if (meleeSprite != null) {
      showEffectOnUnit(target: target, imagePath: meleeSprite);
    }
  }

  // Called when combat round ends to process win/loss results
  void _finishCombatRound() {
    _combatTickTimer?.cancel();
    _combatTickTimer = null;

    if (_currentState != GameState.combat) return;

    bool playerWon = _combatManager!.enemyUnits.every((u) => !u.isAlive);

    _currentState = GameState.postCombat;
    notifyListeners();

    _handlePostCombat(playerWon);

    for (var unit in _boardManager!.getAllBoardUnits()) {
      unit.stats.resetStartOfCombatStats();
      final equippedItems = unit.getEquippedItems();
      for (final item in equippedItems) {
        if (item.tier == 3 && synergyManager!.forgedItems.contains(item)) {
          unit.unequipItem(item.type);
        }
      }
      if (unit.isAlive) {
        unit.stats.currentHealth = unit.stats.maxHealth;
      }
    }

    Future.delayed(Duration(seconds: 1), () {
      if (_currentState == GameState.postCombat) {
        if (_playerHealth > 0) {
          final currentNode = mapManager.currentNode;

          if (currentNode != null && currentNode.rounds.isNotEmpty) {
            _prepareNextRound();
            _currentState = GameState.shopping;
          } else {
            if (currentNode != null) {
              if (currentNode.rewardGold > 0) {
                GameManager.instance!.addGold(currentNode.rewardGold);
              }

              for (final item in currentNode.rewardItems) {
                GameManager.instance!.boardManager!.addItemToBench(
                  item.copyWith(),
                );
              }

              for (final unit in currentNode.rewardUnits) {
                GameManager.instance!.boardManager!.addUnitToBench(
                  unit.copyWith(),
                );
              }
            }
            _currentState = GameState.map;
          }

          _boardManager?.resetBoardPositions(
            _originalPlayerUnits,
            _initialPlayerPositions,
          );
        } else {
          _currentState = GameState.gameOver;
        }
        notifyListeners();
      }
    });
  }

  // Handles player win/loss, scrap, repositioning, gold
  void _handlePostCombat(bool playerWon) {
    if (_boardManager == null) return;

    _currentStage++;
    _addRoundIncome();

    addXp(2);

    if (playerWon) {
      _gold += 1;
    } else {
      int damage = 2 + (_currentStage ~/ 3) + max(5 * _currentStage - 55, 0);
      if (mapManager.currentNode?.type == MapNodeType.elite) {
        damage *= 2;
      }
      _playerHealth -= damage;
    }

    if (_playerHealth <= 0) {
      _playerHealth = 0;
      _currentState = GameState.gameOver;
    }
  }

  int maxInterest = 5;
  // Adds base round income and interest from banked gold
  void _addRoundIncome() {
    int income = 5;

    int interest = (_gold / 10).floor();
    if (interest > maxInterest) interest = maxInterest;

    _gold += income + interest;
  }

  // Resets the entire game state
  void resetGame() {
    _combatTickTimer?.cancel();
    _combatTickTimer = null;
    _playerHealth = 100;
    _gold = 0;
    _playerLevel = 1;
    _playerXp = 0;
    _currentStage = 1;
    _ironvaleScrap = 0;
    _currentState = GameState.shopping;

    _boardManager?.initialize();
    _synergyManager?.reset();
    _combatManager?.reset();

    notifyListeners();
  }

  // Called at the end of post-combat to prepare units and shop for next round
  void _prepareNextRound() {
    _refreshShop();

    _boardManager?.resetBoard();

    for (var unit in _originalPlayerUnits) {
      var position = _initialPlayerPositions[unit.id];
      if (position != null) {
        unit.isOnBoard = true;
        unit.boardX = position.col;
        unit.boardY = position.row;
        _boardManager?.placeUnit(unit, position);
      }
    }

    final currentNode = mapManager.currentNode;
    if (currentNode == null) return;

    if (currentNode.rounds.isEmpty) {
      _currentState = GameState.map;
      notifyListeners();
      return;
    }

    final roundUnits = currentNode.rounds.removeAt(0);
    final enemyTeam = _opponentManager.createUnitsFromList(roundUnits);
    _isRoundPrepared = true;

    _nextRoundEnemies.clear();

    for (var unit in enemyTeam) {
      var position = unit.position;

      unit.isEnemy = true;
      unit.team = 1;
      unit.boardX = position.col;
      unit.boardY = position.row;
      unit.isOnBoard = true;

      _nextRoundEnemies.add(unit);
    }

    int ironvaleLevel = _synergyManager?.getSynergyLevel('Ironvale') ?? 0;
    if (ironvaleLevel > 0) {
      int scrapGained = 0;
      List<Unit> boardUnits = _boardManager!.getAllBoardUnits();
      for (var unit in boardUnits) {
        if (unit.origins.contains('Ironvale') && unit.stats.generateScrap) {
          scrapGained += unit.tier;
        }
      }
      if (scrapGained > 0) {
        _ironvaleScrap += scrapGained;
      }
    }

    notifyListeners();
  }

  // Getter for all player and enemy units during combat
  List<Unit> get allUnitsInCombat {
    List<Unit> units = [];
    if (_combatManager != null) {
      units.addAll(_combatManager!.playerUnits);
      units.addAll(_combatManager!.enemyUnits);
    }
    return units;
  }

  set ironvaleScrap(int newScrap) {
    _ironvaleScrap = newScrap;
  }

  // Searches combat units by ID
  Unit? findUnitById(String id) {
    if (_combatManager == null) return null;

    try {
      return allUnitsInCombat.firstWhere(
        (unit) => unit.id == id,
        orElse: () => throw Exception('Unit not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Refreshes the shop manually
  void _refreshShop() {
    _shopManager?.refreshShop();
  }

  // Launches a projectile effect from attacker to target
  void showProjectileEffectFollowing({
    required Offset from,
    required Unit target,
    required String imagePath,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: duration,
          onEnd: () => entry.remove(),
          builder: (context, value, child) {
            final gm = GameManager.instance!;
            final tileSize = gm.tileSize ?? 48.0;

            final to = gm.boardTileToScreenOffset(
              target.boardY,
              target.boardX,
              tileSize,
              "ranged",
            );

            final currentX = from.dx + (to.dx - from.dx) * value;
            final currentY = from.dy + (to.dy - from.dy) * value;
            final angle = atan2(to.dy - from.dy, to.dx - from.dx);

            return Positioned(
              left: currentX,
              top: currentY,
              child: Transform.rotate(
                angle: angle,
                child: Image.asset(imagePath, width: 24, height: 24),
              ),
            );
          },
        );
      },
    );

    GameManager.instance!.overlayState!.insert(entry);
  }

  // Displays an effect (like an animation or sprite) on a specific unit
  void showEffectOnUnit({
    required Unit target,
    required String imagePath,
    Duration? duration,
  }) {
    final entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: target,
          builder: (context, _) {
            final tileSize = GameManager.instance!.tileSize;
            final pos = GameManager.instance!.boardTileToScreenOffset(
              target.boardY,
              target.boardX,
              tileSize!,
              "effect",
            );

            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: Image.asset(imagePath, width: tileSize, height: tileSize),
            );
          },
        );
      },
    );

    GameManager.instance!.overlayState!.insert(entry);

    Future.delayed(duration ?? Duration(milliseconds: 500), () {
      entry.remove();
    });
  }

  // Converts a tile coordinate into a global screen position
  Offset boardTileToScreenOffset(
    int row,
    int col,
    double tileSize,
    String type,
  ) {
    if (boardKey == null) {
      return Offset.zero;
    }

    final context = boardKey!.currentContext;
    if (context == null) {
      return Offset.zero;
    }

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return Offset.zero;
    }

    final boardTopLeft = box.localToGlobal(Offset.zero);
    if (type == "ranged") {
      return Offset(
        boardTopLeft.dx + col * tileSize + tileSize / 2,
        boardTopLeft.dy + row * tileSize + tileSize / 2,
      );
    } else {
      return Offset(
        boardTopLeft.dx + col * tileSize,
        boardTopLeft.dy + row * tileSize,
      );
    }
  }

  // Finds if the player owns a unit at the max tier
  bool hasReachedMaxTier(String unitName) {
    if (boardManager != null) {
      int maxTier = 3;
      for (var unit in [
        ...boardManager!.getAllBenchUnits(),
        ...boardManager!.getAllBoardUnits(),
      ]) {
        if (unit.unitName == unitName &&
            unit.tier >= maxTier &&
            !unit.isEnemy) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  void applyItemBonus(ItemStatsBonus bonus) {
    overallMaxHealth += bonus.bonusMaxHealth.floor();

    overallAttackDamage += bonus.bonusAttackDamage.floor();
    overallAttackSpeed += bonus.bonusAttackSpeed;
    overallArmor += bonus.bonusArmor.floor();
    overallMagicResist += bonus.bonusMagicResist.floor();
    overallAbilityPower += bonus.bonusAbilityPower.floor();
    overallCritChance += bonus.bonusCritChance;
    overallCritDamage += bonus.bonusCritDamage;
    overallStartingMana += bonus.bonusStartingMana;
    overallLifesteal += bonus.bonusLifesteal;
    overallDamageAmp += bonus.bonusDamageAmp;
    overallDamageReduction += bonus.bonusDamageReduction;
    overallRange += bonus.bonusRange;
    overallAttackSpeed += bonus.bonusAttackSpeedPercent;
  }
}
