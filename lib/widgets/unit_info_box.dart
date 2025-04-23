import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm_of_tactics/models/summoned_unit.dart';
import '../models/unit.dart';
import '../models/item.dart';
import '../enums/item_type.dart';
import '../models/board_manager.dart';
import 'item_slot_widget.dart';
import '../game_data/ability_data.dart';

// A widget that displays a detailed info box for a selected unit, including stats, items, and ability
class UnitInfoBox extends StatelessWidget {
  final Unit unit;
  final VoidCallback onClose;

  const UnitInfoBox({super.key, required this.unit, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final boardManager = Provider.of<BoardManager>(context, listen: false);

    // Only show item slots for non-summoned units
    bool showItemSlots = unit is! SummonedUnit;

    return GestureDetector(
      onTap: onClose,
      child: Stack(
        children: [
          // Semi-transparent background to darken screen behind popup
          Container(
            color: Colors.black.withOpacity(0.7),
            width: double.infinity,
            height: double.infinity,
          ),

          // Actual info box container
          GestureDetector(
            onTap: () {}, // Swallow tap events so they don't close the box
            child: Center(
              child: Container(
                width: 320,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getRarityColor(unit.cost),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),

                // Make content scrollable if too tall
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with unit name and close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            unit.unitName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: onClose,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),

                      // Star icons for unit tier
                      Row(
                        children: List.generate(
                          unit.tier,
                          (index) =>
                              Icon(Icons.star, color: Colors.amber, size: 16),
                        ),
                      ),

                      SizedBox(height: 8),

                      // Origins and classes display
                      _buildInfoSection("Origins", unit.origins.join(", ")),
                      _buildInfoSection("Classes", unit.classes.join(", ")),
                      Divider(color: Colors.blueGrey[700]),

                      // Show item slots if not a summoned unit
                      if (showItemSlots)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildItemSlot(
                                context,
                                boardManager,
                                ItemType.weapon,
                                unit.weapon,
                              ),
                              _buildItemSlot(
                                context,
                                boardManager,
                                ItemType.armor,
                                unit.armor,
                              ),
                              _buildItemSlot(
                                context,
                                boardManager,
                                ItemType.trinket,
                                unit.trinket,
                              ),
                            ],
                          ),
                        ),
                      if (showItemSlots) Divider(color: Colors.blueGrey[700]),

                      // Stats title
                      Text(
                        "Stats",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      // Display unit stats in a grid
                      _buildStatsGrid(context, unit),

                      SizedBox(height: 8),

                      // Board or bench position info
                      _buildInfoSection(
                        "Position",
                        unit.isOnBoard
                            ? "Board (${unit.boardX}, ${unit.boardY})"
                            : "Bench (slot ${unit.benchIndex})",
                      ),

                      // Ability section if unit has one
                      if (unit.abilityName != null &&
                          abilities.containsKey(unit.abilityName)) ...[
                        Divider(color: Colors.blueGrey[700]),
                        Text(
                          "Ability",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          abilities[unit.abilityName!]!.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          abilities[unit.abilityName!]!.description,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Utility to render a row with a label and value
  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  // Builds the stat grid that shows all combat-relevant unit stats
  Widget _buildStatsGrid(BuildContext context, Unit displayUnit) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return GridView.count(
      crossAxisCount: isSmallScreen ? 1 : 2,
      shrinkWrap: true,
      childAspectRatio: isSmallScreen ? 7 : 3.5,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildStatItem(
          "Health",
          "${displayUnit.stats.currentHealth.toInt()}/${displayUnit.stats.maxHealth.toInt()}",
          Icons.favorite,
          Colors.red,
        ),
        _buildStatItem(
          "Mana",
          "${displayUnit.stats.currentMana}/${displayUnit.stats.maxMana}",
          Icons.local_drink,
          Colors.blue,
        ),
        _buildStatItem(
          "Attack Damage",
          displayUnit.stats.attackDamage.toStringAsFixed(1),
          Icons.flash_on,
          Colors.orange,
        ),
        _buildStatItem(
          "Ability Power",
          displayUnit.stats.abilityPower.toStringAsFixed(1),
          Icons.auto_fix_high,
          Colors.purple,
        ),
        _buildStatItem(
          "Attack Speed",
          displayUnit.stats.attackSpeed.toStringAsFixed(2),
          Icons.speed,
          Colors.amber,
        ),
        _buildStatItem(
          "Range",
          displayUnit.stats.range.toStringAsFixed(1),
          Icons.gps_fixed,
          Colors.lightBlue,
        ),
        _buildStatItem(
          "Armor",
          displayUnit.stats.armor.toStringAsFixed(1),
          Icons.shield,
          Colors.grey,
        ),
        _buildStatItem(
          "Magic Resist",
          displayUnit.stats.magicResist.toStringAsFixed(1),
          Icons.security,
          Colors.teal,
        ),
        _buildStatItem(
          "Crit Chance",
          "${(displayUnit.stats.critChance * 100).toInt()}%",
          Icons.bolt,
          Colors.yellow,
        ),
        _buildStatItem(
          "Crit Damage",
          "${(displayUnit.stats.critDamage * 100 - 100).toInt()}%",
          Icons.flash_on,
          Colors.yellow,
        ),
        _buildStatItem(
          "Move Speed",
          displayUnit.stats.movementSpeed.toStringAsFixed(1),
          Icons.directions_run,
          Colors.lime,
        ),
      ],
    );
  }

  // Builds an individual stat row with icon, label, and value
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 4),
        Text(
          "$label: ",
          style: TextStyle(color: Colors.grey[300], fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Builds an interactive item slot for a specific item type (weapon/armor/trinket)
  Widget _buildItemSlot(
    BuildContext context,
    BoardManager boardManager,
    ItemType slotType,
    Item? currentItem,
  ) {
    return ItemSlotWidget(
      item: currentItem,
      slotType: slotType,
      unit: unit,
      onEquip: (Map<String, dynamic> dragData) {
        final Item itemToEquip = dragData['item'] as Item;
        final int? sourceIndex = dragData['sourceIndex'] as int?;
        final String? sourceType = dragData['sourceType'] as String?;

        // Ensure unit is able to equip the item
        if (unit.canEquipItem(itemToEquip)) {
          Item? removedItem;

          // Remove the item from the source bench if needed
          if (sourceType == 'bench' && sourceIndex != null) {
            final dynamic entity = boardManager.getBenchSlotItem(sourceIndex);
            if (entity is Item && entity.id == itemToEquip.id) {
              dynamic removed = boardManager.remove(entity);
              if (removed is Item) {
                removedItem = removed;
              } else {
                return;
              }
            } else {
              return;
            }
          } else {
            removedItem = itemToEquip;
          }

          // Try to equip the item to the unit
          bool equipped = unit.equipItem(removedItem);
          if (equipped) {
            // Item successfully equipped
          } else {
            // If equip failed, return to bench
            boardManager.addItemToBench(removedItem);
          }
        }
      },
      onItemTapped: (Item item) {},
    );
  }

  // Gets the color associated with unit rarity based on gold cost
  Color _getRarityColor(int cost) {
    switch (cost) {
      case 1:
        return Colors.grey.shade400;
      case 2:
        return Colors.green.shade500;
      case 3:
        return Colors.blue.shade500;
      case 4:
        return Colors.purple.shade500;
      case 5:
        return Colors.orange.shade500;
      default:
        return Colors.grey.shade400;
    }
  }
}
