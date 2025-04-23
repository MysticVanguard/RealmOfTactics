import '../models/item.dart';
import '../enums/item_type.dart';
import 'package:realm_of_tactics/models/unit_stats.dart';

// All items so that random items can be acquired throughout the game and items can be combined
final Map<String, Item> allItems = {
  'basic_sword': Item(
    id: 'item_basic_sword',
    name: 'Basic Sword',
    type: ItemType.weapon,
    tier: 1,
    imagePath: 'assets/images/items/basic_sword.png',
    statsBonus: const ItemStatsBonus(bonusAttackDamagePercent: 0.10),
  ),

  'basic_vest': Item(
    id: 'item_basic_vest',
    name: 'Basic Vest',
    type: ItemType.armor,
    tier: 1,
    imagePath: 'assets/images/items/basic_vest.png',
    statsBonus: const ItemStatsBonus(bonusMaxHealth: 150),
  ),

  'spiked_vest': Item(
    id: 'item_spiked_vest',
    name: 'Spiked Vest',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/spiked_vest.png',
    statsBonus: const ItemStatsBonus(
      bonusMaxHealth: 300,
      bonusAttackDamagePercent: 0.20,
    ),
    componentNames: ['Basic Sword', 'Basic Vest'],
    uniqueAbilityDescription:
        'Briefly stun attackers when hit (Not Implemented)',
  ),

  'forged_zephyr_blade': Item(
    id: 'item_forged_zephyr',
    name: 'Zephyr Blade',
    type: ItemType.weapon,
    tier: 3,
    isForged: true,
    requiredOrigin: 'Forgeheart',
    imagePath: 'assets/images/items/forged_zephyr_blade.png',
    statsBonus: const ItemStatsBonus(bonusAttackSpeedPercent: 0.50),
    uniqueAbilityDescription:
        'Ability: On attack, gain 5 Ability Power (Not Implemented)',
  ),

  'forged_archmage_staff': Item(
    id: 'item_forged_archmage',
    name: 'Archmage Staff',
    type: ItemType.weapon,
    tier: 3,
    isForged: true,
    requiredOrigin: 'Forgeheart',
    imagePath: 'assets/images/items/forged_archmage_staff.png',
    statsBonus: const ItemStatsBonus(
      bonusAbilityPower: 20,
      onAttackStats: OnAttackStats(manaGain: 10),
    ),
    uniqueAbilityDescription:
        'Ability: After using an ability for the first time, gain 100 Ability Power (Not Implemented)',
  ),

  'forged_spirit_helm': Item(
    id: 'item_forged_spirithelm',
    name: 'Spirit Helm',
    type: ItemType.armor,
    tier: 3,
    isForged: true,
    requiredOrigin: 'Forgeheart',
    imagePath: 'assets/images/items/forged_spirit_helm.png',
    statsBonus: const ItemStatsBonus(bonusMaxHealth: 400, bonusMagicResist: 50),
    uniqueAbilityDescription:
        'Ability: After using an ability, Heal for 50% Mana Spent (Not Implemented)',
  ),

  'forged_guardian_plate': Item(
    id: 'item_forged_guardian',
    name: 'Guardian Plate',
    type: ItemType.armor,
    tier: 3,
    isForged: true,
    requiredOrigin: 'Forgeheart',
    imagePath: 'assets/images/items/forged_guardian_plate.png',
    statsBonus: const ItemStatsBonus(
      bonusArmor: 50,
      bonusMaxHealth: 100,
      bonusDamageReduction: 0.10,
    ),
    uniqueAbilityDescription:
        'Ability: Combat Start - gain a shield equal to 5 times your Ability Power (Not Implemented)',
  ),

  'forged_bloodthirst_locket': Item(
    id: 'item_forged_bloodlocket',
    name: 'Bloodthirst Locket',
    type: ItemType.trinket,
    tier: 3,
    isForged: true,
    requiredOrigin: 'Forgeheart',
    imagePath: 'assets/images/items/forged_bloodthirst_locket.png',
    statsBonus: const ItemStatsBonus(bonusLifesteal: 0.10, bonusMaxHealth: 200),
    uniqueAbilityDescription:
        'Ability: After killing an enemy, gain 100 Max Health for this combat (Not Implemented)',
  ),

  'forged_jeweled_scope': Item(
    id: 'item_forged_jeweledscope',
    name: 'Jeweled Scope',
    type: ItemType.trinket,
    tier: 3,
    isForged: true,
    requiredOrigin: 'Forgeheart',
    imagePath: 'assets/images/items/forged_jeweled_scope.png',
    statsBonus: const ItemStatsBonus(
      bonusAbilityPower: 30,
      bonusCritChance: 0.25,
    ),
    uniqueAbilityDescription:
        '+1 Range. Ability: Your Ability can critically strike (Not Implemented)',
  ),
};

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
    id: '${itemEntry.value.id}_${DateTime.now().millisecondsSinceEpoch}',
  );
}

// Takes 2 tier 1 items and returns a tier 2 item that comes from their combination
Item? getCombinedItem(Item item1, Item item2) {
  if (!item1.isComponent || !item2.isComponent) return null;

  final combinedEntry = allItems.entries.firstWhere(
    (entry) =>
        entry.value.tier == 2 &&
        entry.value.componentNames.contains(item1.name) &&
        entry.value.componentNames.contains(item2.name),
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
    id: '${combinedEntry.value.id}_${DateTime.now().millisecondsSinceEpoch}',
  );
}
