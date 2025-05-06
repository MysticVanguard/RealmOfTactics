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
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
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
  ]),
  RoundSet(2, [
    [
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Cloudbreaker", Position(2, 3), 2, []),
      UnitData("Icewall Sentinel", Position(2, 1), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 0), 1, []),
      UnitData("Icewall Sentinel", Position(2, 2), 1, []),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 0), 1, []),
      UnitData("Icewall Sentinel", Position(2, 2), 2, []),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 0), 2, []),
      UnitData("Icewall Sentinel", Position(2, 2), 1, [
        allItems["wicked_brooch"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 2), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 3), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 0), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
    ],
  ]),
  RoundSet(3, [
    [
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 0), 2, []),
      UnitData("Icewall Sentinel", Position(2, 2), 2, [
        allItems["wicked_brooch"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 0), 2, []),
      UnitData("Icewall Sentinel", Position(2, 2), 2, [
        allItems["wicked_brooch"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, []),
    ],
    [
      UnitData("Winterblade Guardian", Position(2, 1), 3, [
        allItems["runed_sabre"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["psychic_edge"]!.copyWith(),
      ]),
      UnitData("Glacier Marksman", Position(0, 0), 2, []),
      UnitData("Icewall Sentinel", Position(2, 2), 3, [
        allItems["wicked_brooch"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, []),
    ],
    [
      UnitData("Glacier Marksman", Position(0, 0), 3, []),
      UnitData("Rimebound Vanguard", Position(2, 0), 3, []),
    ],
    [
      UnitData("Glacier Marksman", Position(0, 0), 2, []),
      UnitData("Glacier Marksman", Position(0, 1), 2, []),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, []),
      UnitData("Rimebound Vanguard", Position(2, 1), 2, []),
      UnitData("Icewall Sentinel", Position(2, 2), 2, []),
      UnitData("Icewall Sentinel", Position(2, 3), 2, []),
      UnitData("Winterblade Guardian", Position(2, 4), 2, []),
      UnitData("Winterblade Guardian", Position(2, 5), 2, []),
    ],
  ]),

  RoundSet(4, [
    [
      UnitData("Glacier Marksman", Position(0, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, [
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 2), 2, [
        allItems["mystic_harness"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 1), 1, []),
      UnitData("Northwind Tracker", Position(1, 0), 1, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Glacier Marksman", Position(0, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, [
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 2), 2, [
        allItems["mystic_harness"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 1), 1, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 0), 1, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Glacier Marksman", Position(0, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, [
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 2), 2, [
        allItems["mystic_harness"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 1), 1, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 0), 1, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Glacier Marksman", Position(0, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 1, [
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 2), 2, [
        allItems["mystic_harness"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 1), 1, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Glacier Marksman", Position(0, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 1, [
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 2), 2, [
        allItems["mystic_harness"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 1), 1, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
  ]),

  RoundSet(6, [
    [
      UnitData("Glacier Marksman", Position(0, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 1, [
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 2), 2, [
        allItems["mystic_harness"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 1), 1, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Glacier Marksman", Position(0, 0), 1, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 1, [
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 2), 2, [
        allItems["mystic_harness"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 1), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
    [
      UnitData("Glacier Marksman", Position(0, 0), 1, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, [
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 2), 2, [
        allItems["mystic_harness"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 1), 1, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 1), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],

    [
      UnitData("Borealis Arcanist", Position(0, 1), 2, []),
      UnitData("Frostscribe Mystic", Position(1, 1), 2, []),
      UnitData("Glacier Marksman", Position(0, 0), 1, []),
      UnitData("Glacier Marksman", Position(0, 2), 1, []),
      UnitData("Icewall Sentinel", Position(1, 0), 1, []),
      UnitData("Icewall Sentinel", Position(1, 2), 1, []),
      UnitData("Winterblade Guardian", Position(2, 0), 1, []),
      UnitData("Winterblade Guardian", Position(2, 1), 1, []),
      UnitData("Rimebound Vanguard", Position(2, 2), 1, []),
    ],
  ]),

  RoundSet(7, [
    [
      UnitData("Glacier Marksman", Position(0, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
      UnitData("Rimebound Vanguard", Position(2, 0), 2, [
        allItems["runed_helm"]!.copyWith(),
      ]),
      UnitData("Icewall Sentinel", Position(2, 2), 2, [
        allItems["mystic_harness"]!.copyWith(),
      ]),
      UnitData("Winterblade Guardian", Position(2, 1), 2, [
        allItems["runed_sabre"]!.copyWith(),
      ]),
      UnitData("Snowfall Priest", Position(0, 1), 2, [
        allItems["focused_mind"]!.copyWith(),
      ]),
      UnitData("Northwind Tracker", Position(1, 0), 2, [
        allItems["bloodpiercer"]!.copyWith(),
      ]),
    ],
  ]),
];
