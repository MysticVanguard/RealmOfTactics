import 'package:realm_of_tactics/models/game_manager.dart';
import 'package:realm_of_tactics/models/item.dart';
import 'package:realm_of_tactics/models/unit.dart';

class BlessingEntry {
  final String name;
  final int tier;
  final Set<int> validChoices;

  const BlessingEntry(this.name, this.tier, this.validChoices);
}

class BlessingData {
  static final List<BlessingEntry> allBlessings = [
    // Tier 1
    BlessingEntry("Minimize I", 1, {1}),
    BlessingEntry("Profiteer", 1, {1}),
    BlessingEntry("Powerful", 1, {1}),
    BlessingEntry("Rolling", 1, {1}),
    BlessingEntry("Money Enjoyer", 1, {1}),
    BlessingEntry("Processed Forging", 1, {1, 2}),
    BlessingEntry("Thief", 1, {1, 2, 3}),
    BlessingEntry("No Healing", 1, {1, 2, 3}),
    BlessingEntry("Safeguard", 1, {1, 2, 3}),
    BlessingEntry("Vampiric Bite", 1, {1, 2, 3}),
    BlessingEntry("Shifting Bench", 1, {1, 2, 3}),

    // Tier 2
    BlessingEntry("Minimize II", 2, {1}),
    BlessingEntry("Money Lover", 2, {1}),
    BlessingEntry("Equalizer", 2, {1}),
    BlessingEntry("Three Squared", 2, {1, 2}),
    BlessingEntry("Money Lover+", 2, {2}),
    BlessingEntry("Forging", 2, {1, 2, 3}),
    BlessingEntry("Speed It Up", 2, {2, 3}),
    BlessingEntry("Goodie Bag", 2, {2, 3}),
    BlessingEntry("Strength Up", 2, {1, 2, 3}),
    BlessingEntry("Aggression", 2, {1, 2, 3}),
    BlessingEntry("Fortify", 2, {1, 2, 3}),

    // Tier 3
    BlessingEntry("Minimize III", 3, {1}),
    BlessingEntry("Component Hoarder", 3, {1}),
    BlessingEntry("Big Start", 3, {1}),
    BlessingEntry("Holy Trinity", 3, {1, 2}),
    BlessingEntry("End It", 3, {2, 3}),
    BlessingEntry("Forged Iron", 3, {1, 2, 3}),
    BlessingEntry("Aggressive Aggression", 3, {1, 2, 3}),
    BlessingEntry("Fortified Fortify", 3, {1, 2, 3}),
    BlessingEntry("Shields Up", 3, {1, 2, 3}),
    BlessingEntry("Divinify", 3, {1, 2, 3}),
  ];

  // Given a tier and choicenumber, gets all the blessings possible
  static List<String> getBlessingsForTierAndChoice(int tier, int choiceNumber) {
    return allBlessings
        .where((b) => b.tier == tier && b.validChoices.contains(choiceNumber))
        .map((b) => b.name)
        .toList();
  }

  // Applies any immediate effects of a blessing
  static void applyImmediateBlessing(String blessing) {
    final gm = GameManager.instance!;
    final bm = gm.boardManager;
    final mm = gm.mapManager;

    switch (blessing) {
      case "Powerful":
        gm.addXp(10);
        break;
      case "Rolling":
        gm.shopManager?.addFreeRefresh(10);
        break;
      case "Money Enjoyer":
        gm.addGold(8);
        break;
      case "Rolling+":
        gm.shopManager?.addFreeRefresh(15);
        break;

      case "Money Enjoyer+":
        gm.addGold(15);
        break;
      case "True Champion":
        bm?.addItemToBench(gm.getRandomBasicItem());
        gm.addRandomUnitsToBench(5, 1);
        break;
      case "Thief":
        bm?.addItemToBench(gm.getRandomItemByTier(2));
      case "Money Lover":
        gm.addGold(15);
        gm.maxInterest += 5;
      case "Equalizer":
        mm.tierOrder = [2, 3, 3];
      case "Money Lover+":
        gm.addGold(20);
        gm.maxInterest += 5;
      case "Forging":
        bm?.addItemToBench(gm.getRandomItemByTier(3));
        break;
      case "Goodie Bag":
        gm.addRandomBasicItems(3);
        final unit = gm.getRandomUnitByCost(2);
        final upUnit = unit.upgrade();
        bm?.addUnitToBench(upUnit);
        break;
      case "Big Start":
        gm.addXp(50);
        break;
      case "Forged Iron":
        bm?.addItemToBench(gm.getRandomItemByTier(3));
        bm?.addItemToBench(gm.getRandomItemByTier(3));
        break;
      case "Strength Up":
        for (int i = 0; i < 2; i++) {
          Item item = gm.getRandomBasicItem();
          gm.applyItemBonus(item.statsBonus);
          bm?.addItemToBench(item);
        }
        break;
      case "Component Hoarder":
        gm.addRandomBasicItems(2);
        break;
    }
  }

