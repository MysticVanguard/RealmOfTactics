import 'package:flutter/material.dart';
import 'package:realm_of_tactics/models/game_manager.dart';

// Widget to present a full-screen overlay for the player to choose their starting option.
class StartChoiceOverlay extends StatefulWidget {
  final List<StartOption> startOptions; // List of available starting choices
  final void Function(String optionName)
  onChoose; // Callback when a choice is made
  final int rerolls; // Number of rerolls remaining
  final VoidCallback onReroll; // Callback when reroll is clicked

  const StartChoiceOverlay({
    required this.startOptions,
    required this.rerolls,
    required this.onChoose,
    required this.onReroll,
    super.key,
  });

  @override
  State<StartChoiceOverlay> createState() => _StartChoiceOverlayState();
}

class _StartChoiceOverlayState extends State<StartChoiceOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Dimmed full-screen background
      color: Colors.black.withOpacity(0.85),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              "Choose Your Start",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),

            const SizedBox(height: 20),

            // Start options displayed horizontally
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:
                    widget.startOptions.map((option) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[800],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white70, width: 1),
                          ),

                          // Each option is tappable
                          child: InkWell(
                            onTap: () => widget.onChoose(option.name),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Option title
                                Text(
                                  option.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Option description
                                Text(
                                  option.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Reroll button
            TextButton(
              onPressed: widget.rerolls > 0 ? widget.onReroll : null,
              style: TextButton.styleFrom(
                foregroundColor:
                    widget.rerolls > 0 ? Colors.blueAccent : Colors.grey,
              ),
              child: Text("Reroll (${widget.rerolls})"),
            ),
          ],
        ),
      ),
    );
  }
}
