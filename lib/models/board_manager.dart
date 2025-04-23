import 'package:flutter/foundation.dart';
import 'package:realm_of_tactics/models/ability.dart';
import 'unit.dart';
import 'item.dart';
import 'dart:math';
import 'synergy_manager.dart';
import 'game_manager.dart';
import 'board_position.dart';
import 'package:realm_of_tactics/models/summoned_unit.dart';

class BoardManager extends ChangeNotifier {
  // Various variables for board related things
  static const int boardRows = 6;
  static const int boardCols = 8;
  static const int benchSlots = 10;
  static const int enemyRows = 3;
  static const int playerStartRow = 3;

  // the "board", a 2d list of values that start as null and change to have units occupy them
  final List<List<Unit?>> _board = List.generate(
    boardRows,
    (_) => List.generate(boardCols, (_) => null),
  );

  // The bench, same as the board but only a 1d list
  final List<dynamic> _bench = List.generate(benchSlots, (_) => null);

  // Managers
  final SynergyManager _synergyManager;
  final GameManager _gameManager;
  BoardManager(this._gameManager, this._synergyManager);

  // Initializes the board and bench and updates the visuals
  void initialize() {
    _clearBoardRange();
    _clearBench();
    notifyListeners();
  }

  // Clears the board between certain ranges to help clear both player and enemy boards
  void _clearBoardRange({int startRow = 0, int endRow = boardRows}) {
    for (int row = startRow; row < endRow; row++) {
      for (int col = 0; col < boardCols; col++) {
        _board[row][col] = null;
      }
    }
  }

  // Clears all units from the board
  void resetBoard() {
    _clearBoardRange(); // clears entire board
    notifyListeners();
  }

  // Clears the player's side of the board (used between rounds)
  void clearPlayerBoardSide() {
    _clearBoardRange(startRow: playerStartRow);
    notifyListeners();
  }

  // Removes everything from the bench
  void _clearBench() {
    for (int i = 0; i < benchSlots; i++) {
      _bench[i] = null;
    }
  }

  // Gets the unit at a given position or null if none
  Unit? getUnitAt(Position position) {
    if (isValidBoardPosition(position)) {
      return _board[position.row][position.col];
    }
    return null;
  }

  // Get what is at a bench slot, could be unit or an item or null
  dynamic getBenchSlotItem(int index) {
    if (isValidBenchIndex(index)) {
      return _bench[index];
    }
    return null;
  }

  // Checks if a position is in the enemy territory or not
  bool isEnemyTerritory(Position position) {
    return position.row < enemyRows;
  }

  // Checks if a position is in the player territory or not
  bool isPlayerTerritory(Position position) {
    return position.row >= playerStartRow;
  }

  // The amount of units on the board (not summons)
  int get nonSummonedUnitCount {
    int count = 0;
    for (int i = 0; i < boardRows; i++) {
      for (int j = 0; j < boardCols; j++) {
        if (_board[i][j] != null && _board[i][j] is! SummonedUnit) {
          count++;
        }
      }
    }
    return count;
  }

  // Checks if the player is trying to place the unit on an occupied tile,
  // in the enemy territory, or if it's not a summon and their level is too low
  bool canPlaceUnit(Unit unit, Position position) {
    if (!isValidBoardPosition(position) ||
        _board[position.row][position.col] != null) {
      return false;
    }

    if (!isPlayerTerritory(position)) {
      return false;
    }

    if (unit is SummonedUnit) {
      return true;
    }

    int playerLevel = _gameManager.playerLevel;

    bool isMovingOnBoard = unit.isOnBoard;
    int currentNonSummonCount = nonSummonedUnitCount;

    if (isMovingOnBoard) {
      currentNonSummonCount--;
    }

    if (currentNonSummonCount >= playerLevel) {
      return false;
    }

    return true;
  }

