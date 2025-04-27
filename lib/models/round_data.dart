import 'package:realm_of_tactics/game_data/units.dart' as game_units;
import 'package:realm_of_tactics/models/board_position.dart';
import 'package:realm_of_tactics/models/unit.dart';

// Unit data bundled into a class
class UnitData {
  final String name;
  final Position position;
  final int tier;

  UnitData(this.name, this.position, this.tier);
}

class OpponentManager {
  OpponentManager();

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

// A set of rounds used in a map node
class RoundSet {
  final int floor;
  final List<List<UnitData>> rounds;

  RoundSet(this.floor, this.rounds);
}

// ALl the possible round sets
final List<RoundSet> globalRoundSets = [
  // Floor 1 Rounds
  RoundSet(1, [
    [UnitData('Icewall Sentinel', Position(2, 3), 1)],
    [
      UnitData('Icewall Sentinel', Position(2, 3), 1),
      UnitData('Icewall Sentinel', Position(2, 4), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 3), 1),
      UnitData('Rimebound Vanguard', Position(2, 4), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 3), 1),
      UnitData('Rimebound Vanguard', Position(2, 4), 1),
      UnitData('Icewall Sentinel', Position(2, 2), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 3), 1),
      UnitData('Rimebound Vanguard', Position(2, 4), 1),
      UnitData('Granite Guard', Position(2, 1), 1),
    ],
  ]),
  RoundSet(1, [
    [UnitData('Cloudbreaker', Position(2, 3), 1)],
    [
      UnitData('Cloudbreaker', Position(2, 3), 1),
      UnitData('Cloudbreaker', Position(2, 4), 1),
    ],
    [
      UnitData('Cloudbreaker', Position(2, 2), 1),
      UnitData('Thunder Caller', Position(0, 0), 1),
    ],
    [
      UnitData('Cloudbreaker', Position(2, 2), 1),
      UnitData('Thunder Caller', Position(0, 0), 1),
      UnitData('Thunder Caller', Position(0, 1), 1),
    ],
    [
      UnitData('Cloudbreaker', Position(2, 3), 1),
      UnitData('Thunder Caller', Position(0, 0), 1),
      UnitData('Stormcarver', Position(2, 2), 1),
    ],
  ]),

  // Floor 2 Rounds
  RoundSet(2, [
    [
      UnitData('Icewall Sentinel', Position(2, 3), 1),
      UnitData('Rimebound Vanguard', Position(2, 4), 1),
      UnitData('Granite Guard', Position(2, 1), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 3), 2),
      UnitData('Rimebound Vanguard', Position(2, 4), 1),
      UnitData('Granite Guard', Position(2, 1), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 1),
      UnitData('Rimebound Vanguard', Position(2, 1), 1),
      UnitData('Winterblade Guardian', Position(2, 2), 1),
      UnitData('Glacier Marksman', Position(0, 0), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 1),
      UnitData('Winterblade Guardian', Position(2, 2), 1),
      UnitData('Glacier Marksman', Position(0, 0), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 1),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 1),
      UnitData('Glacier Marksman', Position(0, 0), 1),
    ],
  ]),

  // Floor 3 Rounds
  RoundSet(3, [
    [
      UnitData('Icewall Sentinel', Position(2, 0), 1),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 1),
      UnitData('Glacier Marksman', Position(0, 0), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 1),
      UnitData('Glacier Marksman', Position(0, 0), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 1),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 1),
      UnitData('Glacier Marksman', Position(0, 0), 1),
      UnitData('Granite Guard', Position(2, 4), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 1),
      UnitData('Glacier Marksman', Position(0, 0), 1),
      UnitData('Granite Guard', Position(2, 4), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 2),
      UnitData('Glacier Marksman', Position(0, 0), 1),
      UnitData('Highrock Bulwark', Position(2, 3), 1),
    ],
  ]),

  // Floor 4 Rounds
  RoundSet(4, [
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Glacier Marksman', Position(0, 0), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 1),
      UnitData('Snowfall Priest', Position(0, 1), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Glacier Marksman', Position(0, 0), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 2),
      UnitData('Snowfall Priest', Position(0, 1), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Glacier Marksman', Position(0, 0), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Glacier Marksman', Position(0, 0), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 1),
      UnitData('Snowfall Priest', Position(0, 1), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Glacier Marksman', Position(0, 0), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
    ],
  ]),

  // Floor 5 Rounds
  RoundSet(5, [
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Glacier Marksman', Position(0, 0), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Glacier Marksman', Position(0, 0), 2),
      UnitData('Borealis Arcanist', Position(0, 1), 2),
      UnitData('Snowfall Priest', Position(1, 1), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Glacier Marksman', Position(0, 0), 2),
      UnitData('Borealis Arcanist', Position(0, 1), 2),
      UnitData('Snowfall Priest', Position(1, 1), 2),
      UnitData('Highrock Bulwark', Position(2, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Highrock Bulwark', Position(2, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Highrock Bulwark', Position(2, 2), 2),
    ],
  ]),

  // Floor 6 Rounds
  RoundSet(6, [
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Highrock Bulwark', Position(2, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Highrock Bulwark', Position(2, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 2),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 2),
      UnitData('Glacier Marksman', Position(0, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 2),
      UnitData('Glacier Marksman', Position(0, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 2),
    ],
  ]),

  // Floor 7 Rounds
  RoundSet(7, [
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 2),
      UnitData('Glacier Marksman', Position(0, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 2),
      UnitData('Glacier Marksman', Position(0, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 2),
    ],
  ]),

  // Floor 8 Rounds
  RoundSet(8, [
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 2),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 2),
      UnitData('Gearstep Agent', Position(1, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 2),
      UnitData('Glacier Marksman', Position(0, 2), 2),
      UnitData('Veilstrider', Position(1, 2), 1),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 2),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 2),
      UnitData('Veilstrider', Position(1, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 2),
      UnitData('Veilstrider', Position(1, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 2),
      UnitData('Blazestep Ranger', Position(1, 2), 2),
    ],
  ]),

  // Floor 9 Rounds
  RoundSet(9, [
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 2),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 3),
      UnitData('Blazestep Ranger', Position(1, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 3),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 3),
      UnitData('Blazestep Ranger', Position(1, 2), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 3),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 3),
      UnitData('Blazestep Ranger', Position(1, 2), 2),
      UnitData('Harvest Warden', Position(2, 3), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 3),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 3),
      UnitData('Blazestep Ranger', Position(1, 2), 2),
      UnitData('Hearthguard', Position(2, 3), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 3),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 3),
      UnitData('Blazestep Ranger', Position(1, 2), 2),
      UnitData('Farmland Protector', Position(2, 3), 2),
    ],
  ]),

  // Floor 10 Rounds
  RoundSet(10, [
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 2),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 3),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 3),
      UnitData('Blazestep Ranger', Position(1, 2), 2),
      UnitData('Farmland Protector', Position(2, 3), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 3),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 3),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 3),
      UnitData('Blazestep Ranger', Position(1, 2), 2),
      UnitData('Farmland Protector', Position(2, 3), 2),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 3),
      UnitData('Borealis Arcanist', Position(0, 0), 2),
      UnitData('Snowfall Priest', Position(0, 1), 3),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 3),
      UnitData('Blazestep Ranger', Position(1, 2), 2),
      UnitData('Farmland Protector', Position(2, 3), 3),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 3),
      UnitData('Borealis Arcanist', Position(0, 0), 3),
      UnitData('Snowfall Priest', Position(0, 1), 3),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 3),
      UnitData('Blazestep Ranger', Position(1, 2), 2),
      UnitData('Farmland Protector', Position(2, 3), 3),
    ],
    [
      UnitData('Icewall Sentinel', Position(2, 0), 3),
      UnitData('Rimebound Vanguard', Position(2, 1), 3),
      UnitData('Northwind Tracker', Position(1, 0), 3),
      UnitData('Frostscribe Mystic', Position(1, 1), 3),
      UnitData('Borealis Arcanist', Position(0, 0), 3),
      UnitData('Snowfall Priest', Position(0, 1), 3),
      UnitData('Winterblade Guardian', Position(2, 2), 3),
      UnitData('Glacier Marksman', Position(0, 2), 3),
      UnitData('Blazestep Ranger', Position(1, 2), 3),
      UnitData('Farmland Protector', Position(2, 3), 3),
    ],
  ]),
  // add more round sets for floors 5, 7, etc...
];
