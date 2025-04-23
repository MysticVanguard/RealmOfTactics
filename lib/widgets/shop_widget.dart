import 'package:flutter/material.dart';
import 'dart:math';
import '../models/shop_manager.dart';
import '../models/unit.dart';
import 'unit_widget.dart';

// The shop UI widget that displays units available for purchase during the shopping phase.
class ShopWidget extends StatelessWidget {
  final ShopManager shopManager;
  final Function(int) onPurchaseUnit;
  final VoidCallback onReroll;
  final VoidCallback onClose;

  const ShopWidget({
    super.key,
    required this.shopManager,
    required this.onPurchaseUnit,
    required this.onReroll,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Extract screen sizing and shop data
    final shopUnits = shopManager.shopUnits;
    final isSmallScreen = MediaQuery.of(context).size.width < 800;
    final isVerySmallScreen = MediaQuery.of(context).size.width < 600;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Estimate width of the bench
    final double benchWidthEstimate =
        isVerySmallScreen
            ? screenWidth * 0.19
            : (isSmallScreen ? screenWidth * 0.22 : screenWidth * 0.24);

    // Estimate board layout dimensions
    final availableHeight = screenHeight - AppBar().preferredSize.height - 16;
    final desiredBoardWidth = (availableHeight * 8) / 6;
    final boardSize = min(desiredBoardWidth, screenWidth * 0.6);

    // Compute tile size based on remaining space
    final double spacing = 4.0;
    final double availableHeightPerTile =
        (availableHeight - 40 - (4 * spacing)) / 5;
    final double availableWidthPerTile =
        (benchWidthEstimate - 24 - spacing) / 2;
    final double tileSize = min(
      min(availableWidthPerTile, availableHeightPerTile),
      60.0,
    );
    final double benchWidth = (tileSize * 2) + spacing + 16;

    // Used to calculate remaining width, although result is unused
    final boardContainerWidth = boardSize + 16;
    final remainingWidth = screenWidth - benchWidth - boardContainerWidth;
    max(remainingWidth - 24, screenWidth * 0.12);

    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[900]!.withOpacity(0.95),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isVerySmallScreen) SizedBox(height: 4),

          // Display shop units in a column
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isVerySmallScreen ? 2 : 4),
              child: Column(
                children: [
                  ...List.generate(shopUnits.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: isVerySmallScreen ? 2 : 4,
                        ),
                        child:
                            shopUnits[index] != null
                                ? _buildShopItem(
                                  context,
                                  shopUnits[index]!,
                                  index,
                                  isVerySmallScreen,
                                )
                                : _buildEmptyShopSlot(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Show a reroll button on small screens
          if (isVerySmallScreen)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                height: 30,
                child: ElevatedButton.icon(
                  onPressed: onReroll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  ),
                  icon: Icon(Icons.refresh, size: 10),
                  label: Text('Reroll (2)', style: TextStyle(fontSize: 8)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Builds a visual representation of a shop unit
  Widget _buildShopItem(
    BuildContext context,
    Unit unit,
    int index,
    bool isVerySmallScreen,
  ) {
    return GestureDetector(
      onTap: () {
        onPurchaseUnit(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[700],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _getBorderColorForCost(unit.cost),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Unit icon box
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                padding: EdgeInsets.all(isVerySmallScreen ? 1 : 2),
                color: _getBorderColorForCost(unit.cost).withOpacity(0.3),
                child: Image.asset(
                  unit.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return UnitWidget(unit: unit, isCompact: true);
                  },
                ),
              ),
            ),

            // Text and stat info
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: isVerySmallScreen ? 2 : 4,
                  right: 4,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Unit name
                        Text(
                          unit.unitName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 32,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Unit class list
                        Text(
                          unit.classes.join(', '),
                          style: TextStyle(color: Colors.white70, fontSize: 24),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Unit origin list
                        Text(
                          unit.origins.join(', '),
                          style: TextStyle(color: Colors.white70, fontSize: 24),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Cost display
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getBorderColorForCost(unit.cost),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${unit.cost}g',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty placeholder for shop slots with no unit
  Widget _buildEmptyShopSlot() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[800]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey[700]!, width: 1),
      ),
    );
  }

  // Returns border color based on unit cost
  Color _getBorderColorForCost(int cost) {
    switch (cost) {
      case 1:
        return Colors.grey.shade400;
      case 2:
        return Colors.green.shade400;
      case 3:
        return Colors.blue.shade400;
      case 4:
        return Colors.purple.shade400;
      case 5:
        return Colors.orange.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}
