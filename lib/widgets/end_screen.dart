import 'package:flutter/material.dart';
import 'package:realm_of_tactics/main.dart';
import 'package:realm_of_tactics/models/game_manager.dart';
import 'package:realm_of_tactics/widgets/start_screen.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finalUnits =
        GameManager.instance?.combatManager?.playerUnits
            .where((unit) => !unit.isEnemy)
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(title: const Text('Game Over')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Your Final Team',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: finalUnits.length,
              itemBuilder: (context, index) {
                final unit = finalUnits[index];
                final items = unit.getEquippedItems();
                return ListTile(
                  leading: Image.asset(
                    unit.imagePath,
                    width: 48,
                    height: 48,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.person, color: Colors.amber),
                  ),

                  title: Text(
                    unit.unitName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Row(
                    children:
                        items
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Image.asset(
                                  item.imagePath,
                                  width: 24,
                                  height: 24,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.shield,
                                            color: Colors.lightBlueAccent,
                                          ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              RestartWidget.restartApp(context);
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const StartScreen()),
                (route) => false,
              );
            },
            child: const Text('Play Again', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