  // Calls the check, then if the unit upgrades no need to place,
  // otherwise places the unit on the board or bench spot attempted.
  bool placeUnit(Unit unit, Position position) {
    if (!canPlaceUnit(unit, position)) {
      return false;
    }

    if (unit is! SummonedUnit && tryUpgradeUnit(unit)) {
      return true;
    }

    Unit unitToPlace = unit;
    bool wasOnBench = false;

    int? currentBenchIndex = unit.benchIndex;
    if (currentBenchIndex != null &&
        currentBenchIndex >= 0 &&
        isValidBenchIndex(currentBenchIndex)) {
      if (_bench[currentBenchIndex] is Unit &&
          (_bench[currentBenchIndex] as Unit).id == unit.id) {
        _bench[currentBenchIndex] = null;
        wasOnBench = true;
      }
    } else if (unit.isOnBoard && unit.boardX >= 0 && unit.boardY >= 0) {
      Position oldPos = Position(unit.boardY, unit.boardX);
      if (isValidBoardPosition(oldPos) &&
          _board[oldPos.row][oldPos.col]?.id == unit.id) {
        _board[oldPos.row][oldPos.col] = null;
      }
    }

    unitToPlace.isOnBoard = true;
    unitToPlace.boardX = position.col;
    unitToPlace.boardY = position.row;
    unitToPlace.benchIndex = -1;

    _board[position.row][position.col] = unitToPlace;

    if (wasOnBench && !unit.isSummon) {
      _synergyManager.applyActiveSynergiesToUnit(unitToPlace);
    }

    _synergyManager.updateSynergies();

    notifyListeners();
    return true;
  }

  // Used for placing the summon on the board when it spawns,
  // finding the first valid spot.
  Unit? placeSummonOnBoard(SummonedUnit summon) {
    Position? targetPosition;
    for (int row = playerStartRow; row < boardRows; row++) {
      for (int col = 0; col < boardCols; col++) {
        if (_board[row][col] == null) {
          targetPosition = Position(row, col);
          break;
        }
      }
      if (targetPosition != null) break;
    }

    if (targetPosition == null) {
      return null;
    }

    summon.isOnBoard = true;
    summon.boardX = targetPosition.col;
    summon.boardY = targetPosition.row;
    summon.benchIndex = -1;

    _board[targetPosition.row][targetPosition.col] = summon;

    return summon;
  }

  // Adds a unit to the bench, again if it's used to upgrade skip placement,
  // otherwise find the first bench slot that's empty and if it's from the shop
  // get a new copy to put there otherwise remove all of the bonus stats and
  // synergy effects
  bool addUnitToBench(Unit unit, [int? targetIndex]) {
    if (unit is SummonedUnit) {
      return false;
    }

    if (unit is! SummonedUnit && tryUpgradeUnit(unit)) {
      return true;
    }

    int emptySlot = _findEmptyBenchSlot(targetIndex);
    if (emptySlot == -1) {
      return false;
    }

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String random = (Random().nextInt(1000000)).toString();
    String newId = "${unit.unitName}_${timestamp}_$random";

    Unit unitToAdd = unit;

    if (unitToAdd.isFromShop) {
      newId =
          '${unit.unitName}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000000)}';
      unitToAdd = unit.copyWith(id: newId, stats: unit.stats.copyWith());
    }

    bool removedFromBoard = false;

    if (unit.isOnBoard && unit.boardX >= 0 && unit.boardY >= 0) {
      Position oldPos = Position(unit.boardY, unit.boardX);
      if (isValidBoardPosition(oldPos) &&
          _board[oldPos.row][oldPos.col]?.id == unit.id) {
        _synergyManager.unapplySynergyEffectsFromUnit(unit);
        _board[oldPos.row][oldPos.col] = null;
        removedFromBoard = true;
      }
    }

    unitToAdd.isOnBoard = false;
    unitToAdd.benchIndex = emptySlot;
    unitToAdd.boardX = -1;
    unitToAdd.boardY = -1;
    _bench[emptySlot] = unitToAdd;

    unitToAdd.stats.currentHealth = unitToAdd.stats.maxHealth;

    unitToAdd.stats.resetBonusStats();

    if (removedFromBoard) {
      _synergyManager.updateSynergies();
    }

    notifyListeners();
    return true;
  }

