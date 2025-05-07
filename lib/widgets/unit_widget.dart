import 'package:flutter/material.dart';
import 'package:realm_of_tactics/models/item.dart';
import '../models/unit.dart';
import 'resource_bar.dart';

// Widget that displays a unit's icon, tier stars, name, and optionally HP/Mana bars if it's on the board
class UnitWidget extends StatelessWidget {
  final Unit unit;
  final bool isCompact;
  final bool isBoardUnit;
  final bool isEnemy;
  final void Function(Item item)? onItemDropped;

  const UnitWidget({
    super.key,
    required this.unit,
    this.isEnemy = false,
    this.isCompact = true,
    this.isBoardUnit = false,
    this.onItemDropped,
  });

  @override
  Widget build(BuildContext context) {
    final listenedUnit = unit;

    // Defines the outer border and gradient background of the unit card
    final containerDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _getUnitRarityColors(listenedUnit.cost),
      ),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: _getTierBorderColor(listenedUnit.tier),
        width: listenedUnit.tier > 1 ? 2 : 1,
      ),
    );

    // Renders the unit's image or fallback icon
    final unitImage = Center(
      child: Image.asset(
        listenedUnit.imagePath,
        fit: BoxFit.contain,
        errorBuilder:
            (context, error, stackTrace) => Icon(
              _getUnitIcon(listenedUnit.unitClass),
              color: Colors.white,
              size: 24,
            ),
      ),
    );

    // Renders star overlay in top left for units with tier > 1
    final starsOverlay =
        listenedUnit.tier > 1
            ? Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    listenedUnit.tier,
                    (index) => Icon(Icons.star, color: Colors.amber, size: 8),
                  ),
                ),
              ),
            )
            : SizedBox.shrink();

    // If the unit is on the board, include health/mana bars and overlays
    if (isBoardUnit) {
      return DragTarget<Map<String, dynamic>>(
        onWillAccept: (data) {
          if (data == null || data['type'] != 'item') return false;
          final Item item = data['item'] as Item;
          return unit.canEquipItem(item);
        },
        onAccept: (data) {
          final Item item = data['item'] as Item;
          onItemDropped?.call(item);
        },
        builder: (context, candidateData, rejectedData) {
          // highlight if drag is acceptable
          final isHovering = candidateData.isNotEmpty;

          return Container(
            decoration:
                isHovering
                    ? BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                    )
                    : null,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemSize = constraints.maxHeight * 0.25;

                return Container(
                  padding: const EdgeInsets.all(2),
                  decoration: containerDecoration,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Unit image
                      Positioned.fill(child: unitImage),

                      // HP bar
                      Positioned(
                        top: -3,
                        left: 0,
                        right: 0,
                        child: ResourceBar(
                          currentValue: unit.stats.currentHealth.toDouble(),
                          maxValue: unit.stats.maxHealth.toDouble(),
                          secondaryValue: unit.stats.currentShield.toDouble(),
                          primaryColor:
                              isEnemy
                                  ? Colors.red.shade600
                                  : Colors.green.shade600,
                          secondaryColor: Colors.blue.shade300,
                          backgroundColor: Colors.black.withOpacity(0.6),
                          height: 5,
                        ),
                      ),

                      // Mana bar
                      Positioned(
                        bottom: -3,
                        left: 0,
                        right: 0,
                        child: ResourceBar(
                          currentValue: unit.stats.currentMana.toDouble(),
                          maxValue: unit.stats.maxMana.toDouble(),
                          primaryColor: Colors.blue,
                          backgroundColor: Colors.black45,
                          height: 5,
                        ),
                      ),

                      // Star overlay
                      starsOverlay,

                      // Item overlay
                      if (unit.getEquippedItems().isNotEmpty)
                        Positioned(
                          left: -4,
                          top: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (unit.weapon != null)
                                _buildItemIcon(unit.weapon!, itemSize),
                              if (unit.armor != null)
                                _buildItemIcon(unit.armor!, itemSize),
                              if (unit.trinket != null)
                                _buildItemIcon(unit.trinket!, itemSize),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      // Compact unit widget for display in shop or bench
      return DragTarget<Map<String, dynamic>>(
        onWillAccept: (data) {
          if (data == null || data['type'] != 'item') return false;
          final Item item = data['item'] as Item;
          return unit.canEquipItem(item);
        },
        onAccept: (data) {
          final Item item = data['item'] as Item;
          onItemDropped?.call(item);
        },
        builder: (context, candidateData, rejectedData) {
          // highlight if drag is acceptable
          final isHovering = candidateData.isNotEmpty;

          return Container(
            decoration:
                isHovering
                    ? BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                    )
                    : null,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemSize = constraints.maxHeight * 0.25;

                return Container(
                  padding: const EdgeInsets.all(2),
                  decoration: containerDecoration,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Unit image
                      Positioned.fill(child: unitImage),

                      // Star overlay
                      starsOverlay,

                      // Item overlay
                      if (unit.getEquippedItems().isNotEmpty)
                        Positioned(
                          left: -4,
                          top: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (unit.weapon != null)
                                _buildItemIcon(unit.weapon!, itemSize),
                              if (unit.armor != null)
                                _buildItemIcon(unit.armor!, itemSize),
                              if (unit.trinket != null)
                                _buildItemIcon(unit.trinket!, itemSize),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }

  // Returns a color gradient based on the unit's cost (rarity)
  List<Color> _getUnitRarityColors(int cost) {
    switch (cost) {
      case 1:
        return [Colors.grey.shade700, Colors.grey.shade600];
      case 2:
        return [Colors.green.shade800, Colors.green.shade700];
      case 3:
        return [Colors.blue.shade800, Colors.blue.shade700];
      case 4:
        return [Colors.purple.shade800, Colors.purple.shade700];
      case 5:
        return [Colors.orange.shade900, Colors.orange.shade800];
      default:
        return [Colors.blueGrey.shade800, Colors.blueGrey.shade700];
    }
  }

  // Fallback icon if unit image is not found
  IconData _getUnitIcon(String unitClass) {
    switch (unitClass) {
      case 'Warrior':
        return Icons.sports_martial_arts;
      case 'Mage':
        return Icons.auto_fix_high;
      case 'Assassin':
        return Icons.bloodtype;
      case 'Tank':
        return Icons.shield;
      case 'Marksman':
        return Icons.gps_fixed;
      case 'Support':
        return Icons.healing;
      default:
        return Icons.person;
    }
  }

  // Border color changes based on tier
  Color _getTierBorderColor(int tier) {
    switch (tier) {
      case 1:
        return Colors.grey.shade600;
      case 2:
        return Colors.amber.shade700;
      case 3:
        return Colors.amber;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildItemIcon(Item item, double size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Image.asset(
            item.imagePath,
            fit: BoxFit.contain,
            errorBuilder:
                (context, error, stackTrace) =>
                    Icon(Icons.error, size: size * 0.6, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
