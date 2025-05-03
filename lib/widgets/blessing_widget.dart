import 'package:flutter/material.dart';
import '../models/game_manager.dart';
import '../models/blessing_data.dart';

class BlessingWidget extends StatefulWidget {
  final List<String> blessings;
  final VoidCallback onClose;
  final VoidCallback onReroll;
  final bool canReroll;

  const BlessingWidget({
    super.key,
    required this.blessings,
    required this.onClose,
    required this.onReroll,
    required this.canReroll,
  });

  @override
  State<BlessingWidget> createState() => _BlessingWidgetState();
}

class _BlessingWidgetState extends State<BlessingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Choose a Blessing",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),

            const SizedBox(height: 20),

            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:
                    widget.blessings.map((blessingName) {
                      final description = BlessingData.getBlessingDescription(
                        blessingName,
                      );

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.purple[800],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white70, width: 1),
                          ),
                          child: InkWell(
                            onTap: () {
                              GameManager.instance!.mapManager.chooseBlessing(
                                blessingName,
                              );
                              widget.onClose();
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  blessingName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  description,
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
              onPressed: widget.canReroll ? widget.onReroll : null,
              style: TextButton.styleFrom(
                foregroundColor:
                    widget.canReroll ? Colors.blueAccent : Colors.grey,
              ),
              child: Text("Reroll (${widget.canReroll ? 1 : 0})"),
            ),
          ],
        ),
      ),
    );
  }
}