  // Used for swapping two units on the bench
  void swapBenchUnits(int indexA, int indexB) {
    final Unit? unitA = getBenchSlotItem(indexA) as Unit?;
    final Unit? unitB = getBenchSlotItem(indexB) as Unit?;

    if (unitA != null && unitB != null) {
      _bench[indexA] = unitB;
      _bench[indexB] = unitA;
      unitA.benchIndex = indexB;
      unitB.benchIndex = indexA;
      notifyListeners();
    }
  }

  // Used for swapping two items on the bench
  void swapBenchItems(int indexA, int indexB) {
    final Item? itemA = getBenchSlotItem(indexA) as Item?;
    final Item? itemB = getBenchSlotItem(indexB) as Item?;

    if (itemA != null && itemB != null) {
      _bench[indexA] = itemB;
      _bench[indexB] = itemA;
      itemA.benchIndex = indexB;
      itemB.benchIndex = indexA;
      notifyListeners();
    }
  }

  // Used for swapping two units on the board
  void swapBoardUnits(Position posA, Position posB) {
    final unitA = getUnitAt(posA);
    final unitB = getUnitAt(posB);

    if (unitA != null && unitB != null) {
      _board[posA.row][posA.col] = unitB;
      _board[posB.row][posB.col] = unitA;
      unitA.boardX = posB.col;
      unitA.boardY = posB.row;
      unitB.boardX = posA.col;
      unitB.boardY = posA.row;
      notifyListeners();
    }
  }

  // Adds an item to the bench, or tries to combine it if dropped on another item
  bool addItemToBench(Item item, [int? targetIndex]) {
    int targetSlot = targetIndex ?? -1;

    // If this is a component item and it's dropped on another component, try to combine them
    if (item.isComponent && targetSlot != -1 && isValidBenchIndex(targetSlot)) {
      dynamic targetSlotContent = _bench[targetSlot];
      if (targetSlotContent is Item && targetSlotContent.isComponent) {
        Item? combinedItem = item.combine(targetSlotContent);
        if (combinedItem != null) {
          _bench[targetSlot] = combinedItem;
          combinedItem.benchIndex = targetSlot;
          notifyListeners();
          return true;
        }
      }
    }

    // Otherwise, find an empty bench slot at the index and place it there
    int emptySlot = _findEmptyBenchSlot(targetIndex);
    if (emptySlot == -1) {
      return false;
    }

    item.benchIndex = emptySlot;
    _bench[emptySlot] = item;

    notifyListeners();
    return true;
  }

  // Checks if a bench index is within valid bounds
  bool isValidBenchIndex(int index) {
    return index >= 0 && index < benchSlots;
  }

