import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:realm_of_tactics/models/blessing_data.dart';
import 'package:realm_of_tactics/models/game_manager.dart';
import 'package:realm_of_tactics/models/item.dart';
import 'package:realm_of_tactics/models/round_data.dart';
import 'package:realm_of_tactics/models/unit.dart';

// Types of nodes on the map
enum MapNodeType { start, combat, elite, rest, blessing, boss }

// A map node for the displayed map, has the level of the map
// as the floor, the index as the x, it's type, what it's connected
// to, and the rounds it includes (only relevant for combat and elite)
class MapNode {
  final int floor;
  final int index;
  MapNodeType type;
  final List<MapNode> connections = [];
  List<List<UnitData>> rounds;
  String rewardDescription = '';
  int rewardGold = 0;
  int rewardItemReforgeTokens = 0;
  int rewardUnitSmallDuplicators = 0;
  int rewardUnitLargeDuplicators = 0;
  List<Item> rewardItems = [];
  List<Unit> rewardUnits = [];

  MapNode({
    required this.floor,
    required this.index,
    required this.type,
    required this.rounds,
  });

  bool isConnectedTo(MapNode other) => connections.contains(other);
}

class MapManager extends ChangeNotifier {
  // Map dimensions
  static const int totalFloors = 16;
  static const int nodesPerFloor = 9;
  static const int roundsPerNode = 5;

  List<String> playerBlessings = [];
  int _blessingRerolls = 1;
  int get blessingRerolls => _blessingRerolls;
  int _blessingsChosen = 0;
  List<String> currentBlessingOptions = [];
  List<int> tierOrder = [1, 2, 3]..shuffle();

  final List<List<MapNode>> _map = List.generate(totalFloors, (_) => []);

  // Special nodes need tracked of
  MapNode? _startNode;
  MapNode? _bossNode;
  MapNode? _currentNode;
  MapNode? _selectedNode;

  List<List<MapNode>> get map => _map;
  MapNode? get currentNode => _currentNode;
  MapNode? get selectedNode => _selectedNode;

  void selectAnyNode(MapNode node) {
    _selectedNode = node;
    notifyListeners();
  }

