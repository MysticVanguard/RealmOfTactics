import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/board_manager.dart';
import 'models/game_manager.dart';
import 'models/shop_manager.dart';
import 'models/synergy_manager.dart';
import 'models/combat_manager.dart';
import 'screens/game_screen.dart';

// Entry point for the app
void main() {
  // Instantiate and initialize core managers
  final gameManager = GameManager();
  final synergyManager = SynergyManager()..initialize();
  final boardManager = BoardManager(gameManager, synergyManager)..initialize();
  final shopManager = ShopManager(gameManager)..initialize();
  final combatManager = CombatManager(
    boardManager: boardManager,
    synergyManager: synergyManager,
  );

  // Wire up managers to each other
  gameManager.setBoardManager(boardManager);
  gameManager.setSynergyManager(synergyManager);
  gameManager.setCombatManager(combatManager);
  gameManager.setShopManager(shopManager);
  synergyManager.setGameManager(gameManager);

  // Perform game-wide setup
  gameManager.initialize();

  // Launch the app
  runApp(
    MyApp(
      boardManager: boardManager,
      gameManager: gameManager,
      shopManager: shopManager,
      synergyManager: synergyManager,
      combatManager: combatManager,
    ),
  );
}

// Root widget of the app that wires up the state and theme
class MyApp extends StatelessWidget {
  final BoardManager boardManager;
  final GameManager gameManager;
  final ShopManager shopManager;
  final SynergyManager synergyManager;
  final CombatManager combatManager;

  const MyApp({
    super.key,
    required this.boardManager,
    required this.gameManager,
    required this.shopManager,
    required this.synergyManager,
    required this.combatManager,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide all managers to the widget tree so they can be accessed via context
        ChangeNotifierProvider.value(value: boardManager),
        ChangeNotifierProvider.value(value: gameManager),
        ChangeNotifierProvider.value(value: shopManager),
        ChangeNotifierProvider.value(value: synergyManager),
        ChangeNotifierProvider.value(value: combatManager),
      ],
      child: MaterialApp(
        title: 'Realm of Tactics',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Define color scheme and UI theme
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.blueGrey[900],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blueGrey[900],
            foregroundColor: Colors.white,
          ),
        ),
        // Initial screen for the game
        home: const GameScreen(),
      ),
    );
  }
}
