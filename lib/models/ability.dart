import 'board_position.dart';

// Gives a percent of a stat for a value in an ability effect
class SummonStatScaling {
  final List<double> percentByTier;
  final String? scalingStat;

  SummonStatScaling({required this.percentByTier, this.scalingStat});
}

// The area types to apply the ability effect to
enum AreaShape { xByX, row, column, xShape, plusShape }

// Target selection for ability effect shape to be centered on
enum TargetSelection {
  self,
  target,
  specifiedPosition,
  mostCanHit,
  lowestStat,
  highestStat,
}

// Everything targeting, bundled up for ability effects
class TargetingRule {
  final AreaShape areaShape;
  final int size;

  final TargetSelection selection;
  final String? statName;
  final int? count;

  final bool includeSelf;
  final TargetTeam targetTeam;

  const TargetingRule({
    required this.areaShape,
    required this.size,
    required this.selection,
    this.statName,
    this.count,
    this.includeSelf = true,
    required this.targetTeam,
  });
}

// Who the effect is applied to
enum TargetTeam { allies, enemies, both }

// What the effect does
enum AbilityEffectType {
  damage,
  heal,
  shield,
  statBuff,
  statDebuff,
  summon,
  stun,
  dash,
  projectile,
}

// The effect, used as a very modular piece to make infinite ability combos
class AbilityEffect {
  final AbilityEffectType type;
  final TargetingRule targeting;
  final String? targetStat;

  final String? summonUnitName;
  final String? summonImagePath;
  final Map<String, SummonStatScaling>? summonStats;
  final Position? specifiedAbilityPosition;
  final String? stat;
  final List<int>? baseAmountByTier;
  final String? scalingStat;
  final List<double>? scalingPercentByTier;
  final Duration? duration;
  final int? dashRange;
  final bool? dashAway;
  final int? projectileWidth;
  final List<AbilityEffect>? passThroughEffects;
  final List<AbilityEffect>? impactEffects;
  final bool projectileStopsAtFirstHit;
  final String? projectileSpritePath;
  final double? projectileTravelSpeed;
  final bool isDamageOverTime;
  final Duration? damageOverTimeDuration;
  final String? effectImagePath;

  AbilityEffect({
    required this.type,
    required this.targeting,
    this.effectImagePath,
    this.targetStat,
    this.stat,
    this.baseAmountByTier,
    this.scalingStat,
    this.scalingPercentByTier,
    this.duration,
    this.summonUnitName,
    this.summonImagePath,
    this.summonStats,
    this.specifiedAbilityPosition,
    this.dashRange,
    this.dashAway,
    this.projectileWidth,
    this.passThroughEffects,
    this.impactEffects,
    this.projectileStopsAtFirstHit = true,
    this.projectileSpritePath,
    this.projectileTravelSpeed,
    this.isDamageOverTime = false,
    this.damageOverTimeDuration,
  });
}

// An ability used by a unit, with a plethora of effects
class Ability {
  final String name;
  final String description;
  final List<AbilityEffect> effects;
  final String? targetStat;
  final Duration manaLockDuration;

  const Ability({
    required this.name,
    required this.description,
    required this.effects,
    this.targetStat,
    this.manaLockDuration = const Duration(seconds: 1),
  });
}