  // Fully generates the map so that it is different each run
  void generateMap() {
    _map.clear();

    final Random random = Random();
    const int minNodesPerFloor = 2;
    const int maxNodesPerFloor = 5;
    const int estimatedTotalNodes = 60;

    // Initialize empty floor structure
    for (int floor = 0; floor < totalFloors; floor++) {
      _map.add([]);
    }

    // STEP 1: Add a single fixed start node in the middle column
    final startNode = MapNode(
      floor: 0,
      index: MapManager.nodesPerFloor ~/ 2,
      type: MapNodeType.start,
      rounds: _generateRoundsForFloor(0),
    );
    _map[0].add(startNode);
    List<MapNode> previousFloorNodes = [startNode];

    int totalNodes = 1;

    // STEP 2: Generate each floor from 1 to 14 (last floor before boss)
    for (int floor = 1; floor < totalFloors - 1; floor++) {
      final Set<int> candidateIndices = {};

      // Let previous nodes each propose 1–2 possible connections
      for (final prev in previousFloorNodes) {
        final offsets = [-2, -1, 0, 1, 2]..shuffle();
        for (
          int i = 0;
          i < 4 && candidateIndices.length < maxNodesPerFloor;
          i++
        ) {
          int newIndex = prev.index + offsets[i];
          if (newIndex >= 0 && newIndex < MapManager.nodesPerFloor) {
            candidateIndices.add(newIndex);
          }
        }
      }

      // Force 2–3 nodes only, limit total to ~35
      int nodesThisFloor =
          minNodesPerFloor +
          random.nextInt(maxNodesPerFloor - minNodesPerFloor + 1);

      if (totalNodes + nodesThisFloor > estimatedTotalNodes &&
          floor < totalFloors - 1) {
        nodesThisFloor = estimatedTotalNodes - totalNodes;
      }

      final selectedIndices = candidateIndices.toList()..shuffle();
      selectedIndices.length =
          selectedIndices.length.clamp(1, nodesThisFloor).toInt();

      final List<MapNode> currentFloorNodes = [];

      for (final index in selectedIndices) {
        final nodeType = MapNodeType.combat;
        final newNode = MapNode(
          floor: floor,
          index: index,
          type: nodeType,
          rounds: _generateRoundsForFloor(floor),
        );
        _map[floor].add(newNode);
        currentFloorNodes.add(newNode);
        totalNodes++;
      }

      // Ensure every previous node connects to at least one current node
      for (final prevNode in previousFloorNodes) {
        if (prevNode.connections.isEmpty) {
          // Connect to closest current node
          final closest = currentFloorNodes.reduce(
            (a, b) =>
                (a.index - prevNode.index).abs() <
                        (b.index - prevNode.index).abs()
                    ? a
                    : b,
          );
          prevNode.connections.add(closest);
        }
      }

      // Ensure each new node has at least one inbound connection
      for (final node in currentFloorNodes) {
        final hasInbound = previousFloorNodes.any(
          (prev) => prev.connections.contains(node),
        );
        if (!hasInbound) {
          final closest = previousFloorNodes.reduce(
            (a, b) =>
                (node.index - a.index).abs() < (node.index - b.index).abs()
                    ? a
                    : b,
          );
          closest.connections.add(node);
        }
      }

      previousFloorNodes = currentFloorNodes;
    }

    // STEP 3: Boss node (final target)
    _bossNode = MapNode(
      floor: totalFloors - 1,
      index: MapManager.nodesPerFloor ~/ 2,
      type: MapNodeType.boss,
      rounds: _generateRoundsForFloor(totalFloors),
    );

    _map[totalFloors - 1].add(_bossNode!);

    for (final node in previousFloorNodes) {
      node.connections.add(_bossNode!);
    }

    // Final assignments
    _startNode = startNode;
    _currentNode = _startNode;
    _selectedNode = null;

    _assignNodeTypes();
    assignRewardsToNodes(GameManager.instance!);
    notifyListeners();
  }

  // Assigns the node types and any other unique info
  void _assignNodeTypes() {
    int restFloor = 0;
    for (int floor = 1; floor < totalFloors - 1; floor++) {
      if (floor >= 6 &&
          restFloor == 0 &&
          floor != 10 &&
          (Random().nextDouble() < 0.10 || (restFloor == 0 && floor == 14))) {
        restFloor = floor;
      }
      int elitesOnFloor = 0;
      for (final node in _map[floor]) {
        if (floor == 5 || floor == 10) {
          node.type = MapNodeType.blessing;
          node.rounds.clear();
        } else if (restFloor == floor) {
          node.type = MapNodeType.rest;
          node.rounds.clear();
        } else if (floor >= 2 &&
            floor <= 10 &&
            elitesOnFloor < 2 &&
            Random().nextDouble() < 0.2) {
          elitesOnFloor += 1;
          node.type = MapNodeType.elite;
          node.rounds.clear();
          node.rounds = _generateRoundsForFloor(floor, isElite: true);
        } else if (floor >= 10 &&
            floor <= 12 &&
            elitesOnFloor < 4 &&
            Random().nextDouble() < 0.4) {
          elitesOnFloor += 1;
          node.type = MapNodeType.elite;
          node.rounds.clear();
          node.rounds = _generateRoundsForFloor(floor, isElite: true);
        } else {
          node.type = MapNodeType.combat;
          node.rounds.clear();
          node.rounds = _generateRoundsForFloor(floor);
        }
      }
    }

    for (final node in _map[0]) {
      node.type = MapNodeType.start;
    }

    for (final node in _map[totalFloors - 2]) {
      if (node.type != MapNodeType.rest) {
        node.type = MapNodeType.combat;
      }
    }
  }

