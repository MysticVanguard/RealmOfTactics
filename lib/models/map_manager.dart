import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:realm_of_tactics/models/round_data.dart';

// Types of nodes on the map
enum MapNodeType { start, combat, elite, rest, merchant, event, boss }

// A map node for the displayed map, has the level of the map
// as the floor, the index as the x, it's type, what it's connected
// to, and the rounds it includes (only relevant for combat and elite)
class MapNode {
  final int floor;
  final int index;
  MapNodeType type;
  final List<MapNode> connections = [];
  List<List<UnitData>> rounds;

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
  static const int totalFloors = 15;
  static const int nodesPerFloor = 7;
  static const int roundsPerNode = 5;

  final List<List<MapNode>> _map = List.generate(totalFloors, (_) => []);

  // Special nodes need tracked of
  MapNode? _startNode;
  MapNode? _bossNode;
  MapNode? _currentNode;
  MapNode? _selectedNode;

  List<List<MapNode>> get map => _map;
  MapNode? get currentNode => _currentNode;
  MapNode? get selectedNode => _selectedNode;

  // Fully generates the map so that it is different each run
  void generateMap() {
    _map.clear();

    final Random random = Random();
    const int minNodesPerFloor = 2;
    const int maxNodesPerFloor = 3;
    const int estimatedTotalNodes = 35;

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
    for (int floor = 1; floor < totalFloors; floor++) {
      final Set<int> candidateIndices = {};

      // Let previous nodes each propose 1–2 possible connections
      for (final prev in previousFloorNodes) {
        final offsets = [-1, 0, 1]..shuffle();
        for (
          int i = 0;
          i < 2 && candidateIndices.length < maxNodesPerFloor;
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
      floor: totalFloors,
      index: MapManager.nodesPerFloor ~/ 2,
      type: MapNodeType.boss,
      rounds: _generateRoundsForFloor(totalFloors),
    );

    for (final node in previousFloorNodes) {
      node.connections.add(_bossNode!);
    }

    // Final assignments
    _startNode = startNode;
    _currentNode = _startNode;
    _selectedNode = null;

    _assignNodeTypes();
    notifyListeners();
  }

  // Assigns the node types and any other unique info
  void _assignNodeTypes() {
    for (int floor = 1; floor < totalFloors - 1; floor++) {
      for (final node in _map[floor]) {
        if (floor >= 2 && Random().nextDouble() < 0.15) {
          node.type = MapNodeType.elite;
          node.rounds.clear();
          node.rounds = _generateRoundsForFloor(floor, isElite: true);
        } else if (floor >= 6 && Random().nextDouble() < 0.10) {
          node.type = MapNodeType.rest;
          node.rounds.clear(); // no rounds needed
        } else if (Random().nextDouble() < 0.05) {
          node.type = MapNodeType.merchant;
          node.rounds.clear(); // no rounds
        } else if (Random().nextDouble() < 0.22) {
          node.type = MapNodeType.event;
          node.rounds.clear(); // no rounds
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

    for (final node in _map[totalFloors - 1]) {
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
      notifyListeners();
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
      final int offset = 1 + random.nextInt(3);
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
}
