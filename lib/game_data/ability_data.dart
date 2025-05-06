import "../models/ability.dart";

final Map<String, Ability> abilities = {
  'Frost Barrier': Ability(
    name: 'Frost Barrier',
    description: 'Grants a shield and armor that lasts 5 seconds.',
    effects: [
      AbilityEffect(
        type: AbilityEffectType.shield,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        baseAmountByTier: [100, 100, 100],
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 3.0, 4.0],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "armor",
        baseAmountByTier: [10, 10, 10],
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.3, 0.6, 0.9],
        duration: Duration(seconds: 5),
      ),
    ],
    manaLockDuration: Duration(seconds: 5),
  ),

  'Freezing Slash': Ability(
    name: 'Freezing Slash',
    description:
        'Stabs the target for 200/300/400% AD physical damage. Gain 5/10/15% AP AD for the rest of combat.',
    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [2.0, 3.0, 4.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "attackDamage",
        scalingStat: "abilityPower",
        scalingPercentByTier: [.05, .1, .15],
      ),
    ],
  ),

  'Glacial Aegis': Ability(
    name: 'Glacial Aegis',
    description:
        'Gain a shield equal to 20/30/40% of max health for 5 seconds. Deal 100/200/400% AP as magic damage to the target.',
    effects: [
      AbilityEffect(
        type: AbilityEffectType.shield,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: "maxHealth",
        scalingPercentByTier: [0.2, 0.3, 0.4],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [1.0, 2.0, 4.0],
      ),
    ],
    manaLockDuration: Duration(seconds: 5),
  ),

  'Frigid Volley': Ability(
    name: 'Frigid Volley',
    description: 'Deal 200/400/700% AD as physical damage to the target.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [2.0, 4.0, 7.0],
      ),
    ],
  ),

  'Blessed Renewal': Ability(
    name: 'Blessed Renewal',
    description:
        'Heal the ally with the lowest health for a massive amount based on AP, and grant them Armor and Magic Resist for 5 seconds.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.heal,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.lowestStat,
          statName: "currentHealth",
          count: 1,
          targetTeam: TargetTeam.allies,
        ),
        baseAmountByTier: [0, 0, 0],
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 4.0, 6.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.lowestStat,
          statName: "currentHealth",
          count: 1,
          targetTeam: TargetTeam.allies,
        ),
        stat: "armor",
        baseAmountByTier: [0, 0, 0],
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.05, 0.10, 0.15],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.lowestStat,
          statName: "currentHealth",
          count: 1,
          targetTeam: TargetTeam.allies,
        ),
        stat: "magicResist",
        baseAmountByTier: [5, 10, 15],
        duration: Duration(seconds: 5),
      ),
    ],
  ),

  'Crippling Dagger': Ability(
    name: 'Crippling Dagger',
    description:
        'Throw a dagger at the lowest health enemy unit, dealing 200/300/400% AD physical damage and reducing their damage by 10% for 5 seconds.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.lowestStat,
          statName: "currentHealth",
          count: 1,
          includeSelf: false,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [2.0, 3.0, 4.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.statDebuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.lowestStat,
          statName: "currentHealth",
          count: 1,
          includeSelf: false,
          targetTeam: TargetTeam.enemies,
        ),
        stat: "damageAmp",
        baseAmountByTier: [10, 10, 10],
        duration: Duration(seconds: 5),
      ),
    ],
  ),

  'Starfall Convergence': Ability(
    name: 'Starfall Convergence',
    description:
        'Rain down stars dealing 200/300/400% AP magic damage to the largest clump of enemies in a plus sign.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.mostCanHit,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 4.0, 18.0],
      ),
    ],
  ),

  'Runic Protection': Ability(
    name: 'Runic Protection',
    description:
        'Adjacent allies gain a shield equal to 200/300/400% of AP for 8 seconds.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.shield,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
          includeSelf: false,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 4.0, 20.0],
        duration: Duration(seconds: 8),
      ),
    ],
    manaLockDuration: Duration(seconds: 8),
  ),

  'Thunder Strike': Ability(
    name: 'Thunder Strike',
    description:
        'Calls down lightning to strike the enemy dealing 300/500/700% AP as magic damage.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [3.0, 5.0, 7.0],
      ),
    ],
  ),

  'Thundering Might': Ability(
    name: 'Thundering Might',
    description: 'Gain 10/15/20% AD as bonus AD for the rest of combat.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "attackDamage",
        scalingStat: "attackDamage",
        scalingPercentByTier: [0.10, 0.15, 0.20],
      ),
    ],
  ),

  'Runic Empowerment': Ability(
    name: 'Runic Empowerment',
    description:
        'Buff the highest AP ally with 10/20/30% AP and the highest AD ally with 25/50/75% AD for 5 seconds.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.highestStat,
          statName: "abilityPower",
          count: 1,
          includeSelf: false,
          targetTeam: TargetTeam.allies,
        ),
        stat: "abilityPower",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.10, 0.20, 0.30],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.highestStat,
          statName: "attackDamage",
          count: 1,
          includeSelf: false,
          targetTeam: TargetTeam.allies,
        ),
        stat: "attackDamage",
        scalingStat: "attackDamage",
        scalingPercentByTier: [0.25, 0.50, 0.75],
        duration: Duration(seconds: 5),
      ),
    ],
  ),

  'Stoneguard Stance': Ability(
    name: 'Stoneguard Stance',
    description:
        'Gain 20% Armor and bonus Armor equal to 10/20/30% of AP for 10 seconds.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "armor",
        scalingStat: "armor",
        scalingPercentByTier: [0.20, 0.20, 0.20],
        duration: Duration(seconds: 10),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "armor",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.10, 0.20, 0.30],
        duration: Duration(seconds: 10),
      ),
    ],
    manaLockDuration: Duration(seconds: 10),
  ),

  'Deadeye Barrage': Ability(
    name: 'Deadeye Barrage',
    description:
        'Fires 8 shots at the lowest max health enemy, each dealing 100/200/300% AD as physical damage.',

    effects: List.generate(
      8,
      (i) => AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.lowestStat,
          statName: "maxHealth",
          count: 1,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [1.0, 2.0, 3.0],
      ),
    ),
  ),

  'Cannon Blast': Ability(
    name: 'Cannon Blast',
    description:
        'Fires a cannonball at the largest clump of enemies in a 2x2 area, dealing 200/400/600% AD as physical damage.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 2,
          selection: TargetSelection.mostCanHit,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [2.0, 4.0, 15.0],
      ),
    ],
  ),

  "Hurricane's Eye": Ability(
    name: "Hurricane's Eye",
    description:
        'Strike adjacent enemies 20 times, dealing 150/300/5000% AD physical damage each time.',

    effects: List.generate(
      20,
      (i) => AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [1.5, 3.0, 50.0],
      ),
    ),
  ),

  'Molten Tempo': Ability(
    name: 'Molten Tempo',
    description:
        'Gain 20/50/80% AP Attack Speed for 5 seconds. Adjacent allies gain half of this.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "attackSpeed",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.20, 0.50, 0.80],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
          includeSelf: false,
        ),
        stat: "attackSpeed",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.10, 0.25, 0.40],
        duration: Duration(seconds: 5),
      ),
    ],
    manaLockDuration: Duration(seconds: 5),
  ),

  'Flare Nova': Ability(
    name: 'Flare Nova',
    description:
        'Gain 20/40/100% AP as Ability Power. Then deal 100/200/500% AP damage to the largest clump of enemies in a 3x3 square.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "abilityPower",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.2, 0.4, 1.0],
        duration: null,
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 3,
          selection: TargetSelection.mostCanHit,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [1.0, 2.0, 5.0],
      ),
    ],
  ),

  'Ignited Slash': Ability(
    name: 'Ignited Slash',
    description:
        'Gain 50% AP Attack Speed for 2 seconds. Slash the target for 200/400/1000% AP magic damage.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "attackSpeed",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.5, 0.5, 0.5],
        duration: Duration(seconds: 2),
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 4.0, 10.0],
      ),
    ],
  ),

  'Stoneform': Ability(
    name: 'Stoneform',
    description: 'Gain 100/200/300% AP Max Health. Gain 10% AP Magic Resist.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "maxHealth",
        scalingStat: "abilityPower",
        scalingPercentByTier: [1.0, 2.0, 3.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "magicResist",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.1, 0.1, 0.1],
      ),
    ],
  ),

  'Stonebond Ritual': Ability(
    name: 'Stonebond Ritual',
    description:
        'Heal your lowest health ally for 100/200/300% AP twice. Give a shield to your highest AD ally for 200/400/600% AP.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.heal,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.lowestStat,
          statName: "currentHealth",
          count: 1,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [1.0, 2.0, 3.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.heal,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.lowestStat,
          statName: "currentHealth",
          count: 1,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [1.0, 2.0, 3.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.shield,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.highestStat,
          statName: "attackDamage",
          count: 1,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 4.0, 6.0],
        duration: Duration(seconds: 5),
      ),
    ],
  ),

  'Colossal Might': Ability(
    name: 'Colossal Might',
    description:
        'Gain 20/40/100% AD as bonus AD for 5s. Gain a shield for 10/20/100% max HP + 100/200/500% AP.',

    manaLockDuration: Duration(seconds: 5),
    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "attackDamage",
        scalingStat: "attackDamage",
        scalingPercentByTier: [0.2, 0.4, 1.0],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.shield,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: "maxHealth",
        scalingPercentByTier: [0.1, 0.2, 1.0],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.shield,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [1.0, 2.0, 5.0],
        duration: Duration(seconds: 5),
      ),
    ],
  ),

  'Seismic Bulwark': Ability(
    name: 'Seismic Bulwark',
    description: 'Gain 5/10/15% max HP as bonus AD, Armor, and MR for 5s.',

    manaLockDuration: Duration(seconds: 5),
    effects: [
      for (var stat in ["attackDamage", "armor", "magicResist"])
        AbilityEffect(
          type: AbilityEffectType.statBuff,
          targeting: TargetingRule(
            areaShape: AreaShape.xByX,
            size: 1,
            selection: TargetSelection.self,
            targetTeam: TargetTeam.allies,
          ),
          stat: stat,
          scalingStat: "maxHealth",
          scalingPercentByTier: [0.05, 0.10, 0.15],
          duration: Duration(seconds: 5),
        ),
    ],
  ),
  'Deploy Gearbot': Ability(
    name: 'Deploy Gearbot',
    description:
        'Summon a gearbot with 300/400/500% AP Max Health, 20/40/60% AP Armor and Magic Resist, and 1 attack range.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.summon,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        summonUnitName: 'Gearbot',
        summonImagePath: 'assets/images/units/gearbot.png',
        summonStats: {
          'maxHealth': SummonStatScaling(
            percentByTier: [3.0, 4.0, 5.0],
            scalingStat: 'ap',
          ),
          'armor': SummonStatScaling(
            percentByTier: [0.2, 0.4, 0.6],
            scalingStat: 'ap',
          ),
          'magicResist': SummonStatScaling(
            percentByTier: [0.2, 0.4, 0.6],
            scalingStat: 'ap',
          ),
          'range': SummonStatScaling(percentByTier: [1, 1, 1]),
          'attackDamage': SummonStatScaling(percentByTier: [20, 30, 40]),
        },
      ),
    ],
  ),

  'Deploy Turret': Ability(
    name: 'Deploy Turret',
    description:
        'Summon a turret with 300/600/2500% AP Max Health, 50/100/1000% AP AD, 20/30/100% AP Armor/MR, and 3 range.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.summon,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        summonUnitName: 'Iron Turret',
        summonImagePath: 'assets/images/units/iron_turret.png',
        summonStats: {
          'maxHealth': SummonStatScaling(
            percentByTier: [3.0, 6.0, 25.0],
            scalingStat: 'ap',
          ),
          'attackDamage': SummonStatScaling(
            percentByTier: [0.5, 1.0, 10.0],
            scalingStat: 'ap',
          ),
          'armor': SummonStatScaling(
            percentByTier: [0.2, 0.3, 1.0],
            scalingStat: 'ap',
          ),
          'magicResist': SummonStatScaling(
            percentByTier: [0.2, 0.3, 1.0],
            scalingStat: 'ap',
          ),
          'range': SummonStatScaling(percentByTier: [3, 3, 3]),
        },
      ),
    ],
  ),

  'Aegis Pulse': Ability(
    name: 'Aegis Pulse',
    description:
        'Gain a shield equal to 20/30/40% of max health and deal 300/500/700% AP damage to the enemy.',

    manaLockDuration: Duration(seconds: 3),
    effects: [
      AbilityEffect(
        type: AbilityEffectType.shield,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: 'maxHealth',
        scalingPercentByTier: [0.2, 0.3, 0.4],
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'abilityPower',
        scalingPercentByTier: [3.0, 5.0, 7.0],
      ),
    ],
  ),

  'Fortress Slam': Ability(
    name: 'Fortress Slam',
    description:
        'Deal 5/10/15% max HP as magic damage to adjacent enemies and gain armor.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'maxHealth',
        scalingPercentByTier: [0.05, 0.10, 0.15],
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'armor',
        baseAmountByTier: [5, 10, 15],
      ),
    ],
  ),

  'Twin Surge': Ability(
    name: 'Twin Surge',
    description:
        'Deal AP magic damage to adjacent enemies, then AD physical damage to target.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'abilityPower',
        scalingPercentByTier: [2.0, 3.0, 4.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [3.0, 6.0, 9.0],
      ),
    ],
  ),

  'Priority Pulse': Ability(
    name: 'Priority Pulse',
    description: 'Heal three allies based on different stat rules.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.heal,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.lowestStat,
          statName: 'currentHealth',
          count: 1,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: 'abilityPower',
        scalingPercentByTier: [3.0, 6.0, 20.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.heal,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.highestStat,
          statName: 'attackDamage',
          count: 1,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: 'abilityPower',
        scalingPercentByTier: [1.0, 3.0, 10.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.heal,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.highestStat,
          statName: 'abilityPower',
          count: 1,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: 'abilityPower',
        scalingPercentByTier: [1.0, 3.0, 10.0],
      ),
    ],
  ),

  'Temporal Inscription': Ability(
    name: 'Temporal Inscription',
    description: 'Heal adjacent allies and gain 5 AP.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.heal,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: 'abilityPower',
        scalingPercentByTier: [1.0, 2.0, 3.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'abilityPower',
        baseAmountByTier: [5, 5, 5],
      ),
    ],
  ),

  'Whirring Daggers': Ability(
    name: 'Whirring Daggers',
    description: 'Spin and deal AD physical damage to adjacent enemies.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [2.0, 3.0, 5.0],
      ),
    ],
  ),

  'Clockbot Construct': Ability(
    name: 'Clockbot Construct',
    description: 'Summon a clockbot with basic stats.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.summon,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        summonUnitName: 'Clockbot',
        summonImagePath: 'assets/images/units/clockbot.png',
        summonStats: {
          'maxHealth': SummonStatScaling(percentByTier: [1.0, 1.0, 1.0]),
          'attackDamage': SummonStatScaling(
            percentByTier: [0.15, 0.30, 0.50],
            scalingStat: 'abilityPower',
          ),
          'armor': SummonStatScaling(percentByTier: [10, 20, 30]),
          'magicResist': SummonStatScaling(percentByTier: [10, 20, 30]),
          'range': SummonStatScaling(percentByTier: [2, 2, 2]),
        },
      ),
    ],
  ),

  'Piercing Round': Ability(
    name: 'Piercing Round',
    description:
        'Fire a shot at the lowest armor enemy, dealing 400/600/800% AD Physical damage.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.lowestStat,
          statName: "armor",
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [4.0, 8.0, 40.0],
      ),
    ],
  ),

  'Temporal Bulwark': Ability(
    name: 'Temporal Bulwark',
    description:
        'Gain 10/20/50% Max Health. Deal 300/500/2000% AD to the enemy.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "maxHealth",
        scalingStat: "maxHealth",
        scalingPercentByTier: [0.1, 0.2, 0.5],
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [3.0, 5.0, 20.0],
      ),
    ],
  ),

  'Precision Stab': Ability(
    name: 'Precision Stab',
    description: 'Stab the enemy for 200/400/600% AD damage.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [2.0, 4.0, 6.0],
      ),
    ],
  ),

  'Veggiebot Swarm': Ability(
    name: 'Veggiebot Swarm',
    description:
        'Summon veggiebots with 100/200/300 HP, 10 Armor and MR, 20/40/60% AP AD, and 1 range.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.summon,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        summonUnitName: "Veggiebot",
        summonImagePath: "assets/images/units/veggiebot.png",
        summonStats: {
          "maxHealth": SummonStatScaling(percentByTier: [100, 200, 300]),
          "attackDamage": SummonStatScaling(
            percentByTier: [0.2, 0.4, 0.6],
            scalingStat: "abilityPower",
          ),
          "armor": SummonStatScaling(percentByTier: [10, 10, 10]),
          "magicResist": SummonStatScaling(percentByTier: [10, 10, 10]),
          "range": SummonStatScaling(percentByTier: [1, 1, 1]),
        },
      ),
    ],
  ),

  "Nature's Balance": Ability(
    name: "Nature's Balance",
    description:
        'Heal for 200/300/400% AP. Deal 200/300/400% AP damage to the enemy.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.heal,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 3.0, 4.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 3.0, 4.0],
      ),
    ],
  ),

  'Rejuvenating Bloom': Ability(
    name: 'Rejuvenating Bloom',
    description: 'Heal all allies for 200/300/400% AP.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.heal,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 8,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 3.0, 4.0],
      ),
    ],
  ),

  'Nature Guard': Ability(
    name: 'Nature Guard',
    description:
        'Gain a shield for 300/500/2000% AP. Deal 200/300/400% AP magic damage to the largest clump of enemies in a plus sign.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.shield,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [3.0, 5.0, 20.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 3,
          selection: TargetSelection.mostCanHit,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 3.0, 20.0],
      ),
    ],
  ),

  'Flame Surge': Ability(
    name: 'Flame Surge',
    description:
        'Gain 20/40/60% Attack Speed and 20/40/60% AP Attack Damage for 5 seconds.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "attackSpeed",
        baseAmountByTier: [20, 40, 60],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "attackDamage",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.2, 0.4, 0.6],
        duration: Duration(seconds: 5),
      ),
    ],
  ),

  'Flare Burst': Ability(
    name: 'Flare Burst',
    description:
        'Gain 10/20/30 Lifesteal for 6 seconds. Set off a flare dealing 100/200/300% AD physical damage to all enemies in a 3x3 square centered on the target.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "lifesteal",
        baseAmountByTier: [10, 20, 30],
        duration: Duration(seconds: 6),
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 3,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [1.0, 2.0, 3.0],
      ),
    ],
  ),
  'Firework Launch': Ability(
    name: 'Firework Launch',
    description:
        'Summon a fireworkbot with 50 HP, 5 movement speed, 100/300/500% AP AD, and 10 Armor and MR.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.summon,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        summonUnitName: "Fireworkbot",
        summonImagePath: "assets/images/units/fireworkbot.png",
        summonStats: {
          "maxHealth": SummonStatScaling(percentByTier: [50.0, 50.0, 50.0]),
          "attackDamage": SummonStatScaling(
            percentByTier: [1.0, 3.0, 5.0],
            scalingStat: "abilityPower",
          ),
          "armor": SummonStatScaling(percentByTier: [10, 10, 10]),
          "magicResist": SummonStatScaling(percentByTier: [10, 10, 10]),
          "movementSpeed": SummonStatScaling(percentByTier: [5.0, 5.0, 5.0]),
          "range": SummonStatScaling(percentByTier: [1, 1, 1]),
        },
      ),
    ],
  ),
  'Scorching Bulwark': Ability(
    name: 'Scorching Bulwark',
    description:
        'Gain 10/20/30 Damage Reduction for 5 seconds. Deal 100/200/300% AP damage to the enemy and nearby enemies in a 2x2 area.',

    manaLockDuration: Duration(seconds: 5),
    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "damageReduction",
        baseAmountByTier: [10, 20, 30],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 2,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [1.0, 2.0, 3.0],
      ),
    ],
  ),

  'Burning Riposte': Ability(
    name: 'Burning Riposte',
    description:
        'Deal 100/200/3000% AD physical damage to the enemy, reducing their Attack Damage by 20/30/400% of your AP for 3 seconds.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [1.0, 2.0, 30.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.statDebuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        stat: "attackDamage",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.2, 0.3, 4.0],
        duration: Duration(seconds: 3),
      ),
    ],
  ),

  'Infernal Volley': Ability(
    name: 'Infernal Volley',
    description:
        'Gain 5/10/15% AP Attack Speed and AD. Rapidly throw daggers at the largest group of enemies in a plus shape, dealing 15/25/1000% AD 20 times. Then throw a final dagger at the enemy, dealing 300/600/3000% AD.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "attackDamage",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.05, 0.10, 0.15],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "attackSpeed",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.05, 0.10, 0.15],
        duration: Duration(seconds: 5),
      ),

      ...List.generate(
        20,
        (_) => AbilityEffect(
          type: AbilityEffectType.damage,
          targeting: TargetingRule(
            areaShape: AreaShape.plusShape,
            size: 3,
            selection: TargetSelection.mostCanHit,
            targetTeam: TargetTeam.enemies,
          ),
          scalingStat: "attackDamage",
          scalingPercentByTier: [0.15, 0.25, 10.0],
        ),
      ),

      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "attackDamage",
        scalingPercentByTier: [3.0, 6.0, 30.0],
      ),
    ],
  ),

  'Rocket Barrage': Ability(
    name: 'Rocket Barrage',
    description:
        'Dash 2 tiles away from enemies, then fire a rocket at the largest group of enemies, dealing small damage over time to enemies it passes through and heavy damage in a 2x2 at the impact.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: "attackSpeed",
        scalingStat: "abilityPower",
        scalingPercentByTier: [0.2, 0.3, 0.4],
        duration: null,
        effectImagePath: "images/effects/melee_slash.png",
      ),

      AbilityEffect(
        type: AbilityEffectType.dash,
        dashRange: 2,
        dashAway: true,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.mostCanHit,
          targetTeam: TargetTeam.enemies,
        ),
      ),

      AbilityEffect(
        type: AbilityEffectType.projectile,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 3,
          selection: TargetSelection.mostCanHit,
          targetTeam: TargetTeam.enemies,
        ),
        projectileWidth: 1,
        projectileTravelSpeed: 4,
        projectileSpritePath: 'images/effects/projectile_bullet.png',
        projectileStopsAtFirstHit: true,
        passThroughEffects: [
          AbilityEffect(
            type: AbilityEffectType.damage,
            targeting: TargetingRule(
              areaShape: AreaShape.xByX,
              size: 1,
              selection: TargetSelection.self,
              targetTeam: TargetTeam.enemies,
            ),
            scalingStat: "attackDamage",
            scalingPercentByTier: [0.2, 0.3, 0.4],
            isDamageOverTime: true,
            damageOverTimeDuration: Duration(seconds: 2),
            effectImagePath: "images/effects/melee_poke.png",
          ),
        ],
        impactEffects: [
          AbilityEffect(
            type: AbilityEffectType.damage,
            targeting: TargetingRule(
              areaShape: AreaShape.xByX,
              size: 2,
              selection: TargetSelection.target,
              targetTeam: TargetTeam.enemies,
            ),
            scalingStat: "attackDamage",
            scalingPercentByTier: [1.0, 1.5, 2.0],
            effectImagePath: "images/effects/melee_pummel.png",
          ),
        ],
      ),
    ],
  ),

  'Twin Tempest': Ability(
    name: 'Twin Tempest',
    description:
        'Summon two tornadoes to seek out the highest AP and AD enemy units, dealing 200/400/600% AP magic damage to each.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.highestStat,
          statName: "abilityPower",
          count: 1,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 4.0, 6.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.highestStat,
          statName: "attackDamage",
          count: 1,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: "abilityPower",
        scalingPercentByTier: [2.0, 4.0, 6.0],
      ),
    ],
  ),
  'Lance Strike': Ability(
    name: 'Lance Strike',
    description:
        'Gain 20/40/200% AD as Armor and Magic Resist, and Gain 30% Lifesteal for 5 seconds. Swipe at the enemy, dealing 200/500/4000% AD physical damage to adjacent enemies.',

    manaLockDuration: Duration(seconds: 5),
    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'armor',
        scalingStat: 'attackDamage',
        scalingPercentByTier: [0.2, 0.4, 2.0],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'magicResist',
        scalingStat: 'attackDamage',
        scalingPercentByTier: [0.2, 0.4, 2.0],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'lifesteal',
        baseAmountByTier: [30, 30, 30],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [2.0, 5.0, 40.0],
      ),
    ],
  ),
  'Skyfall Assault': Ability(
    name: 'Skyfall Assault',
    description:
        'The griffin swipes twice at the target, each dealing 200/300/2000% AD and reducing their Armor by 20/30/50% of AP. Then the rider strikes, dealing 400/600/2000% AD to a 3x3 square centered on the enemy.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
          includeSelf: false,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [2.0, 3.0, 20.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.statDebuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
          includeSelf: false,
        ),
        stat: 'armor',
        scalingStat: 'abilityPower',
        scalingPercentByTier: [0.2, 0.3, 0.5],
        duration: Duration(seconds: 5),
      ),

      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
          includeSelf: false,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [2.0, 3.0, 20.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.statDebuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
          includeSelf: false,
        ),
        stat: 'armor',
        scalingStat: 'abilityPower',
        scalingPercentByTier: [0.2, 0.3, 0.5],
        duration: Duration(seconds: 5),
      ),

      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 3,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
          includeSelf: false,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [4.0, 6.0, 20.0],
      ),
    ],
  ),

  'Burrow Maul': Ability(
    name: 'Burrow Maul',
    description:
        'The badger mauls the target, dealing 200/300/400% AD damage. Gain 10/20/30% AP as bonus Attack Damage for 3 seconds.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [2.0, 3.0, 4.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'attackDamage',
        scalingStat: 'abilityPower',
        scalingPercentByTier: [0.1, 0.2, 0.3],
        duration: Duration(seconds: 3),
      ),
    ],
  ),
  'Earthen Fortitude': Ability(
    name: 'Earthen Fortitude',
    description:
        'Gain 20/40/60% AP as Armor for 5 seconds. Adjacent allies gain 10/20/40% of that amount (2/8/24% AP).',

    manaLockDuration: Duration(seconds: 5),
    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'armor',
        scalingStat: 'abilityPower',
        scalingPercentByTier: [0.2, 0.4, 0.6],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'armor',
        scalingStat: 'abilityPower',
        scalingPercentByTier: [0.02, 0.08, 0.24],
        duration: Duration(seconds: 5),
      ),
    ],
  ),

  'Screech and Strike': Ability(
    name: 'Screech and Strike',
    description:
        'Lizard screeches, reducing the attack speed of adjacent enemies by 10/20/30% AP for 10 seconds. Then throw a warpick at the highest attack speed enemy, dealing 300% AD physical damage.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statDebuff,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.enemies,
        ),
        stat: 'attackSpeed',
        scalingStat: 'abilityPower',
        scalingPercentByTier: [0.10, 0.20, 0.30],
        duration: Duration(seconds: 10),
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.highestStat,
          statName: 'attackSpeed',
          count: 1,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [3.0, 3.0, 3.0],
      ),
    ],
  ),

  'Crack and Blast': Ability(
    name: 'Crack and Blast',
    description:
        'Shoots an armor-cracking bomb reducing all enemies\' armor by 10/20/50% for 3 seconds. Then fires the big one, dealing 200/400/4000% AD physical damage to all enemies.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statDebuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 8,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.enemies,
        ),
        stat: 'armor',
        scalingPercentByTier: [0.10, 0.20, 0.50],
        duration: Duration(seconds: 3),
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 8,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [2.0, 4.0, 40.0],
      ),
    ],
  ),

  'Runebound Pulse': Ability(
    name: 'Runebound Pulse',
    description:
        'Gain 20/40/60% AP Armor and MR. Deal 100/150/200% AD to a plus shape centered on the enemy.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'armor',
        scalingStat: 'abilityPower',
        scalingPercentByTier: [0.2, 0.4, 0.6],
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'magicResist',
        scalingStat: 'abilityPower',
        scalingPercentByTier: [0.2, 0.4, 0.6],
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.plusShape,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [1.0, 1.5, 2.0],
      ),
    ],
  ),

  'Arcane Payload': Ability(
    name: 'Arcane Payload',
    description: 'Shoot the enemy, dealing 300/400/500% AD to the enemy.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [3.0, 4.0, 5.0],
      ),
    ],
  ),

  'Pledge of Steel': Ability(
    name: 'Pledge of Steel',
    description:
        'Gain a shield for 300/400/500% AD. Strike the enemy for the same amount.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.shield,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [3.0, 4.0, 5.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [3.0, 4.0, 5.0],
      ),
    ],
  ),

  'Runic Assembly': Ability(
    name: 'Runic Assembly',
    description:
        'Summon a runic enforcer with 500/1000/5000% AP Max Health, 20/40/100% AP Armor and MR, 20 attack damage, 1 range.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.summon,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        summonUnitName: 'Runic Enforcer',
        summonImagePath: 'assets/images/units/runic_enforcer.png',
        summonStats: {
          'maxHealth': SummonStatScaling(
            percentByTier: [5.0, 10.0, 50.0],
            scalingStat: 'abilityPower',
          ),
          'armor': SummonStatScaling(
            percentByTier: [0.2, 0.4, 1.0],
            scalingStat: 'abilityPower',
          ),
          'magicResist': SummonStatScaling(
            percentByTier: [0.2, 0.4, 1.0],
            scalingStat: 'abilityPower',
          ),
          'attackDamage': SummonStatScaling(percentByTier: [20.0, 20.0, 20.0]),
          'range': SummonStatScaling(percentByTier: [1.0, 1.0, 1.0]),
        },
      ),
    ],
  ),

  'Shadow Surge': Ability(
    name: 'Shadow Surge',
    description:
        'Gain 20/30/400% Attack Speed, 20/30/60% Lifesteal, and 40/50/100% Damage Reduction for 5 seconds.',

    manaLockDuration: Duration(seconds: 5),
    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'attackSpeed',
        baseAmountByTier: [20, 30, 400],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'lifesteal',
        baseAmountByTier: [20, 30, 60],
        duration: Duration(seconds: 5),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'damageReduction',
        baseAmountByTier: [40, 50, 100],
        duration: Duration(seconds: 5),
      ),
    ],
  ),

  'Mystic Cascade': Ability(
    name: 'Mystic Cascade',
    description:
        'Reduce the AD of all enemies by 100/200/1000 for 3s. All allies gain a shield for 100/300/1000% AP and all enemies take 100/300/5000% AP damage.',

    manaLockDuration: Duration(seconds: 3),
    effects: [
      AbilityEffect(
        type: AbilityEffectType.statDebuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 8,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.enemies,
        ),
        stat: 'attackDamage',
        baseAmountByTier: [100, 200, 1000],
        duration: Duration(seconds: 3),
      ),
      AbilityEffect(
        type: AbilityEffectType.shield,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 8,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: 'abilityPower',
        scalingPercentByTier: [1.0, 3.0, 10.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 8,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'abilityPower',
        scalingPercentByTier: [1.0, 3.0, 50.0],
      ),
    ],
  ),

  'Earthsplitter': Ability(
    name: 'Earthsplitter',
    description:
        'Gain a shield for 300/400/500% AP. Cleave a 3x3 square centered on the enemy dealing 200/300/400% AD physical damage.',

    effects: [
      AbilityEffect(
        type: AbilityEffectType.shield,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        scalingStat: 'abilityPower',
        scalingPercentByTier: [3.0, 4.0, 5.0],
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 3,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'attackDamage',
        scalingPercentByTier: [2.0, 3.0, 4.0],
      ),
    ],
  ),

  'Unbreakable Form': Ability(
    name: 'Unbreakable Form',
    description:
        'Gain 30 damage reduction for 5 seconds. Gain 10/20/30% Max health. Deal 20/30/40% Max health damage to the enemy.',

    manaLockDuration: Duration(seconds: 2),
    effects: [
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'damageReduction',
        baseAmountByTier: [30, 30, 30],
        duration: Duration(seconds: 2),
      ),
      AbilityEffect(
        type: AbilityEffectType.statBuff,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.self,
          targetTeam: TargetTeam.allies,
        ),
        stat: 'maxHealth',
        scalingStat: 'maxHealth',
        scalingPercentByTier: [0.10, 0.20, 0.30],
      ),
      AbilityEffect(
        type: AbilityEffectType.damage,
        targeting: TargetingRule(
          areaShape: AreaShape.xByX,
          size: 1,
          selection: TargetSelection.target,
          targetTeam: TargetTeam.enemies,
        ),
        scalingStat: 'maxHealth',
        scalingPercentByTier: [0.20, 0.30, 0.40],
      ),
    ],
  ),
};