  // Checks if a node can be selected, if so it does
  void selectNode(MapNode node) {
    if (currentNode == null) return;
    if (currentNode!.connections.contains(node)) {
      _selectedNode = node;
      notifyListeners();
    }
  }

  // Sets our current node to the selected one
  void enterSelectedNode() {
    if (_selectedNode != null) {
      _currentNode = _selectedNode;
      _selectedNode = null;
      if (currentNode!.type == MapNodeType.blessing) {
        GameManager.instance!.setCurrentState(GameState.map);
        offerBlessings();
      } else if (currentNode!.type == MapNodeType.rest) {
        GameManager.instance!.addHealth(25);
      } else {
        // Default to normal handling
        GameManager.instance!.setCurrentState(GameState.shopping);
      }
      notifyListeners();
    }
  }

  // Finds three possible options to offer to the player
  void offerBlessings() {
    final int currentTier = tierOrder[_blessingsChosen];
    final int choiceNumber = _blessingsChosen + 1;

    final possible = BlessingData.getBlessingsForTierAndChoice(
      currentTier,
      choiceNumber,
    );
    possible.shuffle();
    currentBlessingOptions = possible.take(3).toList();

    GameManager.instance!.notifyListeners();
  }

  // Makes a blessing chosen from the widget
  void chooseBlessing(String blessingName) {
    playerBlessings.add(blessingName);
    _blessingsChosen++;

    BlessingData.applyImmediateBlessing(blessingName);
    if ((playerBlessings[0] == "Processed Forging" && _blessingsChosen == 2)) {
      GameManager.instance!.boardManager?.addItemToBench(
        GameManager.instance!.getRandomItemByTier(3),
      );
    } else if (_blessingsChosen == 3) {
      if (playerBlessings[1] == "Processed Forging") {
        GameManager.instance!.boardManager?.addItemToBench(
          GameManager.instance!.getRandomItemByTier(3),
        );
      }
    }
    currentBlessingOptions = [];
    GameManager.instance!.notifyListeners();
  }

  // Rerolls the offered blessings
  void useBlessingReroll() {
    if (_blessingRerolls > 0) {
      _blessingRerolls--;
      offerBlessings();
    }
  }

  // Generates the rounds for a node based off the floor
  List<List<UnitData>> _generateRoundsForFloor(
    int floor, {
    bool isElite = false,
  }) {
    final Random random = Random();

    // List of all available floors that have round sets
    final availableFloors =
        globalRoundSets.map((s) => s.floor).toSet().toList()..sort();

    int effectiveFloor = floor;

    if (isElite) {
      final int offset = 1 + random.nextInt(2);
      effectiveFloor = min(floor + offset, availableFloors.last);
    }

    // Try to find exact matches
    final matchingSets =
        globalRoundSets.where((set) => set.floor == effectiveFloor).toList();

    if (matchingSets.isNotEmpty) {
      matchingSets.shuffle();
      return matchingSets.first.rounds
          .map((r) => List<UnitData>.from(r))
          .toList();
    }

    // Use highest available floor that is below effectiveFloor
    final lowerFloors =
        availableFloors.where((f) => f < effectiveFloor).toList();
    if (lowerFloors.isNotEmpty) {
      final fallbackFloor = lowerFloors.last;
      final fallbackSet = globalRoundSets.firstWhere(
        (set) => set.floor == fallbackFloor,
      );
      return fallbackSet.rounds.map((r) => List<UnitData>.from(r)).toList();
    }

    // If we're still here, use the very first round set (shouldn't be reached tbh)
    return globalRoundSets.first.rounds
        .map((r) => List<UnitData>.from(r))
        .toList();
  }

