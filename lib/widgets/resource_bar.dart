import 'package:flutter/material.dart';
import 'dart:math';

// A widget that displays a multi-segment resource bar, often used for things like health + shield
class ResourceBar extends StatelessWidget {
  // The primary resource value (e.g., current health)
  final double currentValue;

  // The maximum resource value (e.g., max health)
  final double maxValue;

  // The secondary resource value layered on top (e.g., shield)
  final double secondaryValue;

  // Color for the primary resource segment
  final Color primaryColor;

  // Color for the secondary resource segment
  final Color secondaryColor;

  // Background color of the entire bar
  final Color backgroundColor;

  // Height of the bar in pixels
  final double height;

  // Radius used to round the corners of the bar
  final double borderRadius;

  const ResourceBar({
    super.key,
    required this.currentValue,
    required this.maxValue,
    this.secondaryValue = 0,
    required this.primaryColor,
    this.secondaryColor = Colors.lightBlueAccent,
    this.backgroundColor = Colors.black54,
    this.height = 6.0,
    this.borderRadius = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    // If max is invalid, render an empty placeholder
    if (maxValue <= 0) {
      return SizedBox(height: height);
    }

    // Clamp values to prevent overflow or underflow
    final clampedPrimary = currentValue.clamp(0.0, maxValue);
    final clampedSecondary = secondaryValue.clamp(0.0, double.infinity);

    // Total to display might exceed max (e.g. if shield overflows)
    final totalEffectiveValue = clampedPrimary + clampedSecondary;
    final displayMaxValue = max(maxValue, totalEffectiveValue);

    // Again ensure we're not trying to render a 0-width bar
    if (displayMaxValue <= 0) {
      return SizedBox(height: height);
    }

    // Calculate how much of the bar should be filled by each segment
    final primaryFraction = clampedPrimary / displayMaxValue;
    final secondaryFraction = clampedSecondary / displayMaxValue;

    // Make sure total doesn't exceed full width
    (primaryFraction + secondaryFraction).clamp(0.0, 1.0);

    // Ensure all segments are non-negative
    final safePrimaryFraction = max(0.0, primaryFraction);
    final safeSecondaryFraction = max(0.0, secondaryFraction);
    final safeTotalFraction = (safePrimaryFraction + safeSecondaryFraction)
        .clamp(0.0, 1.0);
    final safeEmptyFraction = max(0.0, 1.0 - safeTotalFraction);

    // Build the segmented bar using flexible layout
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        color: backgroundColor,
        child: Row(
          children: [
            // Primary resource segment
            if (safePrimaryFraction > 0)
              Flexible(
                flex: (safePrimaryFraction * 1000).toInt(),
                child: Container(color: primaryColor),
              ),

            // Secondary resource segment (e.g. shield)
            if (safeSecondaryFraction > 0)
              Flexible(
                flex: (safeSecondaryFraction * 1000).toInt(),
                child: Container(color: secondaryColor),
              ),

            // Transparent remainder of the bar
            if (safeEmptyFraction > 0)
              Flexible(
                flex: (safeEmptyFraction * 1000).toInt(),
                child: Container(color: Colors.transparent),
              ),
          ],
        ),
      ),
    );
  }
}
