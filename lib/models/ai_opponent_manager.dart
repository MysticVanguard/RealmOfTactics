import 'package:realm_of_tactics/models/board_position.dart';

import 'unit.dart';
import '../game_data/units.dart' as game_units;

class UnitData {
  final String name;
  final Position position;
  final int tier;

  UnitData(this.name, this.position, this.tier);
}

class AIOpponentManager {
  AIOpponentManager();

  // Get's a list of who the player with fight in the next combat based off the current stage
  List<Unit> generateEnemyTeam(int roundNumber) {
    List<Unit> team = [];

    switch (roundNumber) {
      case 1:
        team.addAll(
          createUnitsFromList([
            UnitData('Icewall Sentinel', Position(2, 3), 1),
            UnitData('Winterblade Guardian', Position(2, 4), 1),
            UnitData('Icewall Sentinel', Position(2, 5), 1),
          ]),
        );
        break;

      case 2:
        team.addAll(
          createUnitsFromList([
            UnitData('Icewall Sentinel', Position(2, 3), 1),
            UnitData('Rimebound Vanguard', Position(2, 4), 1),
            UnitData('Granite Guard', Position(2, 1), 1),
          ]),
        );
        break;

      case 3:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 1,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 1,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 1,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 1,
          ),
        ]);
        break;

      case 4:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 1,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 1,
          ),
        ]);
        break;

      case 5:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 1,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 1,
          ),
          createEnemyUnit(
            unitName: 'Granite Guard',
            position: Position(2, 3),
            tier: 1,
          ),
        ]);
        break;

      case 6:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 1,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 1,
          ),
          createEnemyUnit(
            unitName: 'Granite Guard',
            position: Position(2, 3),
            tier: 2,
          ),
        ]);
        break;

      case 7:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 1,
          ),
          createEnemyUnit(
            unitName: 'Granite Guard',
            position: Position(2, 3),
            tier: 2,
          ),
        ]);
        break;

      case 8:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Granite Guard',
            position: Position(2, 3),
            tier: 2,
          ),
        ]);
        break;

      case 9:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 1,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 1),
            tier: 1,
          ),
        ]);
        break;

      case 10:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 1),
            tier: 1,
          ),
        ]);
        break;

      case 11:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 1),
            tier: 2,
          ),
        ]);
        break;

      case 12:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 1),
            tier: 2,
          ),
        ]);
        break;

      case 13:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Granite Guard',
            position: Position(2, 3),
            tier: 2,
          ),
        ]);
        break;

      case 14:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Granite Guard',
            position: Position(2, 3),
            tier: 2,
          ),
        ]);
        break;

      case 15:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Gearcaster',
            position: Position(2, 2),
            tier: 2,
          ),
        ]);
        break;

      case 16:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 2),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Frostscribe Mystic',
            position: Position(1, 2),
            tier: 1,
          ),
          createEnemyUnit(
            unitName: 'Borealis Arcanist',
            position: Position(0, 0),
            tier: 1,
          ),
        ]);
        break;

      case 17:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 2),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Frostscribe Mystic',
            position: Position(1, 2),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Borealis Arcanist',
            position: Position(0, 0),
            tier: 1,
          ),
        ]);
        break;

      case 18:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 2),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Frostscribe Mystic',
            position: Position(1, 2),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Borealis Arcanist',
            position: Position(0, 0),
            tier: 2,
          ),
        ]);
        break;

      case 19:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 1),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 2),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Frostscribe Mystic',
            position: Position(1, 2),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Borealis Arcanist',
            position: Position(0, 0),
            tier: 2,
          ),
        ]);
        break;

      case 20:
        team.addAll([
          createEnemyUnit(
            unitName: 'Icewall Sentinel',
            position: Position(2, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Rimebound Vanguard',
            position: Position(2, 0),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Winterblade Guardian',
            position: Position(1, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Glacier Marksman',
            position: Position(0, 1),
            tier: 3,
          ),
          createEnemyUnit(
            unitName: 'Northwind Tracker',
            position: Position(1, 0),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Snowfall Priest',
            position: Position(0, 2),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Frostscribe Mystic',
            position: Position(1, 2),
            tier: 2,
          ),
          createEnemyUnit(
            unitName: 'Borealis Arcanist',
            position: Position(0, 0),
            tier: 2,
          ),
        ]);
        break;

      default:
        break;
    }

    return team;
  }

  // Creates an enemy unit of the given name at the given position with of the given tier
  Unit createEnemyUnit({
    required String unitName,
    required Position position,
    int tier = 1,
  }) {
    final base = game_units.unitData[unitName];
    if (base == null) {
      throw Exception("Unit '$unitName' not found in unitData");
    }

    Unit unit = base.copyWith(
      id: '${unitName}_enemy_${DateTime.now().millisecondsSinceEpoch}',
      isEnemy: true,
    );

    for (int i = 1; i < tier; i++) {
      unit = unit.upgrade();
    }

    unit.isEnemy = true;
    unit.team = 1;
    unit.isOnBoard = true;
    unit.boardX = position.col;
    unit.boardY = position.row;
    unit.position = position;

    return unit;
  }

  // Creates all enemy units based off a given list of data
  List<Unit> createUnitsFromList(List<UnitData> unitDataList) {
    return unitDataList
        .map(
          (data) => createEnemyUnit(
            unitName: data.name,
            position: data.position,
            tier: data.tier,
          ),
        )
        .toList();
  }
}
