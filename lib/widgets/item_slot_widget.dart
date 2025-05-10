import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/unit.dart';
import '../enums/item_type.dart';

// Widget that represents an item slot (weapon, armor, trinket) on a unit.
class ItemSlotWidget extends StatelessWidget {
  final Item? item; // The item currently equipped in this slot
  final ItemType slotType; // The type of item this slot accepts
  final Unit unit; // The unit this slot belongs to
  final Function(Map<String, dynamic>, String)
  onEquip; // Called when an item is equipped
  final Function(Item)
  onItemTapped; // Called when the item is tapped to show info

  // Used to prevent re-equipping the same item during drag events
  final String? _initialItemId;

  ItemSlotWidget({
    super.key,
    required this.item,
    required this.slotType,
    required this.unit,
    required this.onEquip,
    required this.onItemTapped,
  }) : _initialItemId = item?.id;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      builder: (context, candidateData, rejectedData) {
        Widget slotContent;

        // If an item is already equipped in this slot
        if (item != null) {
          final currentEquippedItem = item!;
          slotContent = GestureDetector(
            onTap: () => onItemTapped(currentEquippedItem),
            child: _buildItemIcon(currentEquippedItem),
          );
        } else {
          // If no item is equipped, show a placeholder slot icon
          slotContent = _buildPlaceholder(
            isDraggingOver: candidateData.isNotEmpty,
          );
        }

        // Visual indication whether a drag can be accepted
        bool canAcceptVisual = candidateData.any(
          (d) =>
              d != null &&
              d['item'] is Item &&
              item == null &&
              unit.canEquipItem(d['item'] as Item),
        );

        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color:
                canAcceptVisual
                    ? Colors.green.withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.grey.shade600),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: slotContent),
        );
      },

      // Determines if the dropped item can be accepted in this slot
      onWillAccept: (droppedData) {
        if (droppedData == null) return false;
        final Item? droppedItem = droppedData['item'] as Item?;
        if (droppedItem == null) return false;

        return item == null && unit.canEquipItem(droppedItem);
      },

      // Handles logic after item is dropped and accepted
      onAccept: (droppedData) {
        final Item droppedItem = droppedData['item'] as Item;

        // Prevent re-equipping the same item dragged out
        if (droppedItem.id == _initialItemId) {
          return;
        }

        // Call external equip handler
        onEquip(droppedData, droppedData['sourceType']);
      },
    );
  }

  // Builds the item icon widget, with optional reduced opacity when dragging
  Widget _buildItemIcon(Item itemData, {bool isDragging = false}) {
    return Opacity(
      opacity: isDragging ? 0.7 : 1.0,
      child: Image.asset(
        itemData.imagePath,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder:
            (context, error, stackTrace) =>
                Icon(Icons.error, color: Colors.red, size: 30),
      ),
    );
  }

  // Builds the fallback placeholder for an empty item slot
  Widget _buildPlaceholder({bool isDraggingOver = false}) {
    IconData iconData;
    switch (slotType) {
      case ItemType.weapon:
        iconData = Icons.gavel;
        break;
      case ItemType.armor:
        iconData = Icons.shield;
        break;
      case ItemType.trinket:
        iconData = Icons.star;
        break;
    }
    return Icon(
      iconData,
      color: isDraggingOver ? Colors.white : Colors.grey.shade700,
      size: 30,
    );
  }
}
