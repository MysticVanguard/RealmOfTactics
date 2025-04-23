import 'package:flutter/material.dart';
import '../models/unit.dart';
import 'resource_bar.dart';

// Widget that displays a unit's icon, tier stars, name, and optionally HP/Mana bars if it's on the board
class UnitWidget extends StatelessWidget {
  final Unit unit;
  final bool isCompact;
  final bool isBoardUnit;
  final bool isEnemy;

  const UnitWidget({
    super.key,
    required this.unit,
    this.isEnemy = false,
    this.isCompact = true,
    this.isBoardUnit = false,
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
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: containerDecoration,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Unit image centered inside the tile
            Positioned.fill(child: unitImage),

            // Top bar: health and shield
            Positioned(
              top: -3,
              left: 0,
              right: 0,
              child: ResourceBar(
                currentValue: listenedUnit.stats.currentHealth.toDouble(),
                maxValue: listenedUnit.stats.maxHealth.toDouble(),
                secondaryValue: listenedUnit.stats.currentShield.toDouble(),
                primaryColor:
                    isEnemy ? Colors.red.shade600 : Colors.green.shade600,
                secondaryColor: Colors.blue.shade300,
                backgroundColor: Colors.black.withOpacity(0.6),
                height: 5,
              ),
            ),

            // Bottom bar: mana
            Positioned(
              bottom: -3,
              left: 0,
              right: 0,
              child: ResourceBar(
                currentValue: listenedUnit.stats.currentMana.toDouble(),
                maxValue: listenedUnit.stats.maxMana.toDouble(),
                primaryColor: Colors.blue,
                backgroundColor: Colors.black45,
                height: 5,
              ),
            ),

            // Top-left overlay: stars
            starsOverlay,
          ],
        ),
      );
    } else {
      // Compact unit widget for display in shop or bench
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: containerDecoration,

        child: FittedBox(
          fit: BoxFit.contain,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top: tier stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  listenedUnit.tier,
                  (index) => Icon(Icons.star, color: Colors.amber, size: 10),
                ),
              ),

              // Center: unit image
              unitImage,

              // Bottom: unit name
              Text(
                listenedUnit.unitName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
}
