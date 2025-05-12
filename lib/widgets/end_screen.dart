import 'package:flutter/material.dart';
import 'package:realm_of_tactics/main.dart';
import 'package:realm_of_tactics/models/game_manager.dart';
import 'package:realm_of_tactics/widgets/start_screen.dart';

class EndScreen extends StatelessWidget {
  final startOptionName =
      GameManager.instance?.chosenStartOptionName ?? "Unknown";
  final blessings = GameManager.instance?.mapManager.playerBlessings ?? [];

  EndScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                          const Icon(
                                            Icons.person,
                                            color: Colors.amber,
                                          ),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              child: Image.asset(
                                                item.imagePath,
                                                width: 24,
                                                height: 24,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.shield,
                                                      color:
                                                          Colors
                                                              .lightBlueAccent,
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
                      ],
                    ),
                  ),

                  const SizedBox(width: 32),

                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Option',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          GameManager.instance?.chosenStartOptionName ??
                              'Unknown',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (GameManager
                                .instance
                                ?.mapManager
                                .playerBlessings
                                .isNotEmpty ??
                            false) ...[
                          const Text(
                            'Blessings Chosen',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          ...GameManager.instance!.mapManager.playerBlessings
                              .map(
                                (blessing) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    '- $blessing',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                RestartWidget.restartApp(context);
                navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const StartScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Play Again', style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