  // Attempts to upgrade a unit if there are 3 matching copies at the same tier
  bool tryUpgradeUnit(Unit newUnit) {
    if (newUnit.tier >= 3) return false;

    List<Unit> allCopies = [];
    int targetTier = newUnit.tier;

    // Find all copies of this unit at tier 1
    if (targetTier == 1) {
      // Look on the board
      for (int i = 0; i < boardRows; i++) {
        for (int j = 0; j < boardCols; j++) {
          if (_board[i][j] != null &&
              _board[i][j]!.unitName == newUnit.unitName &&
              _board[i][j]!.tier == targetTier) {
            if (!allCopies.any((u) => u.id == _board[i][j]!.id)) {
              allCopies.add(_board[i][j]!);
            }
          }
        }
      }

      // Look on the bench
      for (int i = 0; i < benchSlots; i++) {
        if (_bench[i] is Unit &&
            (_bench[i] as Unit).unitName == newUnit.unitName &&
            (_bench[i] as Unit).tier == targetTier) {
          Unit benchUnit = _bench[i] as Unit;

          if (!allCopies.any((u) => u.id == benchUnit.id)) {
            allCopies.add(benchUnit);
          }
        }
      }

      // Add the current newUnit if it's not already included
      bool newUnitAlreadyCounted = allCopies.any(
        (unit) => unit.id == newUnit.id,
      );
      if (!newUnitAlreadyCounted) {
        allCopies.add(newUnit);
      }

      // Same logic for tier 2 upgrades (into tier 3)
    } else if (targetTier == 2) {
      // Look on the board
      for (int i = 0; i < boardRows; i++) {
        for (int j = 0; j < boardCols; j++) {
          if (_board[i][j] != null &&
              _board[i][j]!.unitName == newUnit.unitName &&
              _board[i][j]!.tier == 2) {
            if (!allCopies.any((u) => u.id == _board[i][j]!.id)) {
              allCopies.add(_board[i][j]!);
            }
          }
        }
      }

      // Look on the bench
      for (int i = 0; i < benchSlots; i++) {
        if (_bench[i] is Unit &&
            (_bench[i] as Unit).unitName == newUnit.unitName &&
            (_bench[i] as Unit).tier == 2) {
          Unit benchUnit = _bench[i] as Unit;
          if (!allCopies.any((u) => u.id == benchUnit.id)) {
            allCopies.add(benchUnit);
          }
        }
      }

      // Ensure the triggering unit is counted
      if (newUnit.tier == 2 &&
          !allCopies.any((unit) => unit.id == newUnit.id)) {
        allCopies.add(newUnit);
      }
    }

    // Ensure all 3 copies are unique
    if (allCopies.length >= 3) {
      Set<String> uniqueIds = allCopies.map((u) => u.id).toSet();
      if (uniqueIds.length < 3) {
        return false;
      }

      // Get the unit that should become the upgraded version
      Unit baseUnit = Unit.findBaseUnitForCombine(allCopies);
      List<Unit> otherCopies =
          allCopies.where((u) => u.id != baseUnit.id).take(2).toList();

      if (otherCopies.length != 2) {
        return false;
      }

      // Upgrade the base unit and unequip items from others
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String random = (Random().nextInt(1000000)).toString();
      String newId = "${baseUnit.unitName}_${timestamp}_$random";

      List<Item> unequippedItems = baseUnit.combineWith(otherCopies);

      baseUnit = baseUnit.copyWith(id: newId);

      // Clear board/bench copies of the others
      for (var unit in otherCopies) {
        if (unit.isOnBoard) {
          Position pos = Position(unit.boardY, unit.boardX);
          if (isValidBoardPosition(pos)) {
            _board[pos.row][pos.col] = null;
          }
        } else if (unit.benchIndex != null && unit.benchIndex! >= 0) {
          _bench[unit.benchIndex!] = null;
        }
      }

      // Clear the old newUnit if it's not the one that was upgraded
      if (newUnit.id != baseUnit.id) {
        if (newUnit.isOnBoard) {
          Position pos = Position(newUnit.boardY, newUnit.boardX);
          if (isValidBoardPosition(pos)) {
            _board[pos.row][pos.col] = null;
          }
        } else if (newUnit.benchIndex != null && newUnit.benchIndex! >= 0) {
          _bench[newUnit.benchIndex!] = null;
        }
      }

      // Put unequipped items back on the bench
      for (var item in unequippedItems) {
        int emptySlot = _findEmptyBenchSlot();
        if (emptySlot != -1) {
          _bench[emptySlot] = item;
          item.benchIndex = emptySlot;
        }
      }

      // Try placing upgraded unit on the bench if needed
      if (!baseUnit.isOnBoard) {
        List<int> availableSlots = [];

        for (var unit in otherCopies) {
          if (!unit.isOnBoard &&
              unit.benchIndex != null &&
              unit.benchIndex! >= 0) {
            availableSlots.add(unit.benchIndex!);
          }
        }

        if (baseUnit.benchIndex != null && baseUnit.benchIndex! >= 0) {
          availableSlots.add(baseUnit.benchIndex!);
        }

        if (availableSlots.isEmpty) {
          int emptySlot = _findEmptyBenchSlot();
          if (emptySlot != -1) {
            availableSlots.add(emptySlot);
          }
        }

        availableSlots.sort();

        if (availableSlots.isNotEmpty) {
          int targetSlot = availableSlots.first;
          baseUnit.benchIndex = targetSlot;
          baseUnit.isOnBoard = false;
          baseUnit.boardX = -1;
          baseUnit.boardY = -1;
          _bench[targetSlot] = baseUnit;
        } else {
          return false;
        }
      }

      // Check for auto-promotion to tier 3 if this upgrade created a new tier 2
      if (targetTier == 1) {
        notifyListeners();

        int tier2Count = 0;

        for (int i = 0; i < boardRows; i++) {
          for (int j = 0; j < boardCols; j++) {
            if (_board[i][j] != null &&
                _board[i][j]!.unitName == baseUnit.unitName &&
                _board[i][j]!.tier == 2) {
              tier2Count++;
            }
          }
        }

        for (int i = 0; i < benchSlots; i++) {
          if (_bench[i] is Unit &&
              (_bench[i] as Unit).unitName == baseUnit.unitName &&
              (_bench[i] as Unit).tier == 2) {
            tier2Count++;
          }
        }

        if (tier2Count >= 3) {
          tryUpgradeUnit(baseUnit);
        }
      }

      notifyListeners();
      return true;
    }

    return false;
  }

