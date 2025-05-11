import 'package:flutter/material.dart';
import 'package:realm_of_tactics/screens/game_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GameScreen()),
            );
          },
          child: const Text('Start Game', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
