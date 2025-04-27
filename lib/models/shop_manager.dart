import 'package:flutter/material.dart';
import 'dart:math';
import 'unit.dart';
import 'game_manager.dart';
import '../game_data/units.dart';

// A pool of units used to track how many copies of a specific unit are available in the shop
class UnitPool {
  final Unit unitTemplate;
  final int cost;
  final int poolSize;
  final List<String> classes;
  final List<String> origins;
  int available;
  final GameManager _gameManager;

  UnitPool({
    required this.unitTemplate,
    required this.cost,
    required this.poolSize,
    required this.classes,
    required this.origins,
    required GameManager gameManager,
  }) : _gameManager = gameManager,
       available = poolSize;

  // Creates a copy of the unit from the template, reducing the available pool count
  Unit createUnit() {
    if (available <= 0) {
      return throw Exception('No more units available in pool');
    }

    available--;
    Unit newUnit = unitTemplate.copyWith(
      id:
          '${unitTemplate.unitName}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
    );
    newUnit.gameManager = _gameManager;
    return newUnit;
  }

  // Returns one unit back to the pool, increasing its availability (e.g., if sold or not used)
  void returnUnit() {
    if (available < poolSize) {
      available++;
    }
  }
}

// Represents the probability of rolling each unit tier based on player level
class TierOdds {
  final int playerLevel;
  final List<double> oddsPerTier;

  TierOdds({required this.playerLevel, required this.oddsPerTier});
}

// Manages the shop system: unit rolls, purchases, and pool state
class ShopManager extends ChangeNotifier {
  final GameManager _gameManager;
  final int _shopSize = 5;
  final int _rerollCost = 2;
  int _freeRefreshAmount = 0;

  List<Unit?> _shopUnits = List.generate(5, (_) => null);
  final List<UnitPool> _unitPools = [];

  ShopManager(this._gameManager);

  List<Unit?> get shopUnits => _shopUnits;
  int get rerollCost => _rerollCost;
  int get shopSize => _shopSize;
  int get freeRefreshAmount => _freeRefreshAmount;

  // Initializes shop by populating the unit pools and performing first refresh
  void initialize() {
    _initializeUnitPool();
    _freeRefreshAmount = 0;
    refreshShop();
  }

  // Attempts a reroll—free if available, otherwise costs gold
  bool tryReroll() {
    if (_freeRefreshAmount > 0) {
      _freeRefreshAmount -= 1;
      refreshShop();
      return true;
    }

    if (_gameManager.gold >= _rerollCost) {
      _gameManager.spendGold(_rerollCost);
      refreshShop();
      return true;
    }
    return false;
  }

  // Resets the free shop refresh (used at start of turn, etc.)
  void addFreeRefresh(int x) {
    _freeRefreshAmount = x;
    notifyListeners();
  }

  // Refreshes the shop with a new set of units based on player level and availability in the pool
  void refreshShop() {
    _shopUnits = List.generate(_shopSize, (_) => null);

    final playerLevel = _gameManager.playerLevel;
    final rand = Random();

    for (int i = 0; i < _shopSize; i++) {
      int unitCost = _generateUnitCost(playerLevel, rand);

      List<UnitPool> availablePools =
          _unitPools
              .where((pool) => pool.cost == unitCost && pool.available > 0)
              .toList();

      if (availablePools.isNotEmpty) {
        UnitPool selectedPool =
            availablePools[rand.nextInt(availablePools.length)];

        _shopUnits[i] = selectedPool.createUnit();
      }
    }

    notifyListeners();
  }

  // Attempts to purchase the unit in the given shop slot
  bool tryPurchaseUnit(int shopIndex) {
    if (shopIndex < 0 ||
        shopIndex >= _shopSize ||
        _shopUnits[shopIndex] == null) {
      return false;
    }

    final unit = _shopUnits[shopIndex]!;

    if (_gameManager.gold >= unit.cost) {
      Unit newUnit = unit.copyWith(
        id:
            '${unit.unitName}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000000)}',
        isFromShop: true,
      );
      newUnit.gameManager = _gameManager;

      if (_gameManager.purchaseUnit(newUnit)) {
        _shopUnits[shopIndex] = null;
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  // Determines the cost of a unit to roll based on the player’s level and probability table
  int _generateUnitCost(int playerLevel, Random rand) {
    final List<List<double>> levelProbabilities = [
      [1.00, 0.00, 0.00, 0.00, 0.00],
      [0.70, 0.30, 0.00, 0.00, 0.00],
      [0.60, 0.35, 0.05, 0.00, 0.00],
      [0.50, 0.35, 0.15, 0.00, 0.00],
      [0.40, 0.35, 0.23, 0.02, 0.00],
      [0.30, 0.35, 0.30, 0.05, 0.00],
      [0.20, 0.35, 0.30, 0.14, 0.01],
      [0.15, 0.25, 0.35, 0.20, 0.05],
      [0.10, 0.20, 0.35, 0.25, 0.10],
      [0.10, 0.15, 0.30, 0.30, 0.15],
    ];

    int level = playerLevel.clamp(1, 9);

    final probs = levelProbabilities[level - 1];

    double roll = rand.nextDouble();

    double cumulative = 0;
    for (int i = 0; i < probs.length; i++) {
      cumulative += probs[i];
      if (roll <= cumulative) {
        return i + 1;
      }
    }

    return 1;
  }

  // Builds the initial unit pool from available unit data and cost-based sizes
  void _initializeUnitPool() {
    _unitPools.clear();

    unitData.forEach((unitName, unitTemplate) {
      _unitPools.add(
        UnitPool(
          unitTemplate: unitTemplate,
          cost: unitTemplate.cost,
          poolSize: _getPoolSizeForCost(unitTemplate.cost),
          classes: unitTemplate.classes,
          origins: unitTemplate.origins,
          gameManager: _gameManager,
        ),
      );
    });
  }

  // Returns the starting pool size for a unit based on its cost
  int _getPoolSizeForCost(int cost) {
    switch (cost) {
      case 1:
        return 29;
      case 2:
        return 22;
      case 3:
        return 18;
      case 4:
        return 12;
      case 5:
        return 10;
      default:
        return 20;
    }
  }
}