  // Returns all the units currently on the board
  List<Unit> getAllBoardUnits() {
    List<Unit> units = [];

    for (int i = 0; i < boardRows; i++) {
      for (int j = 0; j < boardCols; j++) {
        if (_board[i][j] != null) {
          units.add(_board[i][j]!);
        }
      }
    }

    return units;
  }

  // Returns all the units currently on the bench
  List<Unit> getAllBenchUnits() {
    return _bench.whereType<Unit>().toList();
  }

  // Returns all the items currently on the bench
  List<Item> getAllBenchItems() {
    return _bench.whereType<Item>().toList();
  }

  // Finds the first empty bench slot, optionally starting at a target index
  int _findEmptyBenchSlot([int? startIndex]) {
    int start =
        startIndex != null &&
                isValidBenchIndex(startIndex) &&
                _bench[startIndex] == null
            ? startIndex
            : 0;

    if (start == startIndex) return start;

    for (int i = 0; i < (startIndex ?? benchSlots); i++) {
      if (_bench[i] == null) return i;
    }

    if (startIndex != null) {
      for (int i = startIndex + 1; i < benchSlots; i++) {
        if (_bench[i] == null) return i;
      }
    }

    return -1;
  }

  // Checks if a board position is valid
  bool isValidBoardPosition(Position position) {
    return position.row >= 0 &&
        position.row < boardRows &&
        position.col >= 0 &&
        position.col < boardCols;
  }

  // Gets total number of units currently on the board
  int get boardUnitCount {
    int count = 0;
    for (int i = 0; i < boardRows; i++) {
      for (int j = 0; j < boardCols; j++) {
        if (_board[i][j] != null) {
          count++;
        }
      }
    }
    return count;
  }

  // Gets total number of units on the bench
  int get benchUnitCount {
    return _bench.whereType<Unit>().length;
  }

  // Gets total number of items on the bench
  int get benchItemCount {
    return _bench.whereType<Item>().length;
  }

  // How many total bench slots are currently used
  int get occupiedBenchSlots {
    return _bench.where((slot) => slot != null).length;
  }

  // Finds the board position of a unit by ID
  Position? findUnitPositionById(String unitId) {
    for (int i = 0; i < boardRows; i++) {
      for (int j = 0; j < boardCols; j++) {
        if (_board[i][j] != null && _board[i][j]!.id == unitId) {
          return Position(i, j);
        }
      }
    }
    return null;
  }

  // Returns whether a specific board tile is occupied
  bool isBoardPositionOccupied(Position position) {
    return isValidBoardPosition(position) &&
        _board[position.row][position.col] != null;
  }

  // Clears a unit from a specific board tile if there is one
  bool clearBoardPosition(Position position) {
    if (!isValidBoardPosition(position)) {
      return false;
    }

    if (_board[position.row][position.col] != null) {
      _board[position.row][position.col] = null;
      notifyListeners();
      return true;
    }

    return false;
  }