  // Applies any combat start effects of blessings
  static void applyCombatStartBlessings(
    List<Unit> playerUnits,
    List<Unit> enemyUnits,
  ) {
    final gm = GameManager.instance!;
    final bm = gm.boardManager;
    final mm = gm.mapManager;
    final blessings = mm.playerBlessings;
    final threeCosts = playerUnits.where((unit) => unit.cost == 3).length;
    final threeCostsUpgraded =
        playerUnits.where((unit) => unit.tier == 3 && unit.cost == 3).length;
    if (blessings.contains("No Healing")) {
      for (final unit in enemyUnits) {
        unit.stats.healingReduced = true;
      }
    }
    if (blessings.contains("Profiteer")) {
      gm.addGold(1);
    }
    if (blessings.contains("Shifting Bench")) {
      for (final item in bm!.getAllBenchItems()) {
        int itemTier = item.tier;
        bm.remove(item);
        bm.addItemToBench(gm.getRandomItemByTier(itemTier));
      }
    }
    for (final unit in playerUnits) {
      int itemsHeld = unit.getEquippedItems().length;
      int componentsHeld =
          unit.getEquippedItems().where((item) => item.tier == 1).length;
      for (final blessing in blessings) {
        switch (blessing) {
          case "Minimize I":
            if (unit.cost != 1) continue;
            unit.stats.combatStartDamageAmp += .05 * unit.tier;
            unit.stats.combatStartDamageResistanceBonus += .05 * unit.tier;
            break;
          case "Minimize II":
            if (unit.cost != 1) continue;
            unit.stats.combatStartDamageAmp += .1 * unit.tier;
            unit.stats.combatStartDamageResistanceBonus += .1 * unit.tier;
            break;
          case "Minimize III":
            if (unit.cost != 1) continue;
            unit.stats.combatStartDamageAmp += .15 * unit.tier;
            unit.stats.combatStartDamageResistanceBonus += .15 * unit.tier;
            break;
          case "Safeguard":
            List<Unit> adjacent = unit.getAdjacentUnits();
            if (adjacent.length > 1) continue;
            if (unit.stats.maxHealth > adjacent[0].stats.maxHealth) {
              unit.stats.combatStartDamageResistanceBonus += .05;
              adjacent[0].stats.combatStartDamageAmp += .05;
            } else {
              unit.stats.combatStartDamageAmp += .05;
              adjacent[0].stats.combatStartDamageResistanceBonus += .05;
            }
            break;
          case "Three Squared":
            if (threeCosts != 3) continue;
            if (unit.cost == 3) {
              unit.stats.combatStartAttackSpeedBonus += .33;
              unit.stats.combatStartHealthBonus += 333;
            }
            break;
          case "Holy Trinity":
            if (threeCostsUpgraded != 3) continue;
            if (unit.cost == 3) {
              unit.stats.combatStartAttackSpeedBonus += .33;
              unit.stats.combatStartHealthBonus += 333;
              unit.stats.combatStartDamageResistanceBonus += .33;
              unit.stats.combatStartDamageAmp += .33;
            }
            break;
          case "Aggression":
            unit.stats.combatStartHealthBonus += 50 * itemsHeld;
            unit.stats.combatStartAttackDamageBonus +=
                ((unit.stats.baseAttackDamage * .05) * itemsHeld).floor();
            break;
          case "Fortify":
            unit.stats.combatStartArmorBonus += 10 * itemsHeld;
            unit.stats.combatStartMagicResistBonus += 10 * itemsHeld;
            break;
          case "Component Hoarder":
            if (componentsHeld == 0) continue;
            for (final item in unit.getEquippedItems()) {
              if (item.tier == 1) {
                unit.stats.applyItemBonusToCombatStart(item.statsBonus);
                unit.stats.applyItemBonusToCombatStart(item.statsBonus);
                unit.stats.applyItemBonusToCombatStart(item.statsBonus);
                unit.stats.applyItemBonusToCombatStart(item.statsBonus);
              }
            }
            break;
          case "Aggressive Aggresion":
            unit.stats.combatStartHealthBonus += 100 * itemsHeld;
            unit.stats.combatStartAttackDamageBonus +=
                ((unit.stats.baseAttackDamage * .15) * itemsHeld).floor();
            break;
          case "Fortified Fortify":
            unit.stats.combatStartArmorBonus += 10 * itemsHeld;
            unit.stats.combatStartMagicResistBonus += 10 * itemsHeld;
            break;
        }
      }
    }
  }

