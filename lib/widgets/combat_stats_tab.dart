import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm_of_tactics/models/combat_manager.dart';
import 'package:realm_of_tactics/models/unit.dart';
import 'package:realm_of_tactics/screens/game_screen.dart';

class CombatStatsTab extends StatefulWidget {
  final StatType selectedStat;
  final void Function(StatType) onStatSelected;

  const CombatStatsTab({
    super.key,
    required this.selectedStat,
    required this.onStatSelected,
  });

  @override
  State<CombatStatsTab> createState() => _CombatStatsTabState();
}

class _CombatStatsTabState extends State<CombatStatsTab> {
  @override
  Widget build(BuildContext context) {
    final combatManager = Provider.of<CombatManager>(context);
    final List<Unit> playerUnits =
        combatManager.playerUnits.where((u) => !u.isSummon).toList();
    final List<Unit> enemyUnits =
        combatManager.enemyUnits.where((u) => !u.isSummon).toList();

    // Chooses which substats we are visualizing
    double Function(Unit) getFirstStat;
    double Function(Unit) getSecondStat;

    Color firstColor;
    Color secondColor;

    switch (widget.selectedStat) {
      case StatType.damageBlocked:
        getFirstStat = (u) => u.stats.physicalDamageBlocked.toDouble();
        getSecondStat = (u) => u.stats.magicDamageBlocked.toDouble();
        firstColor = Colors.orangeAccent;
        secondColor = Colors.purpleAccent;
        break;
      case StatType.healingAndShielding:
        getFirstStat = (u) => u.stats.healingDone.toDouble();
        getSecondStat = (u) => u.stats.shieldingDone.toDouble();
        firstColor = Colors.greenAccent;
        secondColor = Colors.lightBlueAccent;
        break;
      default:
        getFirstStat = (u) => u.stats.physicalDamageDone.toDouble();
        getSecondStat = (u) => u.stats.magicDamageDone.toDouble();
        firstColor = Colors.redAccent;
        secondColor = Colors.blueAccent;
    }

    double maxPlayerStat = playerUnits
        .map((u) => getFirstStat(u) + getSecondStat(u))
        .fold(0.0, max);
    double maxEnemyStat = enemyUnits
        .map((u) => getFirstStat(u) + getSecondStat(u))
        .fold(0.0, max);

    Widget buildUnitBar(Unit unit, double maxTeamStat) {
      final first = getFirstStat(unit);
      final second = getSecondStat(unit);
      final total = first + second;
      final firstPercent = maxTeamStat == 0 ? 0.0 : first / maxTeamStat;
      final secondPercent = maxTeamStat == 0 ? 0.0 : second / maxTeamStat;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              unit.unitName,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Text(
              total.toInt().toString(),
              style: const TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Stack(
              children: [
                LinearProgressIndicator(
                  value: firstPercent + secondPercent,
                  minHeight: 8,
                  backgroundColor: Colors.grey[700],
                  color: secondColor,
                ),
                LinearProgressIndicator(
                  value: firstPercent,
                  minHeight: 8,
                  backgroundColor: Colors.transparent,
                  color: firstColor,
                ),
              ],
            ),
          ],
        ),
      );
    }

    List<Unit> sortedPlayerUnits = [...playerUnits]..sort(
      (a, b) => (getFirstStat(b) + getSecondStat(b)).compareTo(
        getFirstStat(a) + getSecondStat(a),
      ),
    );
    List<Unit> sortedEnemyUnits = [...enemyUnits]..sort(
      (a, b) => (getFirstStat(b) + getSecondStat(b)).compareTo(
        getFirstStat(a) + getSecondStat(a),
      ),
    );

    return Container(
      color: Colors.black.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children:
                StatType.values.map((type) {
                  final isSelected = widget.selectedStat == type;
                  final label = type.name
                      .replaceAllMapped(
                        RegExp(r'([A-Z])'),
                        (m) => ' ${m.group(0)}',
                      )
                      .trim()
                      .replaceFirstMapped(
                        RegExp(r'^.'),
                        (m) => m.group(0)!.toUpperCase(),
                      );

                  return SizedBox(
                    height: 28,
                    child: TextButton(
                      onPressed: () => widget.onStatSelected(type),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            isSelected ? Colors.blue : Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(64, 28),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Player Units",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: ListView(
                          children:
                              sortedPlayerUnits
                                  .map((u) => buildUnitBar(u, maxPlayerStat))
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(color: Colors.white70),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Enemy Units",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: ListView(
                          children:
                              sortedEnemyUnits
                                  .map((u) => buildUnitBar(u, maxEnemyStat))
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
