import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm_of_tactics/models/combat_manager.dart';
import 'package:realm_of_tactics/models/unit.dart';
import 'package:realm_of_tactics/screens/game_screen.dart';

// Widget for displaying post-combat statistics such as damage dealt, taken, or healing
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
    // Access the CombatManager from the provider
    final combatManager = Provider.of<CombatManager>(context);

    // Get player and enemy units for this round
    final List<Unit> playerUnits = combatManager.playerUnits;
    final List<Unit> enemyUnits = combatManager.enemyUnits;

    // Determine which stat to calculate (damage, healing, or taken)
    double Function(Unit) getStat;
    switch (widget.selectedStat) {
      case StatType.damageTaken:
        getStat = (u) => u.stats.damageTaken.toDouble();
        break;
      case StatType.healing:
        getStat = (u) => u.stats.healingDone.toDouble();
        break;
      default:
        getStat = (u) => u.stats.damageDealt.toDouble();
    }

    // Find the maximum value for each team to normalize progress bars
    double maxPlayerStat = playerUnits.map(getStat).fold(0.0, max);
    double maxEnemyStat = enemyUnits.map(getStat).fold(0.0, max);

    // Builds the UI for a single unit's stat bar
    Widget buildUnitBar(Unit unit, double maxTeamStat) {
      final value = getStat(unit);
      final percent = (maxTeamStat == 0) ? 0.0 : value / maxTeamStat;

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
              value.toInt().toString(),
              style: const TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.grey[700],
              color: Colors.blueAccent,
            ),
          ],
        ),
      );
    }

    // Sort player and enemy units by the selected stat, descending
    List<Unit> sortedPlayerUnits = [...playerUnits]
      ..sort((a, b) => getStat(b).compareTo(getStat(a)));
    List<Unit> sortedEnemyUnits = [...enemyUnits]
      ..sort((a, b) => getStat(b).compareTo(getStat(a)));

    return Container(
      color: Colors.black.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          // Buttons to toggle which stat is being displayed
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children:
                StatType.values.map((type) {
                  final isSelected = widget.selectedStat == type;
                  final label =
                      type.name
                          .replaceAllMapped(
                            RegExp(r'([A-Z])'),
                            (m) => ' ${m.group(0)}',
                          )
                          .trim();

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

          // Two-column layout showing player and enemy stat bars
          Expanded(
            child: Row(
              children: [
                // Player units on the left
                Expanded(
                  child: Column(
                    children: [
                      const Text(
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

                // Enemy units on the right
                Expanded(
                  child: Column(
                    children: [
                      const Text(
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