  static final Map<String, String> blessingDescriptions = {
    "Minimize I":
        "1 cost units gain +5% Damage Amp and +5% Damage Reduction per star level at the start of combat.",
    "Profiteer": "Gain +1 gold at the start of each combat.",
    "Powerful": "Gain 10 free XP.",
    "Rolling": "Gain 10 free rerolls.",
    "Money Enjoyer": "Gain 8 gold.",
    "Processed Forging": "Gain 1 random forged item after your next blessing.",
    "Rolling+": "Gain 15 free rerolls.",
    "Money Enjoyer+": "Gain 15 gold.",
    "True Champion": "Gain a random component and a random 5 cost unit.",
    "Thief": "Gain a random tier 2 item.",
    "No Healing":
        "Enemy units have healing reduced by 40% at the start of combat.",
    "Safeguard":
        "If a unit starts combat next to only 1 other unit, high HP gets 5% Damage Reduction, low HP gets 5% Damage Amp.",
    "Vampiric Bite": "Units gain 200 Health on kill.",
    "Shifting Bench":
        "Items on the bench change to a random item of the same tier at the start of each combat.",
    "Minimize II":
        "1 cost units gain +10% Damage Amp and +10% Damage Reduction per star level.",
    "Money Lover": "Gain 15 gold. Max interest increased to 10.",
    "Equalizer": "Your Tier 1 blessing becomes Tier 3.",
    "Three Squared":
        "Start with 3 3-cost units: they get 33% Attack Speed and 333 Health.",
    "Money Lover+": "Gain 20 gold. Max interest increased to 10.",
    "Forging": "Gain a random forged item.",
    "Speed It Up": "After 15 seconds, your units gain 150% Attack Speed.",
    "Goodie Bag": "Gain 3 tier 1 items and 1 tier 2 2-cost unit.",
    "Strength Up":
        "Gain 2 tier 1 items. All units gain their stats at combat start.",
    "Aggression": "Units gain 50 HP and 5% AD per item held.",
    "Fortify": "Units gain 10 Armor and 10 MR per item held.",
    "Minimize III":
        "1 cost units gain +15% Damage Amp and +15% Damage Reduction per star level.",
    "Component Hoarder":
        "Tier 1 items give 4x stats at combat start. Gain 2 tier 1 items.",
    "Big Start": "Gain 50 XP.",
    "Holy Trinity":
        "Start with 3 tier 3 3-cost units: They get 33% Attack Speed, Damage Resistance, and Damage Amp, and 333 Health.",
    "End It": "After 15 seconds, your units gain 300% Attack Speed.",
    "Forged Iron": "Gain 2 random forged items.",
    "Aggressive Aggression": "Units gain 100 HP and 15% AD per item held.",
    "Fortified Fortify": "Units gain 25 Armor and 25 MR per item held.",
    "Shields Up": "Shields are 2x larger.",
    "Divinify":
        "Last unit gains massive bonuses including 33% max HP, lifesteal, and 100% Attack Speed.",
  };

  static String getBlessingDescription(String name) {
    return blessingDescriptions[name] ?? "No description available.";
  }
}
