import 'package:flutter/material.dart';
import '../models/item.dart';

// A simple widget for rendering an item icon
class ItemWidget extends StatelessWidget {
  // The item to display
  final Item item;

  const ItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Slight padding around the icon for spacing
      padding: const EdgeInsets.all(2.0),

      // Display the item's image from its asset path
      child: Image.asset(
        item.imagePath,
        fit: BoxFit.contain,

        // Fallback icon if the image asset fails to load
        errorBuilder:
            (context, error, stackTrace) =>
                Icon(Icons.error_outline, color: Colors.orange, size: 20),
      ),
    );
  }
}