  // Removes a unit or item from either the board or bench
  dynamic remove(dynamic entity) {
    if (entity is Unit) {
      // Remove from board
      if (entity.isOnBoard) {
        Position position = Position(entity.boardY, entity.boardX);
        if (isValidBoardPosition(position) &&
            _board[position.row][position.col]?.id == entity.id) {
          Unit? removedUnit = _board[position.row][position.col];
          _board[position.row][position.col] = null;
          notifyListeners();
          return removedUnit;
        }
      }
      // Remove from bench
      else {
        int? benchIdx = entity.benchIndex;
        if (benchIdx != null && benchIdx >= 0 && isValidBenchIndex(benchIdx)) {
          if (_bench[benchIdx] is Unit &&
              (_bench[benchIdx] as Unit).id == entity.id) {
            dynamic removed = _bench[benchIdx];
            _bench[benchIdx] = null;
            notifyListeners();
            return removed;
          }
        }
      }
    } else if (entity is Item) {
      // Remove item from bench
      int? benchIdx = entity.benchIndex;
      if (benchIdx >= 0 && isValidBenchIndex(benchIdx)) {
        if (_bench[benchIdx] is Item &&
            (_bench[benchIdx] as Item).id == entity.id) {
          dynamic removed = _bench[benchIdx];
          _bench[benchIdx] = null;
          notifyListeners();
          return removed;
        }
      }
    }
    return null;
  }

  // Calculates the amount of gold a unit would sell for based on tier
  int calculateSellValue(Unit unit) {
    int baseValue = unit.cost;

    if (unit.tier == 2) {
      return (3 * baseValue) - 1;
    } else if (unit.tier == 3) {
      return (9 * baseValue) - 1;
    }

    return baseValue;
  }

  // Attempts to sell a unit; fails if it has items or is a summon
  int sellUnit(Unit unit) {
    if (unit is SummonedUnit) {
      return 0;
    }

    if (unit.weapon != null || unit.armor != null || unit.trinket != null) {
      return 0;
    }

    int sellValue = calculateSellValue(unit);
    _synergyManager.unapplySynergyEffectsFromUnit(unit);
    dynamic removed = remove(unit);

    if (removed != null) {
    } else {
      return 0;
    }
    return sellValue;
  }

  // Called when spawning an enemy to place it on the board
  bool registerEnemyUnit(Unit unit) {
    if (!unit.isOnBoard ||
        !isValidBoardPosition(Position(unit.boardY, unit.boardX))) {
      return false;
    }

    if (_board[unit.boardY][unit.boardX] != null) {
      return false;
    }

    _board[unit.boardY][unit.boardX] = unit;

    return true;
  }

  // Calculates distance between 2 units (Manhattan-style)
  static int calculateDistance(Unit unit1, Unit unit2) {
    if (!unit1.isOnBoard || !unit2.isOnBoard) {
      return 999;
    }
    int dx = (unit1.boardX - unit2.boardX).abs();
    int dy = (unit1.boardY - unit2.boardY).abs();
    return max(dx, dy);
  }

  // Calculates distance between two (x, y) coordinate pairs
  static int calculateDistanceCoords(int x1, int y1, int x2, int y2) {
    int dx = (x1 - x2).abs();
    int dy = (y1 - y2).abs();
    return max(dx, dy);
  }

  // Moves a unit to a new board position, updating visuals and synergies
  bool moveUnitOnBoard(Unit unit, Position newPosition) {
    if (!unit.isOnBoard ||
        !isValidBoardPosition(newPosition) ||
        getUnitAt(newPosition) != null) {
      return false;
    }

    Position oldPosition = Position(unit.boardY, unit.boardX);
    if (isValidBoardPosition(oldPosition) &&
        _board[oldPosition.row][oldPosition.col]?.id == unit.id) {
      _board[oldPosition.row][oldPosition.col] = null;
    }

    _board[newPosition.row][newPosition.col] = unit;
    unit.boardX = newPosition.col;
    unit.boardY = newPosition.row;

    unit.checkEmberhillMovement();

    _synergyManager.updateSynergies();

    notifyListeners();
    return true;
  }

  // Resets units to their original board positions or moves them to bench
  void resetBoardPositions(
    List<Unit> originalUnits,
    Map<String, Position> initialPositions,
  ) {
    _clearBoardRange();

    for (var unit in originalUnits) {
      Position? position = initialPositions[unit.id];
      if (position != null && isValidBoardPosition(position)) {
        if (_board[position.row][position.col] != null) {
          _board[position.row][position.col] = null;
        }
        _board[position.row][position.col] = unit;
        unit.isOnBoard = true;
        unit.boardX = position.col;
        unit.boardY = position.row;
        unit.benchIndex = -1;
        unit.reset();
      } else {
        addUnitToBench(unit);
      }
    }

    notifyListeners();
  }

