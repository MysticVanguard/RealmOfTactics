import 'package:flutter/material.dart';
import '../models/synergy_manager.dart';

// Main widget that displays current synergy stats on the left panel
class SynergyDisplay extends StatelessWidget {
  final SynergyManager synergyManager;

  const SynergyDisplay({super.key, required this.synergyManager});

  @override
  Widget build(BuildContext context) {
    // Get the current synergy counts from the manager
    final allSynergyCounts = synergyManager.synergyCounts;

    // Sort the synergies alphabetically by name
    final sortedSynergies =
        allSynergyCounts.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey[600]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title header
          Text(
            'Synergies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // List of synergies or fallback message
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (allSynergyCounts.isEmpty)
                    // Fallback when no units are on board
                    Text(
                      'No units on board',
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    // Display each synergy with its data
                    ...sortedSynergies.map(
                      (entry) => _buildSynergyItem(
                        context,
                        entry.key,
                        entry.value,
                        synergyManager.activeSynergiesSet.contains(entry.key),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a single synergy block (title, progress, status)
  Widget _buildSynergyItem(
    BuildContext context,
    String synergy,
    int count,
    bool isActive,
  ) {
    final thresholds = synergyManager.getSynergyThresholds(synergy);
    final isVerySmallScreen = MediaQuery.of(context).size.width < 600;

    // If no thresholds are defined, show basic display
    if (thresholds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display synergy name and inactive tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$synergy: $count',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  "(Inactive)",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontSize: isVerySmallScreen ? 10 : 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Determine which threshold (tier) is currently active
    int activeLevel = -1;
    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (count >= thresholds[i]) {
        activeLevel = i;
        break;
      }
    }

    final int maxNodes = thresholds.isEmpty ? 0 : thresholds.last;
    bool isTrulyActive = activeLevel >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with synergy name and active/inactive label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "$synergy (Current: $count)",
                    style: TextStyle(
                      color: isTrulyActive ? Colors.amber : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isVerySmallScreen ? 12 : 14,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4),
              Flexible(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isTrulyActive ? "(Active)" : "(Inactive)",
                    style: TextStyle(
                      color: isTrulyActive ? Colors.green : Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontSize: isVerySmallScreen ? 10 : 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Row showing each tier threshold (e.g., 2 / 4 / 6)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < thresholds.length; i++) ...[
                  if (i > 0)
                    Text(
                      " / ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isVerySmallScreen ? 12 : 14,
                      ),
                    ),
                  Text(
                    "${thresholds[i]}",
                    style: TextStyle(
                      color: i == activeLevel ? Colors.amber : Colors.white,
                      fontWeight:
                          i == activeLevel
                              ? FontWeight.bold
                              : FontWeight.normal,
                      fontSize: isVerySmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Visual progress bar made of nodes
          if (maxNodes > 0) _buildNodeProgressBar(count, maxNodes, thresholds),

          // Detailed description of the synergy's effects
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildDetailedDescription(
                context,
                synergy,
                activeLevel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a visual progress bar with circular nodes for each synergy tier
  Widget _buildNodeProgressBar(int count, int maxNodes, List<int> thresholds) {
    return Container(
      height: 24,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxNodes, (i) {
            return Container(
              width: 14,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Display a faded threshold marker behind the node if it's a tier
                  if (thresholds.contains(i + 1))
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withOpacity(0.3),
                        border: Border.all(color: Colors.amber),
                      ),
                    ),

                  // Main progress node
                  Container(
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < count ? Colors.amber : Colors.blueGrey[700],
                      border: Border.all(
                        color: i < count ? Colors.amber : Colors.blueGrey[500]!,
                        width: 1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // Returns a list of descriptive Text widgets for a given synergy
  List<Widget> _buildDetailedDescription(
    BuildContext context,
    String synergy,
    int activeLevel,
  ) {
    final isVerySmallScreen = MediaQuery.of(context).size.width < 600;
    final fontSize = isVerySmallScreen ? 10.0 : 12.0;

    // Each block below handles a specific synergy by name
    if (synergy == 'Stormpeak') {
      String combinedDescription =
          "For every 20 Armor, Stormpeak units gain 50/100/150 Health.\n"
          "For every 20 Magic Resist, Stormpeak units gain 1/3/5% Damage Resistance.\n"
          "For every 20 Attack Damage, Stormpeak units gain 1/3/5% Attack Speed.\n"
          "For every 20 Ability Power, Stormpeak units gain 1/2/3 Mana on attack.";

      // Split and individually style each line
      List<String> lines = combinedDescription.split('\n');
      List<Widget> result = [];

      for (String line in lines) {
        result.add(_buildFormattedLine(line, activeLevel, fontSize));
        result.add(SizedBox(height: 2));
      }

      return result;
    }
    // Repeat for each synergy type, calling the shared formatter method
    else if (synergy == 'Knight') {
      String combinedDescription =
          "Knight units gain 10/20/30% Attack Damage and 5/10/15% Lifesteal.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Frostward') {
      String combinedDescription =
          "Frostward units gain 10/15/20/25 Armor and Magic Resist per adjacent Frostward ally.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Ironvale') {
      String combinedDescription =
          "Summon: Drone / Turret / Tank. Ironvale units generate 1 scrap per round per star level.Summon gains +5 Health and +1 AD per scrap.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Chronospark') {
      String combinedDescription =
          "Every 10/5 seconds, Chronospark units heal 5/10% of Max Health.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Stoneborn') {
      String combinedDescription =
          "Stoneborn units gain 20/40/60% Max Health shield at the start of combat if no adjacent allies.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Greendale') {
      String combinedDescription =
          "Greendale units generate 1 gold per round at the start of planning. Gain an additional 1/2/3 gold if you lost last combat.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Forgeheart') {
      String combinedDescription =
          "Forgeheart units gain 1/2/3 unique Forged items and 10/20/30 Armor/Magic Resist.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Defender') {
      String combinedDescription =
          "All units gain 5/15/25 Armor & Magic Resist. Defenders gain 15/45/75 Armor & Magic Resist.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Tank') {
      String combinedDescription =
          "Tank units gain 10/20/40% Max Health. Tank units gain Attack Damage equal to 5% Max Health.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Rifleman') {
      String combinedDescription =
          "Rifleman units gain 5/10 Attack Damage each time they attack.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Beast Rider') {
      String combinedDescription =
          "Beast Rider units gain 20/40/60% Attack Speed and 25% Cleave Damage.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Artillerist') {
      String combinedDescription =
          "Artillerist units deal 50/100/150% bonus Attack Damage in AoE with every 5th attack.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Engineer') {
      String combinedDescription = "Summoned units gain +200/400% Stats.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Runebound') {
      String combinedDescription =
          "Runebound units gain 20/40/60% of item stats as bonus stats at the start of combat.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Emberhill') {
      String combinedDescription =
          "Emberhill units gain 5/10/15% Damage Amp. Moving grants 5/10/15% Attack Speed bonus.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Skyguard') {
      String combinedDescription =
          "Skyguard units gain 5/10/15s evasion after being hit by a melee attack.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Deeprock') {
      String combinedDescription =
          "Deeprock units reduce enemy Armor and Magic Resist by 20/30/40 before casting their ability.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Ironhide') {
      String combinedDescription =
          "Ironhide units stun adjacent enemies for 2s before casting their ability.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Scout') {
      String combinedDescription =
          "Scout units deal 150% damage to the highest health enemy every 8/6/4s. Scout units gain 25/50/100% Movement Speed.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Spellblade') {
      String combinedDescription =
          "Spellblade units convert 50/100% of Ability Power to Attack Damage.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Battlemage') {
      String combinedDescription =
          "Battlemage units gain 20/50/80 Ability Power. Enemies deal 10% less damage to Battlemages.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Runesmith') {
      String combinedDescription =
          "Adjacent allies gain: 100/10/10/10/10 HP/Armor and Magic Resist/Attack Damage/Ability Power/Attack Speed.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    } else if (synergy == 'Cleric') {
      String combinedDescription =
          "Cleric units provide healed units with either 20/40/60% Attack Damage or 20/40/60% Ability Power.";
      return [_buildFormattedLine(combinedDescription, activeLevel, fontSize)];
    }

    // Default fallback for missing description
    return [
      Text(
        "Description not implemented",
        style: TextStyle(
          color: Colors.red,
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
        ),
      ),
    ];
  }

  // Utility method for formatting tiered synergy text and highlighting active tier
  Widget _buildFormattedLine(
    String line,
    int activeLevel, [
    double fontSize = 12.0,
    String? highlightPattern,
  ]) {
    RegExp valuePattern = RegExp(
      highlightPattern ??
          r'(\d+(?:\.\d+)?(?:\%)?)/(\d+(?:\.\d+)?(?:\%)?)/(\d+(?:\.\d+)?(?:\%)?(?:/\d+(?:\.\d+)?(?:\%)?)?)',
      multiLine: true,
    );

    // If no match, return plain styled text
    if (!valuePattern.hasMatch(line)) {
      return Text(
        line,
        style: TextStyle(color: Colors.white70, fontSize: fontSize),
      );
    }

    List<TextSpan> spans = [];
    String remaining = line;

    // Parse and highlight each value segment
    while (valuePattern.hasMatch(remaining)) {
      Match match = valuePattern.firstMatch(remaining)!;

      String beforeMatch = remaining.substring(0, match.start);
      spans.add(
        TextSpan(
          text: beforeMatch,
          style: TextStyle(color: Colors.white70, fontSize: fontSize),
        ),
      );

      String matchedText = match.group(0)!;
      List<String> values = matchedText.split('/');

      for (int i = 0; i < values.length; i++) {
        bool isActive = (i == activeLevel);

        spans.add(
          TextSpan(
            text: values[i],
            style: TextStyle(
              color: isActive ? Colors.amber : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        );

        if (i < values.length - 1) {
          spans.add(
            TextSpan(
              text: "/",
              style: TextStyle(color: Colors.white70, fontSize: fontSize),
            ),
          );
        }
      }

      remaining = remaining.substring(match.end);
    }

    if (remaining.isNotEmpty) {
      spans.add(
        TextSpan(
          text: remaining,
          style: TextStyle(color: Colors.white70, fontSize: fontSize),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      overflow: TextOverflow.ellipsis,
      maxLines: 5,
    );
  }
}
