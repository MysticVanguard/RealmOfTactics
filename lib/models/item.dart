import 'dart:math';

import '../enums/item_type.dart';
import '../game_data/items.dart';
import 'package:meta/meta.dart';
import 'package:realm_of_tactics/models/unit_stats.dart';

// A data class representing stat bonuses an item can grant a unit
@immutable
class ItemStatsBonus {
  final double bonusMaxHealth;
  final double bonusAttackDamage;
  final double bonusAttackSpeed;
  final double bonusArmor;
  final double bonusMagicResist;
  final double bonusAbilityPower;
  final double bonusCritChance;
  final double bonusCritDamage;
  final double bonusLifesteal;
  final int bonusStartingMana;
  final double bonusMovementSpeed;
  final OnAttackStats onAttackStats;
  final double bonusDamageAmp;
  final double bonusDamageReduction;
  final int bonusRange;

  final double bonusAttackDamagePercent;
  final double bonusAttackSpeedPercent;
  final double bonusAbilityPowerPercent;
  final double bonusMovementSpeedPercent;

  // Constructor for all possible stat bonus types, defaulting to 0
  const ItemStatsBonus({
    this.bonusMaxHealth = 0,
    this.bonusAttackDamage = 0,
    this.bonusAttackSpeed = 0,
    this.bonusArmor = 0,
    this.bonusMagicResist = 0,
    this.bonusAbilityPower = 0,
    this.bonusCritChance = 0,
    this.bonusCritDamage = 0,
    this.bonusLifesteal = 0,
    this.bonusStartingMana = 0,
    this.bonusMovementSpeed = 0,
    this.onAttackStats = OnAttackStats.empty,
    this.bonusAttackDamagePercent = 0,
    this.bonusAttackSpeedPercent = 0,
    this.bonusAbilityPowerPercent = 0,
    this.bonusMovementSpeedPercent = 0,
    this.bonusDamageAmp = 0,
    this.bonusDamageReduction = 0,
    this.bonusRange = 0,
  });
}

// Represents an item a unit can equip, including stats, effects, and visuals
class Item {
  final String id;
  final String name;
  final ItemType type;
  final int tier;
  final ItemStatsBonus statsBonus;
  final String? uniqueAbilityDescription;
  final String imagePath;
  final List<String> componentNames;
  final bool isForged;
  final String? requiredOrigin;
  String? ownerUnitId;

  int benchIndex = -1;

  // Constructor for an Item, with optional unique ability and components
  Item({
    required this.id,
    required this.name,
    required this.type,
    required this.tier,
    this.statsBonus = const ItemStatsBonus(),
    this.uniqueAbilityDescription,
    required this.imagePath,
    this.componentNames = const [],
    this.isForged = false,
    this.requiredOrigin,
    this.ownerUnitId,
  });

  // Whether the item is a basic component (tier 1 and not forged)
  bool get isComponent => tier == 1 && !isForged;

  // Determines if this item can be combined with another (basic and not forged, and different types)
  bool canCombineWith(Item other) {
    if (isForged || other.isForged) return false;
    if (!isComponent || !other.isComponent) return false;
    return id != other.id;
  }

  // Attempts to combine this item with another and return the resulting item
  Item? combine(Item other) {
    if (isForged || other.isForged) return null;
    if (!canCombineWith(other)) return null;
    return getCombinedItem(this, other);
  }

  // Creates a copy of this item, optionally modifying fields
  Item copyWith({
    String? id,
    String? name,
    ItemType? type,
    int? tier,
    ItemStatsBonus? statsBonus,
    String? uniqueAbilityDescription,
    String? imagePath,
    List<String>? componentNames,
    int? benchIndex,
    bool? isForged,
    String? requiredOrigin,
  }) {
    bool explicitlyNullOrigin =
        requiredOrigin == null && this.requiredOrigin != null;

    return Item(
      id:
          '${this.id}_${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000000)}',
      name: name ?? this.name,
      type: type ?? this.type,
      tier: tier ?? this.tier,
      statsBonus: statsBonus ?? this.statsBonus,
      uniqueAbilityDescription:
          uniqueAbilityDescription ?? this.uniqueAbilityDescription,
      imagePath: imagePath ?? this.imagePath,
      componentNames: componentNames ?? List.from(this.componentNames),
      isForged: isForged ?? this.isForged,
      requiredOrigin:
          explicitlyNullOrigin ? null : (requiredOrigin ?? this.requiredOrigin),
    )..benchIndex = benchIndex ?? this.benchIndex;
  }

  // Returns a fresh instance of an item to use where needed
  Item? getItemById(String id) {
    final itemEntry = allItems.entries.firstWhere(
      (entry) => entry.value.id == id,
      orElse:
          () => allItems.entries.firstWhere(
            (entry) => entry.key == id,
            orElse:
                () => MapEntry(
                  'not_found',
                  Item(
                    id: 'not_found',
                    name: 'Not Found',
                    type: ItemType.trinket,
                    tier: 0,
                    imagePath: '',
                  ),
                ),
          ),
    );

    if (itemEntry.key == 'not_found') return null;

    return itemEntry.value.copyWith(
      id:
          '${itemEntry.value.id}_${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000000)}',
    );
  }

  // Takes 2 tier 1 items and returns a tier 2 item that comes from their combination
  Item? getCombinedItem(Item item1, Item item2) {
    if (!item1.isComponent || !item2.isComponent) return null;

    // Create a sorted list of component names to match against
    final pair = [item1.name, item2.name]..sort();

    final combinedEntry = allItems.entries.firstWhere(
      (entry) {
        final item = entry.value;
        if (item.tier != 2 || item.componentNames.length != 2) return false;

        final comps = [...item.componentNames]..sort();
        return pair[0] == comps[0] && pair[1] == comps[1];
      },
      orElse:
          () => MapEntry(
            'not_found',
            Item(
              id: 'not_found',
              name: 'Not Found',
              type: ItemType.trinket,
              tier: 0,
              imagePath: '',
            ),
          ),
    );

    if (combinedEntry.key == 'not_found') return null;

    return combinedEntry.value.copyWith(
      id:
          '${combinedEntry.value.id}_${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000000)}',
    );
  }
}
