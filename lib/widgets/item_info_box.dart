import 'package:flutter/material.dart';
import '../models/item.dart';
import '../game_data/items.dart';

// A widget that displays detailed information about an item when selected
class ItemInfoBox extends StatelessWidget {
  final Item item;
  final VoidCallback onClose;

  const ItemInfoBox({Key? key, required this.item, required this.onClose})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose, // Close overlay when tapping outside the box
      child: Container(
        color: Colors.black.withOpacity(
          0.7,
        ), // Dark semi-transparent background
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping the content itself
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getTierColor(item.tier), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with item icon, name, and close button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        item.imagePath,
                        width: 40,
                        height: 40,
                        errorBuilder: (c, e, s) => Icon(Icons.error),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Tier stars and item type display
                            Row(
                              children: List.generate(
                                item.tier,
                                (index) => Icon(
                                  Icons.star,
                                  color: _getTierColor(item.tier),
                                  size: 14,
                                ),
                              )..addAll([
                                SizedBox(width: 5),
                                Text(
                                  '(${item.type.name.capitalize()} T${item.tier})',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                      // Close button
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: onClose,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),

                  Divider(color: Colors.blueGrey[700], height: 20),

                  // Item stat bonuses
                  _buildStatsSection(item.statsBonus),

                  // Unique effect/description if present
                  if (item.uniqueAbilityDescription != null &&
                      item.uniqueAbilityDescription!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        item.uniqueAbilityDescription!,
                        style: TextStyle(
                          color: Colors.cyan[200],
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  // If it's a combined item, show components
                  if (item.tier > 1 && item.componentNames.isNotEmpty)
                    _buildRecipeSection(item.componentNames),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Builds stat bonus lines for the item
  Widget _buildStatsSection(ItemStatsBonus stats) {
    List<Widget> statWidgets = [];

    // Helper to conditionally add stat lines
    void addStat(String label, double value, {bool isPercent = false}) {
      if (value != 0) {
        statWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                Text(
                  "$label: ",
                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                ),
                Text(
                  "${isPercent ? '+' : ''}${value > 0 && !isPercent ? '+' : ''}${isPercent ? (value * 100).toStringAsFixed(0) : value.toStringAsFixed(0)}${isPercent ? '%' : ''}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Add all possible stats
    addStat("Health", stats.bonusMaxHealth);
    addStat("Attack Damage", stats.bonusAttackDamage);
    addStat("AD", stats.bonusAttackDamagePercent, isPercent: true);
    addStat("Attack Speed", stats.bonusAttackSpeedPercent, isPercent: true);
    addStat("Ability Power", stats.bonusAbilityPower);
    addStat("AP", stats.bonusAbilityPowerPercent, isPercent: true);
    addStat("Armor", stats.bonusArmor);
    addStat("Magic Resist", stats.bonusMagicResist);
    addStat("Crit Chance", stats.bonusCritChance * 100, isPercent: true);
    addStat("Crit Damage", stats.bonusCritDamage * 100, isPercent: true);
    addStat("Lifesteal", stats.bonusLifesteal * 100, isPercent: true);
    addStat("Max Mana", stats.bonusManaMax.toDouble());
    addStat("Starting Mana", stats.bonusStartingMana.toDouble());

    if (statWidgets.isEmpty) {
      return SizedBox.shrink(); // No stats to show
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statWidgets,
    );
  }

  // Shows the item recipe using icons of its components
  Widget _buildRecipeSection(List<String> componentNames) {
    List<Widget> componentIcons = [];

    for (String name in componentNames) {
      Item? componentItem;
      try {
        componentItem = allItems.values.firstWhere(
          (i) => i.name == name && i.tier == 1,
        );
      } catch (e) {
        componentItem = null;
      }

      if (componentItem != null) {
        componentIcons.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Image.asset(
              componentItem.imagePath,
              width: 20,
              height: 20,
              errorBuilder: (c, e, s) => Icon(Icons.help_outline, size: 20),
            ),
          ),
        );
      } else {
        componentIcons.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(Icons.help_outline, size: 20, color: Colors.grey),
          ),
        );
      }
    }

    if (componentIcons.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Text(
            "Recipe: ",
            style: TextStyle(color: Colors.grey[300], fontSize: 13),
          ),
          ...componentIcons,
        ],
      ),
    );
  }

  // Returns a color based on item tier
  Color _getTierColor(int tier) {
    if (tier == 1) return Colors.grey.shade400;
    if (tier == 2) return Colors.blue.shade400;
    return Colors.purple.shade400;
  }
}

// Extension to capitalize item type names
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
