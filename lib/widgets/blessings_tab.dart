import 'package:flutter/material.dart';
import '../models/game_manager.dart';
import '../models/blessing_data.dart';

class BlessingsTab extends StatelessWidget {
  const BlessingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final blessings = GameManager.instance!.mapManager.playerBlessings;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Blessings",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          if (blessings.isEmpty)
            Text("No blessings yet", style: TextStyle(color: Colors.white70))
          else
            ...blessings.map(
              (b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b,
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      BlessingData.getBlessingDescription(b),
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
