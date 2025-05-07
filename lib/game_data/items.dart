import '../models/item.dart';
import '../enums/item_type.dart';

// All items so that random items can be acquired throughout the game and items can be combined
final Map<String, Item> allItems = {
  'item_basic_sword': Item(
    id: 'item_basic_sword',
    name: 'Basic Sword',
    type: ItemType.weapon,
    tier: 1,
    imagePath: 'assets/images/items/basic_sword.png',
    statsBonus: const ItemStatsBonus(bonusAttackDamagePercent: 0.10),
  ),

  'item_basic_tunic': Item(
    id: 'item_basic_tunic',
    name: 'Basic Tunic',
    type: ItemType.armor,
    tier: 1,
    imagePath: 'assets/images/items/basic_vest.png',
    statsBonus: const ItemStatsBonus(bonusMaxHealth: 150),
  ),

  'item_basic_bow': Item(
    id: 'item_basic_bow',
    name: 'Basic Bow',
    type: ItemType.weapon,
    tier: 1,
    imagePath: 'assets/images/items/basic_vest.png',
    statsBonus: const ItemStatsBonus(bonusAttackSpeedPercent: 0.10),
  ),

  'item_basic_wand': Item(
    id: 'item_basic_wand',
    name: 'Basic Wand',
    type: ItemType.weapon,
    tier: 1,
    imagePath: 'assets/images/items/basic_vest.png',
    statsBonus: const ItemStatsBonus(bonusAbilityPower: 10),
  ),

  'item_basic_dagger': Item(
    id: 'item_basic_dagger',
    name: 'Basic Dagger',
    type: ItemType.trinket,
    tier: 1,
    imagePath: 'assets/images/items/basic_vest.png',
    statsBonus: const ItemStatsBonus(bonusCritChance: 0.15),
  ),

  'item_basic_orb': Item(
    id: 'item_basic_orb',
    name: 'Basic Orb',
    type: ItemType.trinket,
    tier: 1,
    imagePath: 'assets/images/items/basic_vest.png',
    statsBonus: const ItemStatsBonus(bonusStartingMana: 10),
  ),

  'item_basic_locket': Item(
    id: 'item_basic_locket',
    name: 'Basic Locket',
    type: ItemType.trinket,
    tier: 1,
    imagePath: 'assets/images/items/basic_vest.png',
    statsBonus: const ItemStatsBonus(bonusLifesteal: 0.10),
  ),

  'item_basic_helmet': Item(
    id: 'item_basic_helmet',
    name: 'Basic Helmet',
    type: ItemType.armor,
    tier: 1,
    imagePath: 'assets/images/items/basic_vest.png',
    statsBonus: const ItemStatsBonus(bonusArmor: 10),
  ),

  'item_basic_armguard': Item(
    id: 'item_basic_armguard',
    name: 'Basic Armguard',
    type: ItemType.armor,
    tier: 1,
    imagePath: 'assets/images/items/basic_vest.png',
    statsBonus: const ItemStatsBonus(bonusMagicResist: 10),
  ),

  'twinfang_blade': Item(
    id: 'item_twinfang_blade',
    name: 'Twinfang Blade',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Sword', 'Basic Sword'],
    statsBonus: const ItemStatsBonus(bonusAttackDamagePercent: 0.55),
    uniqueAbilityDescription:
        'Deal 15% Bonus AD to all enemies adjacent to the target on attack.',
  ),

  'bladed_repeater': Item(
    id: 'item_bladed_repeater',
    name: 'Bladed Repeater',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Sword', 'Basic Bow'],
    statsBonus: const ItemStatsBonus(
      bonusAttackDamagePercent: 0.25,
      bonusAttackSpeedPercent: 0.40,
    ),
    uniqueAbilityDescription: 'Every third attack deals 50% bonus damage.',
  ),

  'arcblade': Item(
    id: 'item_arcblade',
    name: 'Arcblade',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Sword', 'Basic Wand'],
    statsBonus: const ItemStatsBonus(
      bonusAttackDamagePercent: 0.10,
      bonusAbilityPower: 10,
      bonusMagicResist: 40,
    ),
    uniqueAbilityDescription:
        'Attacks and abilities reduce healing of enemies hit.',
  ),

  'bloodpiercer': Item(
    id: 'item_bloodpiercer',
    name: 'Bloodpiercer',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Sword', 'Basic Dagger'],
    statsBonus: const ItemStatsBonus(
      bonusAttackDamagePercent: 0.25,
      bonusCritChance: 0.50,
    ),
    uniqueAbilityDescription: 'Ability damage can critically strike.',
  ),

  'runed_sabre': Item(
    id: 'item_runed_sabre',
    name: 'Runed Sabre',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Sword', 'Basic Orb'],
    statsBonus: const ItemStatsBonus(
      bonusAttackDamagePercent: 0.20,
      bonusStartingMana: 20,
      bonusArmor: 20,
    ),
    uniqueAbilityDescription: 'Gain 20% extra mana.',
  ),

  'vampiric_blade': Item(
    id: 'item_vampiric_blade',
    name: 'Vampiric Blade',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Sword', 'Basic Locket'],
    statsBonus: const ItemStatsBonus(
      bonusAttackDamagePercent: 0.25,
      bonusLifesteal: 0.20,
      bonusMagicResist: 20,
    ),
    uniqueAbilityDescription:
        'Overhealing creates a temporary shield (up to 10% max HP).',
  ),

  'tempest_string': Item(
    id: 'item_tempest_string',
    name: 'Tempest String',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Bow', 'Basic Bow'],
    statsBonus: const ItemStatsBonus(bonusAttackSpeedPercent: 0.25),
    uniqueAbilityDescription: 'Gain 3% Attack Speed on attack.',
  ),

  'spellshot_launcher': Item(
    id: 'item_spellshot_launcher',
    name: 'Spellshot Launcher',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Bow', 'Basic Wand'],
    statsBonus: const ItemStatsBonus(
      bonusAttackSpeedPercent: 0.30,
      bonusAbilityPower: 30,
    ),
    uniqueAbilityDescription:
        'Each attack has a 50% chance to fire a magic bolt dealing 33% AP damage.',
  ),

  'whirlwind_knives': Item(
    id: 'item_whirlwind_knives',
    name: 'Whirlwind Knives',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Bow', 'Basic Dagger'],
    statsBonus: const ItemStatsBonus(
      bonusAttackSpeedPercent: 0.50,
      bonusCritChance: 0.50,
    ),
    uniqueAbilityDescription: 'Ability damage can critically strike.',
  ),

  'channeling_bow': Item(
    id: 'item_channeling_bow',
    name: 'Channeling Bow',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Bow', 'Basic Orb'],
    statsBonus: const ItemStatsBonus(
      bonusAttackSpeedPercent: 0.20,
      bonusStartingMana: 20,
      bonusMaxHealth: 300,
    ),
    uniqueAbilityDescription: 'Heal for 500% of Attack Speed every second.',
  ),

  'leeching_arrows': Item(
    id: 'item_leeching_arrows',
    name: 'Leeching Arrows',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Bow', 'Basic Locket'],
    statsBonus: const ItemStatsBonus(
      bonusAttackSpeedPercent: 0.40,
      bonusLifesteal: 0.20,
    ),
    uniqueAbilityDescription:
        'Heal lowest health ally for 1% of max HP on attack.',
  ),
  'twin_conduits': Item(
    id: 'item_twin_conduits',
    name: 'Twin Conduits',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Wand', 'Basic Wand'],
    statsBonus: const ItemStatsBonus(bonusAbilityPower: 60),
    uniqueAbilityDescription:
        'Enemies damaged by abilities lose 10% Damage Reduction.',
  ),

  'chaos_prism': Item(
    id: 'item_chaos_prism',
    name: 'Chaos Prism',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Wand', 'Basic Dagger'],
    statsBonus: const ItemStatsBonus(
      bonusAbilityPower: 25,
      bonusCritChance: 0.50,
    ),
    uniqueAbilityDescription: 'Ability damage can critically strike.',
  ),

  'focused_mind': Item(
    id: 'item_focused_mind',
    name: 'Focused Mind',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Wand', 'Basic Orb'],
    statsBonus: const ItemStatsBonus(
      bonusAbilityPower: 45,
      bonusStartingMana: 30,
    ),
    uniqueAbilityDescription: 'Gain 30% Max Mana after every spell cast.',
  ),

  'bloodstaff': Item(
    id: 'item_bloodstaff',
    name: 'Bloodstaff',
    type: ItemType.weapon,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Wand', 'Basic Locket'],
    statsBonus: const ItemStatsBonus(
      bonusAbilityPower: 30,
      bonusLifesteal: 0.20,
    ),
    uniqueAbilityDescription:
        'Heal lowest health ally for Lifesteal% of Damage dealt.',
  ),

  'shadow_fang': Item(
    id: 'item_shadow_fang',
    name: 'Shadow Fang',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Dagger', 'Basic Dagger'],
    statsBonus: const ItemStatsBonus(
      bonusCritChance: 0.25,
      bonusCritDamage: 0.30,
    ),
    uniqueAbilityDescription: 'Gain 5% Crit Damage after casting your ability.',
  ),

  'psychic_edge': Item(
    id: 'item_psychic_edge',
    name: 'Psychic Edge',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Dagger', 'Basic Orb'],
    statsBonus: const ItemStatsBonus(
      bonusCritChance: 0.25,
      bonusStartingMana: 20,
    ),
    uniqueAbilityDescription: 'Gain 5 mana on crit (Cooldown 1s).',
  ),

  'blood_charm': Item(
    id: 'item_blood_charm',
    name: 'Blood Charm',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Dagger', 'Basic Locket'],
    statsBonus: const ItemStatsBonus(
      bonusCritChance: 0.25,
      bonusLifesteal: 0.10,
    ),
    uniqueAbilityDescription: 'Crits restore 3% missing HP.',
  ),

  'spiked_visor': Item(
    id: 'item_spiked_visor',
    name: 'Spiked Visor',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Dagger', 'Basic Helmet'],
    statsBonus: const ItemStatsBonus(bonusCritChance: 0.25, bonusArmor: 30),
    uniqueAbilityDescription:
        'Gain 25% more Crit Chance when shielded for 5s. You can critically shield.',
  ),

  'wardbreaker_gem': Item(
    id: 'item_wardbreaker_gem',
    name: 'Wardbreaker Gem',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Dagger', 'Basic Armguard'],
    statsBonus: const ItemStatsBonus(
      bonusCritChance: 0.25,
      bonusMagicResist: 10,
      bonusAbilityPower: 35,
    ),
    uniqueAbilityDescription: 'Crits remove 10 MR from enemies hit for 3s.',
  ),

  'wicked_brooch': Item(
    id: 'item_wicked_brooch',
    name: 'Wicked Brooch',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Dagger', 'Basic Tunic'],
    statsBonus: const ItemStatsBonus(bonusArmor: 30, bonusMaxHealth: 300),
    uniqueAbilityDescription:
        'Gain a 5% Max Health shield when you are hit with a crit (Cooldown 3s).',
  ),

  'overflow_core': Item(
    id: 'item_overflow_core',
    name: 'Overflow Core',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Orb', 'Basic Orb'],
    statsBonus: const ItemStatsBonus(bonusStartingMana: 40),
    uniqueAbilityDescription:
        'Killing a unit grants 10 Mana and 5% Damage Amp.',
  ),

  'resonant_focus': Item(
    id: 'item_resonant_focus',
    name: 'Resonant Focus',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Orb', 'Basic Locket'],
    statsBonus: const ItemStatsBonus(
      bonusStartingMana: 20,
      bonusMaxHealth: 100,
      bonusAbilityPower: 40,
    ),
    uniqueAbilityDescription: 'Heal the lowest health ally for 50% AP on cast.',
  ),

  'aether_helm': Item(
    id: 'item_aether_helm',
    name: 'Aether Helm',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Orb', 'Basic Helmet'],
    statsBonus: const ItemStatsBonus(bonusStartingMana: 20, bonusArmor: 20),
    uniqueAbilityDescription:
        'Gain 30 Armor for 3s after casting your ability.',
  ),

  'mystic_charm': Item(
    id: 'item_mystic_charm',
    name: 'Mystic Charm',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Orb', 'Basic Armguard'],
    statsBonus: const ItemStatsBonus(
      bonusStartingMana: 20,
      bonusMagicResist: 15,
      bonusAttackDamagePercent: .30,
    ),
    uniqueAbilityDescription: 'Casting abilities gives a 100 Health shield.',
  ),

  'vital_core': Item(
    id: 'item_vital_core',
    name: 'Vital Core',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Orb', 'Basic Tunic'],
    statsBonus: const ItemStatsBonus(
      bonusStartingMana: 20,
      bonusMaxHealth: 150,
      bonusMagicResist: 30,
    ),
    uniqueAbilityDescription:
        'Heal 5% of missing HP after casting your ability.',
  ),

  'eternal_charm': Item(
    id: 'item_eternal_charm',
    name: 'Eternal Charm',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Locket', 'Basic Locket'],
    statsBonus: const ItemStatsBonus(
      bonusLifesteal: 0.30,
      bonusDamageAmp: 0.10,
    ),
    uniqueAbilityDescription: 'Lifesteal is doubled below 30% HP.',
  ),

  'warlock_talisman': Item(
    id: 'item_warlock_talisman',
    name: 'Warlock Talisman',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Locket', 'Basic Helmet'],
    statsBonus: const ItemStatsBonus(
      bonusLifesteal: 0.20,
      bonusArmor: 20,
      bonusAttackDamagePercent: .20,
    ),
    uniqueAbilityDescription: 'Deal 50% of heals to the current target.',
  ),

  'darkbinding_charm': Item(
    id: 'item_darkbinding_charm',
    name: 'Darkbinding Charm',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Locket', 'Basic Armguard'],
    statsBonus: const ItemStatsBonus(
      bonusLifesteal: 0.10,
      bonusMagicResist: 10,
      bonusAbilityPower: 30,
    ),
    uniqueAbilityDescription: 'Heals gain 5 AP for 2s.',
  ),

  'blood_vessel': Item(
    id: 'item_blood_vessel',
    name: 'Blood Vessel',
    type: ItemType.trinket,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Locket', 'Basic Tunic'],
    statsBonus: const ItemStatsBonus(bonusLifesteal: 0.10, bonusMaxHealth: 300),
    uniqueAbilityDescription: 'Heal 3% max HP every 2s while above 60% health.',
  ),

  'iron_dome': Item(
    id: 'item_iron_dome',
    name: 'Iron Dome',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Helmet', 'Basic Helmet'],
    statsBonus: const ItemStatsBonus(bonusArmor: 60),
    uniqueAbilityDescription: 'Reduce physical damage taken by 10%.',
  ),

  'balanced_plate': Item(
    id: 'item_balanced_plate',
    name: 'Balanced Plate',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Helmet', 'Basic Armguard'],
    statsBonus: const ItemStatsBonus(bonusArmor: 20, bonusMagicResist: 20),
    uniqueAbilityDescription:
        'The first time you drop below 50% Max Health, gain 50 Armor and MR.',
  ),

  'bulwarks_crown': Item(
    id: 'item_bulwarks_crown',
    name: 'Bulwark’s Crown',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Helmet', 'Basic Tunic'],
    statsBonus: const ItemStatsBonus(bonusArmor: 40, bonusMaxHealth: 300),
    uniqueAbilityDescription:
        'After taking damage, gain a 400 HP shield (5s cooldown).',
  ),

  'bladed_helm': Item(
    id: 'item_bladed_helm',
    name: 'Bladed Helm',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Helmet', 'Basic Sword'],
    statsBonus: const ItemStatsBonus(
      bonusArmor: 20,
      bonusAttackDamagePercent: 0.40,
    ),
    uniqueAbilityDescription:
        'Gain Immunity to Stuns for 10 seconds at the start of combat.',
  ),

  'swift_helm': Item(
    id: 'item_swift_helm',
    name: 'Swift Helm',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Helmet', 'Basic Bow'],
    statsBonus: const ItemStatsBonus(
      bonusArmor: 30,
      bonusAttackSpeedPercent: 0.30,
    ),
    uniqueAbilityDescription:
        'Remove 20% Armor from enemies hit by attacks and abilities (Does not stack).',
  ),

  'runed_helm': Item(
    id: 'item_runed_helm',
    name: 'Runed Helm',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Helmet', 'Basic Wand'],
    statsBonus: const ItemStatsBonus(bonusArmor: 30, bonusAbilityPower: 40),
    uniqueAbilityDescription:
        'Gain a 300% AP Health shield at the start of combat.',
  ),

  'nullplate': Item(
    id: 'item_nullplate',
    name: 'Nullplate',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Armguard', 'Basic Armguard'],
    statsBonus: const ItemStatsBonus(bonusMagicResist: 40),
    uniqueAbilityDescription: 'After taking damage, gain 1 MR (Max 60).',
  ),

  'mystic_wrap': Item(
    id: 'item_mystic_wrap',
    name: 'Mystic Wrap',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Armguard', 'Basic Tunic'],
    statsBonus: const ItemStatsBonus(bonusMagicResist: 30, bonusMaxHealth: 300),
    uniqueAbilityDescription: 'Heal for 15% of blocked damage.',
  ),

  'guarded_saber': Item(
    id: 'item_guarded_saber',
    name: 'Guarded Saber',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Armguard', 'Basic Sword'],
    statsBonus: const ItemStatsBonus(
      bonusMagicResist: 20,
      bonusAttackDamagePercent: 0.40,
    ),
    uniqueAbilityDescription:
        'Gain 10% of total AD % AD at the start of combat.',
  ),

  'mystic_harness': Item(
    id: 'item_mystic_harness',
    name: 'Mystic Harness',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Armguard', 'Basic Bow'],
    statsBonus: const ItemStatsBonus(
      bonusMagicResist: 30,
      bonusAttackSpeedPercent: 0.20,
    ),
    uniqueAbilityDescription: 'Attacks grant 5 MR and 5 Armor (Max 50).',
  ),

  'magebane_plate': Item(
    id: 'item_magebane_plate',
    name: 'Magebane Plate',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Armguard', 'Basic Wand'],
    statsBonus: const ItemStatsBonus(
      bonusMagicResist: 30,
      bonusAbilityPower: 20,
      bonusMaxHealth: 100,
    ),
    uniqueAbilityDescription:
        "Attacks and abilities reduce hit enemies' MR by 20%. (Does Not Stack)",
  ),

  'titan_hide': Item(
    id: 'item_titan_hide',
    name: 'Titan Hide',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Tunic', 'Basic Tunic'],
    statsBonus: const ItemStatsBonus(bonusMaxHealth: 600),
    uniqueAbilityDescription:
        'Gain 10% damage resistance while above 60% health.',
  ),

  'battle_plate': Item(
    id: 'item_battle_plate',
    name: 'Battle Plate',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Tunic', 'Basic Sword'],
    statsBonus: const ItemStatsBonus(
      bonusMaxHealth: 300,
      bonusAttackDamagePercent: 0.30,
      bonusArmor: 10,
    ),
    uniqueAbilityDescription: 'Gain 10% lifesteal while below 50% HP.',
  ),

  'hunters_coat': Item(
    id: 'item_hunters_coat',
    name: 'Hunter’s Coat',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Tunic', 'Basic Bow'],
    statsBonus: const ItemStatsBonus(
      bonusMaxHealth: 400,
      bonusAttackSpeedPercent: 0.20,
    ),
    uniqueAbilityDescription:
        'Gain 1% Attack Speed, 1% Attack Damage, and 1 AP when taking damage (up to 20%).',
  ),

  'vital_focus': Item(
    id: 'item_vital_focus',
    name: 'Vital Focus',
    type: ItemType.armor,
    tier: 2,
    imagePath: 'assets/images/items/basic_vest.png',
    componentNames: ['Basic Tunic', 'Basic Wand'],
    statsBonus: const ItemStatsBonus(
      bonusMaxHealth: 200,
      bonusAbilityPower: 40,
    ),
    uniqueAbilityDescription: 'Gain 10 AP after casting your ability.',
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
    uniqueAbilityDescription: 'On attack, gain 5 Ability Power.',
  ),

  'forged_spirit_helm': Item(
    id: 'item_forged_spirithelm',
    name: 'Spirit Helm',
    type: ItemType.armor,
    tier: 3,
    isForged: true,
    requiredOrigin: 'Forgeheart',
    imagePath: 'assets/images/items/forged_spirit_helm.png',
    statsBonus: const ItemStatsBonus(
      bonusMaxHealth: 300,
      bonusMagicResist: 30,
      bonusArmor: 30,
      bonusAbilityPower: 30,
    ),
    uniqueAbilityDescription: 'After using an ability, Heal for 50% Mana Spent',
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
      bonusAbilityPower: 60,
      bonusCritChance: 0.50,
      bonusRange: 1,
    ),
    uniqueAbilityDescription: '+1 Range. Your Ability can critically strike',
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