  // Returns list of units affected by area targeting
  List<Unit> getUnitsInArea(
    Position center,
    AreaShape shape,
    int size,
    List<Unit> candidates,
  ) {
    List<Unit> result = [];

    for (final unit in candidates) {
      final dx = (unit.boardX - center.col).abs();
      final dy = (unit.boardY - center.row).abs();

      switch (shape) {
        case AreaShape.xByX:
          if (size == 0) {
            result.add(unit);
          } else {
            final range = (size / 2).floor();
            if ((unit.boardX >= center.col - range &&
                    unit.boardX <= center.col + range) &&
                (unit.boardY >= center.row - range &&
                    unit.boardY <= center.row + range)) {
              result.add(unit);
            }
          }
          break;

        case AreaShape.row:
          if (size == 0 || (unit.boardY == center.row && dx <= size)) {
            result.add(unit);
          }
          break;

        case AreaShape.column:
          if (size == 0 || (unit.boardX == center.col && dy <= size)) {
            result.add(unit);
          }
          break;

        case AreaShape.plusShape:
          if (size == 0 || (dx == 0 || dy == 0) && (dx <= size && dy <= size)) {
            result.add(unit);
          }
          break;

        case AreaShape.xShape:
          if (size == 0 || dx == dy && dx <= size) {
            result.add(unit);
          }
          break;
      }
    }

    return result;
  }

  // Returns the center position that would hit the most units with a given area shape
  Position getBestClusterTarget(
    AreaShape shape,
    int size,
    List<Unit> candidates,
  ) {
    int maxHits = 0;
    Position bestCenter = Position(0, 0);

    for (var unit in candidates) {
      Position center = Position(unit.boardY, unit.boardX);
      int hits = getUnitsInArea(center, shape, size, candidates).length;

      if (hits > maxHits) {
        maxHits = hits;
        bestCenter = center;
      }
    }

    return bestCenter;
  }

  // Adds a summoned unit to the board at the first available tile
  bool addSummonedUnit(SummonedUnit summon, {required bool isEnemy}) {
    int startRow = isEnemy ? 3 : boardRows;
    int endRow = isEnemy ? 0 : playerStartRow;
    if (isEnemy) {
      GameManager.instance?.combatManager?.enemyUnits.add(summon);
    } else {
      GameManager.instance?.combatManager?.playerUnits.add(summon);
    }
    Position? targetPosition;

    for (int row = startRow - 1; row > endRow; row--) {
      for (int col = 0; col < boardCols; col++) {
        if (_board[row][col] == null) {
          targetPosition = Position(row, col);
          break;
        }
      }
      if (targetPosition != null) break;
    }

    if (targetPosition == null) {
      return false;
    }

    summon.isOnBoard = true;
    summon.boardX = targetPosition.col;
    summon.boardY = targetPosition.row;
    summon.benchIndex = -1;

    _board[targetPosition.row][targetPosition.col] = summon;

    notifyListeners();
    return true;
  }

  // Returns list of units adjacent to a given unit
  List<Unit> getAdjacentUnits(Unit unit) {
    if (!unit.isOnBoard) return [];

    List<Unit> adjacentUnits = [];
    final directions = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];

    for (var dir in directions) {
      int newY = unit.boardY + dir[0];
      int newX = unit.boardX + dir[1];

      if (isValidBoardPosition(Position(newY, newX))) {
        Unit? adjacentUnit = _board[newY][newX];
        if (adjacentUnit != null) {
          adjacentUnits.add(adjacentUnit);
        }
      }
    }

    return adjacentUnits;
  }

  // Returns true if all 10 bench slots are occupied
  bool isBenchFull() {
    int occupiedSlots = 0;
    for (int i = 0; i < 10; i++) {
      if (_bench[i] != null) {
        occupiedSlots++;
      }
    }
    return occupiedSlots >= 10;
  }
}
