import 'package:realm_of_tactics/enums/item_type.dart';
import 'package:realm_of_tactics/game_data/items.dart';
import 'package:realm_of_tactics/game_data/units.dart' as game_units;
import 'package:realm_of_tactics/models/board_position.dart';
import 'package:realm_of_tactics/models/item.dart';
import 'package:realm_of_tactics/models/unit.dart';

// Unit data bundled into a class
class UnitData {
  final String name;
  final Position position;
  final int tier;
  final List<Item>? items;

  UnitData(this.name, this.position, this.tier, this.items);
}

class OpponentManager {
  OpponentManager();

  // Creates an enemy unit of the given name at the given position with of the given tier
  Unit createEnemyUnit({
    required String unitName,
    required Position position,
    int tier = 1,
    List<Item>? items,
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
    List<ItemType> types = [ItemType.weapon, ItemType.armor, ItemType.trinket];
    print(items);
    if (items != null) {
      for (final item in items) {
        print(item.name);
        item.type = types.removeAt(0);
        bool equipped = unit.equipItem(item, enemyEquip: true);
        print(equipped);
      }
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
            items: data.items,
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
    [UnitData("Winterblade Guardian", Position(2, 2), 2, [])],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, []),
      UnitData("Cloudbreaker", Position(2, 3), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Cloudbreaker", Position(2, 3), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Cloudbreaker", Position(2, 3), 2, []),
    ],
  ]),

  RoundSet(2, [
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Cloudbreaker", Position(2, 3), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Cloudbreaker", Position(2, 3), 2, []),
      UnitData("Icewall Sentinel", Position(2, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Cloudbreaker", Position(2, 3), 2, []),
      UnitData("Icewall Sentinel", Position(2, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Cloudbreaker", Position(2, 3), 2, []),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Cloudbreaker", Position(2, 3), 2, []),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
    ],
  ]),
  RoundSet(3, [
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Cloudbreaker", Position(2, 3), 2, []),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Cloudbreaker", Position(2, 3), 2, []),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, []),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
  ]),
  RoundSet(4, [
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, []),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, []),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
    ],
  ]),
  RoundSet(5, [
    [
      UnitData("Winterblade Guardian", Position(2, 2), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, []),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
    ],
  ]),
  RoundSet(6, [
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 3), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 1), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, []),
      UnitData("Icewall Sentinel", Position(2, 0), 2, []),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, []),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
    ],
  ]),
  RoundSet(7, [
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, []),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, []),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
    ],
  ]),
  RoundSet(8, [
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
  ]),
  RoundSet(9, [
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, []),
      UnitData("Rimebound Vanguard", Position(2, 2), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, []),
      UnitData("Glacier Marksman", Position(0, 1), 3, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, []),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 3, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
    ],
  ]),
  RoundSet(10, [
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, []),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 3, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, []),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, []),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, []),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, []),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
  ]),
  RoundSet(11, [
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, []),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, []),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, []),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, []),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
  ]),
  RoundSet(12, [
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, []),
    ],
  ]),
  RoundSet(13, [
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
        allItems["wardbreaker_gem"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
    ],
  ]),
  RoundSet(14, [
    [
      UnitData("Winterblade Guardian", Position(2, 1), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
        allItems["wardbreaker_gem"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
        allItems["wardbreaker_gem"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
        allItems["wardbreaker_gem"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 3, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
        allItems["wardbreaker_gem"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 3, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
        allItems["wardbreaker_gem"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
    ],
  ]),
  RoundSet(15, [
    [
      UnitData("Winterblade Guardian", Position(2, 1), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 3, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
        allItems["wardbreaker_gem"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["battle_plate"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 3, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 3, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 3, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
        allItems["wardbreaker_gem"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 2, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, []),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 2, []),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 3, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 3, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
        allItems["wardbreaker_gem"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 3, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 3, []),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, [
        allItems["titan_hide"]!.copyWith(),
        allItems["bulwarks_crown"]!.copyWith(),
        allItems["blood_vessel"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 0), 3, []),
      UnitData("Glacier Marksman", Position(0, 2), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bladed_repeater"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 0), 3, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 3, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 2, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
        allItems["wardbreaker_gem"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 3, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, []),
      UnitData("Rimebound Vanguard", Position(2, 2), 2, []),
      UnitData("Icewall Sentinel", Position(2, 0), 2, []),
      UnitData("Glacier Marksman", Position(0, 2), 2, []),
      UnitData("Snowfall Priest", Position(0, 0), 3, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 1), 3, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["twinfang_blade"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Borealis Arcanist", Position(0, 1), 3, [
        allItems["chaos_prism"]!.copyWith(),
        allItems["focused_mind"]!.copyWith(),
        allItems["wardbreaker_gem"]!.copyWith(),
      ]),
      UnitData("Frostscribe Mystic", Position(1, 0), 3, [
        allItems["focused_mind"]!.copyWith(),
        allItems["vital_focus"]!.copyWith(),
        allItems["runed_helm"]!.copyWith(),
      ]),
    ],
  ]),
];
