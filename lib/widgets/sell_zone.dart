import 'package:flutter/material.dart';
import 'package:realm_of_tactics/models/summoned_unit.dart';
import '../models/unit.dart';

// A widget representing a drop zone where units can be sold.
class SellZone extends StatelessWidget {
  // Callback triggered when a unit is sold
  final Function(Unit) onSellUnit;

  // Width of the sell zone container
  final double size;

  // Determines if small screen adjustments are needed
  final bool isVerySmallScreen;

  const SellZone({
    required this.onSellUnit,
    this.size = 180,
    this.isVerySmallScreen = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Visual configuration values
    final double iconSize = 18;
    final double fontSize = 12;
    final double borderWidth = 2.0;

    return DragTarget<Map<String, dynamic>>(
      // Determine if the dropped item is valid for selling
      onWillAccept: (data) {
        if (data == null) return false;

        if (data['type'] == 'unit') {
          final Unit unit = data['unit'] as Unit;
          return unit is! SummonedUnit; // Can't sell summons
        }

        if (data['type'] == 'item') {
          return false;
        }

        return false;
      },

      // Handles accepted item drop (unit sell)
      onAccept: (data) {
        if (data['type'] == 'unit') {
          final Unit unit = data['unit'] as Unit;
          onSellUnit(unit);
        }
      },

      // Builds the UI for the sell zone and applies visual cues
      builder: (context, candidateData, rejectedData) {
        bool isValidDrop =
            candidateData.isNotEmpty && candidateData.first != null;

        return Container(
          width: size,
          height: 36,
          decoration: BoxDecoration(
            color:
                isValidDrop
                    ? Colors.red.withOpacity(0.3)
                    : Colors.red.withOpacity(0.1),
            border: Border.all(
              color: Colors.red.withOpacity(isValidDrop ? 0.8 : 0.4),
              width: borderWidth,
            ),
            borderRadius: BorderRadius.circular(8),
          ),

          // Icon and label displayed inside the sell zone
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_forever,
                color: Colors.red.withOpacity(0.8),
                size: iconSize,
              ),
              SizedBox(width: 4),
              Text(
                'Sell',
                style: TextStyle(
                  color: Colors.red.withOpacity(0.8),
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