  void assignRewardsToNodes(GameManager gameManager) {
    for (var floorNodes in _map) {
      for (var node in floorNodes) {
        if (node.type != MapNodeType.combat && node.type != MapNodeType.elite) {
          continue;
        }
        final items = <Item>[];
        final units = <Unit>[];
        int gold = 0;
        int itemReforgeTokens = 0;
        int unitLargeDuplicators = 0;
        int unitSmallDuplicators = 0;
        int rewardFloor = node.floor;
        if (node.type == MapNodeType.elite) {
          gold += 10;
          itemReforgeTokens += 1;
          items.add(gameManager.getRandomBasicItem());
        }

        switch (rewardFloor) {
          case 0:
          case 1:
            items.add(gameManager.getRandomBasicItem());
            itemReforgeTokens += 1;
            break;
          case 2:
            items.add(gameManager.getRandomBasicItem());
            itemReforgeTokens += 1;
            break;
          case 3:
            items.add(gameManager.getRandomBasicItem());
            units.add(gameManager.getRandomUnitByCost(1));
            itemReforgeTokens += 1;
            break;
          case 4:
            items.add(gameManager.getRandomBasicItem());
            itemReforgeTokens += 1;
            unitSmallDuplicators += 1;
            break;
          case 5:
            break;
          case 6:
            itemReforgeTokens += 1;
            break;
          case 7:
            items.add(gameManager.getRandomBasicItem());
            units.add(gameManager.getRandomUnitByCost(2));
            itemReforgeTokens += 1;
            break;
          case 8:
            items.add(gameManager.getRandomBasicItem());
            itemReforgeTokens += 1;
            break;
          case 9:
            items.addAll([
              gameManager.getRandomBasicItem(),
              gameManager.getRandomBasicItem(),
            ]);
            itemReforgeTokens += 2;
            unitSmallDuplicators += 2;
            break;
          case 10:
            break;
          case 11:
            units.add(gameManager.getRandomUnitByCost(3));
            items.add(gameManager.getRandomItemByTier(2));
            itemReforgeTokens += 1;
            break;
          case 12:
            items.add(gameManager.getRandomItemByTier(2));
            itemReforgeTokens += 1;
            break;
          case 13:
            items.add(gameManager.getRandomItemByTier(2));
            itemReforgeTokens += 1;
            break;
          case 14:
            units.add(gameManager.getRandomUnitByCost(4));
            items.addAll([
              gameManager.getRandomItemByTier(2),
              gameManager.getRandomItemByTier(2),
            ]);
            itemReforgeTokens += 2;
            unitLargeDuplicators += 1;
            break;
        }

        List<Unit> newUnits = [];
        for (final unit in units) {
          final newUnit = unit.upgrade();
          newUnits.add(newUnit);
        }
        // Set rewards
        node.rewardGold = gold;
        node.rewardItems = items;
        node.rewardUnits = newUnits;
        node.rewardItemReforgeTokens = itemReforgeTokens;
        node.rewardUnitSmallDuplicators = unitSmallDuplicators;
        node.rewardUnitLargeDuplicators = unitLargeDuplicators;

        // Build display string
        final parts = <String>[];
        if (gold > 0) parts.add('$gold Gold');
        if (itemReforgeTokens > 0) {
          parts.add(
            '$itemReforgeTokens Item Reforge Token${itemReforgeTokens > 1 ? 's' : ''}',
          );
        }
        if (unitSmallDuplicators > 0) {
          parts.add(
            '$unitSmallDuplicators Small Unit Duplicator${unitSmallDuplicators > 1 ? 's' : ''}',
          );
        }
        if (unitLargeDuplicators > 0) {
          parts.add(
            '$unitLargeDuplicators Large Unit Duplicator${unitLargeDuplicators > 1 ? 's' : ''}',
          );
        }
        parts.addAll(items.map((item) => 'Item: ${item.name}'));
        parts.addAll(newUnits.map((unit) => 'Unit: Tier 2 ${unit.unitName}'));

        node.rewardDescription = parts.join('\n');
      }
    }
  }
}
