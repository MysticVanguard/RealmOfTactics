import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm_of_tactics/models/map_manager.dart';
import 'package:realm_of_tactics/widgets/combat_stats_tab.dart';
import 'package:realm_of_tactics/widgets/start_choice_ui.dart';
import 'package:realm_of_tactics/widgets/unit_info_box.dart';
import 'dart:math';
import '../models/board_manager.dart';
import '../models/game_manager.dart';
import '../models/shop_manager.dart';
import '../models/synergy_manager.dart';
import '../models/unit.dart';
import '../models/item.dart';
import '../widgets/game_board.dart';
import '../widgets/shop_widget.dart';
import '../widgets/synergy_display.dart';
import '../widgets/unit_widget.dart';
import '../widgets/item_widget.dart';
import '../widgets/item_info_box.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/map_widget.dart';

// A simple data class representing a tutorial screen's content
class TutorialPage {
  final String imagePath;
  final String text;

  TutorialPage({required this.imagePath, required this.text});
}

// Enum used to control which stat to display in the stats panel
enum StatType { damageDealt, damageBlocked, healingAndShielding }

// The main screen of the game, managing gameplay interaction and UI state
class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Currently selected unit, used for displaying stats/details
  Unit? selectedUnit;

  // 0 = Units, 1 = Items
  int _selectedBenchTab = 0;

  // Info item displayed in the unit details
  Item? _infoItem;

  // Toggles for UI visibility
  bool _isShopOpen = false;
  bool _isStatsOpen = false;
  bool _isDragging = false;

  // Current selected stat tab in stats panel
  StatType _selectedStat = StatType.damageDealt;

  MapNode? _selectedMapNode;

  // Global key used to measure board position for animations
  final GlobalKey boardKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Hook board key into GameManager so it can calculate positions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameManager>(context, listen: false).setBoardKey(boardKey);
    });

    // Setup the overlay/ticker in the GameManager for animations and effects
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      final gameManager = GameManager.instance;
      if (gameManager != null) {
        gameManager.overlayState = overlay;
        gameManager.overlayTicker = this;
      }
    });
  }

  // Tutorial screens displayed in order
  final List<TutorialPage> _tutorialPages = [
    TutorialPage(
      imagePath: 'assets/images/tutorial_images/TutorialImageStartChoice.png',
      text: '''At the start of every game, you get to choose your start...''',
    ),
    TutorialPage(
      imagePath: 'assets/images/tutorial_images/TutorialImageGold.png',
      text: '''Gold is used for buying units...''',
    ),
    TutorialPage(
      imagePath: 'assets/images/tutorial_images/TutorialImageLevel.png',
      text: '''The other thing you can spend your gold on is buying XP...''',
    ),
    TutorialPage(
      imagePath: 'assets/images/tutorial_images/TutorialImageEnemyBoard.png',
      text:
          '''Now that we have chosen our start, there's just a few more things to go over...''',
    ),
    TutorialPage(
      imagePath: 'assets/images/tutorial_images/TutorialImageButtons.png',
      text: '''From this main screen there are 3 buttons...''',
    ),
    TutorialPage(
      imagePath: 'assets/images/tutorial_images/TutorialImageShop.png',
      text: '''This is the shop...''',
    ),
  ];

  // Tracks the current tutorial page index
  int _tutorialPageIndex = 0;

  // Whether or not the tutorial modal is open
  bool _showTutorial = false;

  // Select a unit on the board or bench
  void _selectUnit(Unit unit) {
    setState(() {
      selectedUnit = unit;
    });
  }

  // Deselect the currently selected unit
  void _deselectUnit() {
    setState(() {
      selectedUnit = null;
    });
  }

  // Attempts to sell the selected unit
  void _handleSellUnit(Unit unit) {
    final boardManager = Provider.of<BoardManager>(context, listen: false);
    final gameManager = Provider.of<GameManager>(context, listen: false);

    if (gameManager.currentState == GameState.combat) {
      // Prevent selling during combat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot sell units during combat!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Try to sell unit, get gold if successful
    int goldReceived = boardManager.sellUnit(unit);

    if (goldReceived > 0) {
      gameManager.addGold(goldReceived);

      // Show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sold ${unit.unitName} for $goldReceived gold',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).size.height -
                AppBar().preferredSize.height,
            left: MediaQuery.of(context).size.width / 3,
            right: MediaQuery.of(context).size.width / 3,
          ),
        ),
      );

      // Deselect if it was the selected unit
      if (selectedUnit?.id == unit.id) {
        _deselectUnit();
      }
    } else {
      // Error if the unit still has items
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Must remove items from unit to sell',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).size.height -
                AppBar().preferredSize.height,
            left: MediaQuery.of(context).size.width / 3,
            right: MediaQuery.of(context).size.width / 3,
          ),
        ),
      );
    }
  }

  // Handles buying a unit from the shop
  void _purchaseUnit(int shopIndex) {
    final shopManager = Provider.of<ShopManager>(context, listen: false);
    final boardManager = Provider.of<BoardManager>(context, listen: false);
    final gameManager = Provider.of<GameManager>(context, listen: false);
    final unit = shopManager.shopUnits[shopIndex];

    if (gameManager.currentState == GameState.combat) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot purchase units during combat!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (boardManager.isBenchFull()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bench is full! Sell units to make space.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (unit != null && shopManager.tryPurchaseUnit(shopIndex)) {
      boardManager.addUnitToBench(unit);
    }
  }

  // Refreshes the shop with a reroll
  void _rerollShop() {
    final shopManager = Provider.of<ShopManager>(context, listen: false);
    shopManager.tryReroll();
  }

  // Buys XP to level up the player
  void _levelUp() {
    final gameManager = Provider.of<GameManager>(context, listen: false);
    gameManager.levelUp();
  }

  // Starts the combat round
  void _startCombatRound() {
    final gameManager = Provider.of<GameManager>(context, listen: false);
    gameManager.startCombatRound();
  }

  // Toggles shop panel open/close
  void _toggleShop() {
    final gameManager = Provider.of<GameManager>(context, listen: false);

    if (gameManager.currentState == GameState.combat) {
      return;
    }

    setState(() {
      _isShopOpen = !_isShopOpen;
    });
  }

  // Clean up
  @override
  void dispose() {
    Provider.of<BoardManager>(context, listen: false);
    super.dispose();
  }

  // New tab on the left with node info when the nodes are selected
  Widget _buildNodeInfoBox(MapNode? node) {
    if (node != null && node.rewardDescription.isEmpty) {
      node.rewardDescription = "💡 DEBUG: No reward found!";
    }
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
            "Node Info",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (node == null)
                    Text(
                      "Nothing selected",
                      style: TextStyle(color: Colors.white70),
                    )
                  else if (node.type == MapNodeType.combat ||
                      node.type == MapNodeType.elite)
                    ..._buildCombatPreviewLines(node)
                  else
                    Text(node.type.name, style: TextStyle(color: Colors.white)),
                  if (node != null && node.rewardDescription.isNotEmpty) ...[
                    Text(
                      "Rewards:",
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      node.rewardDescription,
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The actual text displayed when a combat/elite node is hovered
  List<Widget> _buildCombatPreviewLines(MapNode node) {
    final List<Widget> lines = [];

    final bool isElite = node.type == MapNodeType.elite;
    final bool isBoss = node.type == MapNodeType.boss;

    for (int i = 0; i < node.rounds.length; i++) {
      final round = node.rounds[i];

      final Map<String, int> countMap = {};
      final Map<String, int> tierMap = {};

      for (final unit in round) {
        countMap[unit.name] = (countMap[unit.name] ?? 0) + 1;
        tierMap[unit.name] = unit.tier; // capture the tier
      }

      final units = countMap.entries.toList();

      // Add round header
      lines.add(
        Text(
          "${isBoss ? "Boss Round" : (isElite ? "Elite Round" : "Round")} ${i + 1}:",
          style: TextStyle(
            color:
                isBoss
                    ? Colors.redAccent
                    : (isElite ? Colors.purpleAccent : Colors.white),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      );

      // Show units 2 per row
      for (int j = 0; j < units.length; j += 2) {
        final left = units[j];
        final right = (j + 1 < units.length) ? units[j + 1] : null;

        lines.add(
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "⭐${tierMap[left.key] ?? 1} ${left.key} x${left.value}",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (right != null)
                  Expanded(
                    child: Text(
                      "⭐${tierMap[right.key] ?? 1} ${right.key} x${right.value}",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  Spacer(), // fill if no second unit
              ],
            ),
          ),
        );
      }

      lines.add(SizedBox(height: 6));
    }

    return lines;
  }

  // Builds the main game UI including board, bench, shop, stats, combat controls, and overlays
  @override
  Widget build(BuildContext context) {
    // Screen dimensions and breakpoints
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 1200;
    final isVerySmallScreen = screenSize.width < 900;

    // Access game-related managers
    final gameManager = Provider.of<GameManager>(context);
    final boardManager = Provider.of<BoardManager>(context);
    final shopManager = Provider.of<ShopManager>(context);
    final synergyManager = Provider.of<SynergyManager>(context);
    final bool isInCombat = gameManager.currentState == GameState.combat;

    // Automatically close shop if combat starts
    if (isInCombat && _isShopOpen) {
      _isShopOpen = false;
    }

    // Determine available board area
    final availableHeight =
        screenSize.height - AppBar().preferredSize.height - 16;
    final desiredBoardWidth = (availableHeight * 8) / 6;
    final boardSize = min(desiredBoardWidth, screenSize.width * 0.6);
    final boardHeight = (boardSize * 6) / 8;

    // Estimate bench width based on screen size
    final double benchWidthEstimate =
        isVerySmallScreen
            ? screenSize.width * 0.14
            : (isSmallScreen
                ? screenSize.width * 0.17
                : screenSize.width * 0.18);

    // Space remaining for left-side panels
    final boardContainerWidth = boardSize + 16;
    final remainingWidth =
        screenSize.width - benchWidthEstimate - boardContainerWidth;
    max(remainingWidth - 24, screenSize.width * 0.15);

    // Hide stats panel if shop is opened
    if (_isShopOpen && _isStatsOpen) _isStatsOpen = false;
    // Hide shop and stats if opened during map
    if (gameManager.currentState == GameState.map) {
      _isStatsOpen = false;
      _isShopOpen = false;
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            toolbarHeight: 24,
            centerTitle: false,

            // Top bar buttons for shop, help, stats, reroll, and combat
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shop toggle button
                IconButton(
                  icon: Icon(
                    _isShopOpen ? Icons.store_outlined : Icons.store,
                    color:
                        (isInCombat ||
                                gameManager.currentState == GameState.map ||
                                gameManager.currentState ==
                                    GameState.chooseStart)
                            ? Colors.grey
                            : Colors.white,
                  ),
                  onPressed:
                      (isInCombat ||
                              gameManager.currentState == GameState.map ||
                              gameManager.currentState == GameState.chooseStart)
                          ? null
                          : _toggleShop,
                  tooltip:
                      (isInCombat ||
                              gameManager.currentState == GameState.map ||
                              gameManager.currentState == GameState.chooseStart)
                          ? 'Shop disabled right now'
                          : 'Toggle Shop',
                ),

                // Help and Stats toggle
                if (!_isShopOpen)
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.white),
                    tooltip: "How to Play",
                    onPressed: () {
                      setState(() {
                        _showTutorial = true;
                      });
                    },
                  ),
                if (!_isShopOpen)
                  IconButton(
                    icon: Icon(
                      Icons.bar_chart,
                      color:
                          (gameManager.currentState == GameState.map ||
                                  gameManager.currentState ==
                                      GameState.chooseStart)
                              ? Colors.grey
                              : Colors.white,
                    ),
                    tooltip:
                        (gameManager.currentState == GameState.map ||
                                gameManager.currentState ==
                                    GameState.chooseStart)
                            ? "Stats disabled right now"
                            : "Combat Stats",
                    onPressed:
                        (gameManager.currentState == GameState.map ||
                                gameManager.currentState ==
                                    GameState.chooseStart)
                            ? null
                            : () {
                              setState(() {
                                _isStatsOpen = !_isStatsOpen;
                              });
                            },
                  ),

                // Reroll button when shop is open
                if (_isShopOpen && !isVerySmallScreen)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: _rerollShop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        minimumSize: Size(0, 36),
                      ),
                      icon: Icon(
                        Icons.refresh,
                        size: isVerySmallScreen ? 14 : 16,
                      ),
                      label: Text(
                        (shopManager.freeRefreshAmount > 0)
                            ? 'Free Refresh'
                            : 'Reroll (2)',
                        style: TextStyle(fontSize: isVerySmallScreen ? 10 : 12),
                      ),
                    ),
                  ),
              ],
            ),

            // Top right player/combat controls
            actions: [
              // Game state summary
              if (!isSmallScreen && !isVerySmallScreen)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildGameStateHeader(gameManager),
                ),

              // Player stats panel
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildPlayerInfo(gameManager),
                ),
              ),

              // Start combat button
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 4.0),
                child: ElevatedButton.icon(
                  onPressed: _startCombatRound,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                      horizontal: isVerySmallScreen ? 4 : 6,
                      vertical: 0,
                    ),
                    minimumSize: Size(0, 36),
                  ),
                  icon: Icon(
                    Icons.sports_martial_arts,
                    size: isVerySmallScreen ? 12 : 16,
                  ),
                  label: Text(
                    'Combat',
                    style: TextStyle(fontSize: isVerySmallScreen ? 10 : 12),
                  ),
                ),
              ),
            ],
            backgroundColor: Colors.blueGrey[900],
            automaticallyImplyLeading: false,
          ),

          // Body area for game layout
          body: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left panel - Shop, Stats, or Synergy
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        // Shop / Stats / Synergy toggle area
                        Container(
                          padding: EdgeInsets.all(isVerySmallScreen ? 4 : 8),
                          constraints: BoxConstraints(
                            minWidth: screenSize.width * 0.25,
                          ),
                          child:
                              _isShopOpen
                                  ? ShopWidget(
                                    shopManager: shopManager,
                                    onReroll: _rerollShop,
                                    onPurchaseUnit: _purchaseUnit,
                                    onClose: _toggleShop,
                                  )
                                  : _isStatsOpen
                                  ? CombatStatsTab(
                                    selectedStat: _selectedStat,
                                    onStatSelected: (newStat) {
                                      setState(() {
                                        _selectedStat = newStat;
                                      });
                                    },
                                  )
                                  : gameManager.currentState == GameState.map
                                  ? _buildNodeInfoBox(_selectedMapNode)
                                  : SynergyDisplay(
                                    synergyManager: synergyManager,
                                  ),
                        ),

                        // Drag target for selling units
                        if (!isInCombat)
                          DragTarget<Map<String, dynamic>>(
                            onWillAccept:
                                (data) =>
                                    data != null && data['type'] == 'unit',
                            onAccept: (data) {
                              final Unit unit = data['unit'] as Unit;
                              _handleSellUnit(unit);
                            },
                            builder: (context, candidateData, rejectedData) {
                              bool isHovering = candidateData.isNotEmpty;
                              Unit? hoveringUnit;
                              int sellValue = 0;

                              if (isHovering && candidateData.first != null) {
                                final data = candidateData.first!;
                                if (data['type'] == 'unit') {
                                  hoveringUnit = data['unit'] as Unit;
                                  sellValue = boardManager.calculateSellValue(
                                    hoveringUnit,
                                  );
                                }
                              }

                              // Sell hover UI overlay
                              return isHovering
                                  ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.3),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.6),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Sell Unit?',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.monetization_on,
                                                color: Colors.amber,
                                                size: 24,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '+$sellValue Gold',
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  : Container();
                            },
                          ),
                      ],
                    ),
                  ),

                  // Board in the center
                  Container(
                    width: boardContainerWidth,
                    padding: EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        // Main board with aspect ratio
                        Container(
                          padding: EdgeInsets.all(2),
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 8 / 6,
                              child: Container(
                                width: boardSize,
                                height: boardHeight,
                                child: GameBoard(
                                  key: boardKey,
                                  boardManager: boardManager,
                                  onUnitSelected: _selectUnit,
                                  onClearSelection: _deselectUnit,
                                  selectedUnit: selectedUnit,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Start choice overlay
                        if (gameManager.currentState == GameState.chooseStart)
                          StartChoiceOverlay(
                            startOptions: gameManager.currentStartOptions,
                            rerolls: gameManager.startRerolls,
                            onChoose: (optionKey) {
                              gameManager.applyStartOption(optionKey);
                              // now handled inside applyStartOption -> sets state to map
                            },
                            onReroll: () {
                              gameManager.useStartReroll();
                            },
                          )
                        else if (gameManager.currentState == GameState.map)
                          MapWidget(
                            mapManager: gameManager.mapManager,
                            onNodeSelected: (node) {
                              setState(() {
                                gameManager.mapManager.selectNode(node);
                                _selectedMapNode = gameManager
                                    .mapManager
                                    .map[node.floor]
                                    .firstWhere((n) => n.index == node.index);
                              });
                            },
                            onConfirmSelection: () {
                              gameManager.enterSelectedMapNode();
                            },
                          ),

                        // Item info overlay
                        if (_infoItem != null)
                          ItemInfoBox(
                            item: _infoItem!,
                            onClose: () {
                              setState(() {
                                _infoItem = null;
                              });
                            },
                          ),

                        // Unit info overlay
                        if (selectedUnit != null)
                          UnitInfoBox(
                            unit: selectedUnit!,
                            onClose: () {
                              setState(() {
                                selectedUnit = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),

                  // Bench panel on the right
                  Container(
                    width: benchWidthEstimate,
                    padding: EdgeInsets.symmetric(
                      vertical: isVerySmallScreen ? 4 : 8,
                      horizontal: isVerySmallScreen ? 2 : 4,
                    ),
                    child: _buildVerticalBench(
                      boardManager,
                      isSmallScreen,
                      isVerySmallScreen,
                      benchWidthEstimate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tutorial overlay, if active
        if (_showTutorial)
          Positioned.fill(
            child: Stack(
              children: [
                // Dimmed background
                AbsorbPointer(
                  absorbing: true,
                  child: Container(color: Colors.black.withOpacity(0.75)),
                ),

                // Tutorial content card
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    heightFactor: 0.8,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image
                              Expanded(
                                flex: 5,
                                child: Image.asset(
                                  _tutorialPages[_tutorialPageIndex].imagePath,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Tutorial text
                              Expanded(
                                flex: 2,
                                child: AutoSizeText(
                                  _tutorialPages[_tutorialPageIndex].text,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration: TextDecoration.none,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 10,
                                  minFontSize: 10,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Navigation controls
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (_tutorialPageIndex > 0)
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_left,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _tutorialPageIndex--;
                                        });
                                      },
                                    )
                                  else
                                    SizedBox(width: 48),
                                  if (_tutorialPageIndex <
                                      _tutorialPages.length - 1)
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_right,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _tutorialPageIndex++;
                                        });
                                      },
                                    )
                                  else
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _showTutorial = false;
                                          _tutorialPageIndex = 0;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        "Close",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),

                          // Close button in top right
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _showTutorial = false;
                                  _tutorialPageIndex = 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Builds the player's HUD info bar (health, gold, level, XP)
  Widget _buildPlayerInfo(GameManager gameManager) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 800;
    final bool isVerySmallScreen = screenSize.width < 600;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player Health
          Icon(
            Icons.favorite,
            color: Colors.red,
            size: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
          ),
          SizedBox(width: 2),
          Text(
            '${gameManager.playerHealth}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isVerySmallScreen ? 9 : (isSmallScreen ? 10 : 12),
            ),
          ),
          SizedBox(width: isVerySmallScreen ? 2 : 4),

          // Player Gold
          Icon(
            Icons.monetization_on,
            color: Colors.amber,
            size: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
          ),
          SizedBox(width: 2),
          Text(
            '${gameManager.gold}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isVerySmallScreen ? 9 : (isSmallScreen ? 10 : 12),
            ),
          ),
          SizedBox(width: isVerySmallScreen ? 2 : 4),

          // Player Level
          Icon(
            Icons.arrow_upward,
            color: Colors.blue,
            size: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
          ),
          SizedBox(width: 2),
          Text(
            'Lvl ${gameManager.playerLevel}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isVerySmallScreen ? 9 : (isSmallScreen ? 10 : 12),
            ),
          ),

          // Player XP progress (hidden on very small screens)
          if (!isVerySmallScreen)
            Text(
              ' (${gameManager.currentXpProgress}/${gameManager.xpForNextLevel})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isVerySmallScreen ? 9 : (isSmallScreen ? 10 : 12),
              ),
            ),
        ],
      ),
    );
  }

  // Displays the current game phase/status (Combat, Planning, Game Over, etc.)
  Widget _buildGameStateHeader(GameManager gameManager) {
    String stateText;
    Color stateColor;

    // Set label and color based on current game state
    switch (gameManager.currentState) {
      case GameState.combat:
        stateText = 'Combat';
        stateColor = Colors.red;
        break;
      case GameState.shopping:
        stateText = 'Planning';
        stateColor = Colors.green;
        break;
      case GameState.postCombat:
        stateText = 'Round Over';
        stateColor = Colors.orange;
        break;
      case GameState.gameOver:
        stateText = 'Game Over';
        stateColor = Colors.grey;
        break;
      case GameState.chooseStart:
        stateText = 'Choose Start';
        stateColor = Colors.blue;
        break;
      case GameState.map:
        stateText = 'Choose Start';
        stateColor = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: stateColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stateText,
            style: TextStyle(
              color: stateColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 4),
          Text(
            'S${gameManager.currentStage}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Builds the vertical bench on the right side of the screen (2x6 grid)
  Widget _buildVerticalBench(
    BoardManager boardManager,
    bool isSmallScreen,
    bool isVerySmallScreen,
    double benchWidthEstimate,
  ) {
    final gameManager = Provider.of<GameManager>(context);
    final bool isInCombat = gameManager.currentState == GameState.combat;

    final containerWidth = benchWidthEstimate - 8;

    final units =
        boardManager.getAllBenchUnits()..sort((a, b) {
          int costCompare = a.cost.compareTo(b.cost);
          if (costCompare != 0) return costCompare;
          int nameCompare = a.unitName.compareTo(b.unitName);
          if (nameCompare != 0) return nameCompare;
          return b.tier.compareTo(a.tier);
        });
    final items =
        boardManager.getAllBenchItems()..sort((a, b) {
          int tierCompare = b.tier.compareTo(a.tier);
          if (tierCompare != 0) return tierCompare;
          return b.name.compareTo(a.name);
        });

    // Determine grid content
    final bool showingUnits = _selectedBenchTab == 0;
    final int itemCount = items.length;
    final int itemSlots = ((itemCount / 10).ceil()) * 10;

    final int gridCount = showingUnits ? 12 : itemSlots;
    final List<dynamic> gridItems = showingUnits ? units : items;

    return Container(
      width: containerWidth,
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Tab selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedBenchTab = 0;
                    });
                  },
                  child: AutoSizeText(
                    "Units",
                    maxLines: 1,
                    minFontSize: 8,
                    style: TextStyle(
                      color:
                          _selectedBenchTab == 0
                              ? Colors.white
                              : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedBenchTab = 1;
                    });
                  },
                  child: AutoSizeText(
                    "Items",
                    maxLines: 1,
                    minFontSize: 8,
                    style: TextStyle(
                      color:
                          _selectedBenchTab == 1
                              ? Colors.white
                              : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),

          // Grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double spacing = 4.0;
                final double tileSize = min(
                  (constraints.maxHeight - (spacing * 6)) / 6,
                  (containerWidth - (3 * spacing)) / 2,
                );

                return GridView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: 1,
                  ),
                  itemCount: gridCount,
                  itemBuilder: (context, index) {
                    final content =
                        (index < gridItems.length) ? gridItems[index] : null;
                    return _buildBenchTile(content, tileSize, isInCombat);
                  },
                );
              },
            ),
          ),

          // XP button below bench (only visible outside combat)
          if (showingUnits && !isInCombat)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: double.infinity,
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: _levelUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: Icon(Icons.arrow_upward, size: 16),
                  label: Text(
                    'Buy XP',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Builds a single bench slot (drag target) which can hold either a unit or an item
  Widget _buildBenchTile(
    dynamic benchContent,
    double tileSize,
    bool isInCombat,
  ) {
    final boardManager = Provider.of<BoardManager>(context, listen: false);

    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) {
        if (data == null) return false;
        return data['type'] == 'unit' || data['type'] == 'item';
      },
      onAccept: (data) {
        if (data['type'] == 'unit') {
          final Unit draggedUnit = data['unit'] as Unit;
          final String sourceType = data['sourceType'];

          if (sourceType == 'board') {
            // Dragged from board to bench
            boardManager.addUnitToBench(draggedUnit);
          } else if (sourceType == 'bench') {
            // Swapping bench units (optional)
          }
        } else if (data['type'] == 'item') {
          final Item draggedItem = data['item'] as Item;

          if (benchContent is Item) {
            // Try to combine if compatible
            final Item? combined = draggedItem.combine(benchContent);
            if (combined != null) {
              boardManager.remove(draggedItem);
              boardManager.remove(benchContent);
              boardManager.addItemToBench(combined);
            }
          } else {
            // If empty slot
            boardManager.remove(draggedItem);
            boardManager.addItemToBench(draggedItem);
          }
        }

        setState(() {});
      },
      builder: (context, candidateData, rejectedData) {
        bool isDropping = candidateData.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color:
                isDropping
                    ? Colors.green.withOpacity(0.4)
                    : Colors.blueGrey[600],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blueGrey[500]!),
          ),
          child:
              (benchContent != null)
                  ? (benchContent is Unit
                      ? _buildDraggableUnitWidget(
                        benchContent,
                        tileSize,
                        isInCombat,
                      )
                      : _buildDraggableItemWidget(
                        benchContent,
                        tileSize,
                        isInCombat,
                      ))
                  : null,
        );
      },
    );
  }

  // Builds a draggable unit widget that responds differently depending on whether combat is active
  Widget _buildDraggableUnitWidget(
    Unit unit,
    double tileSize,
    bool isInCombat,
  ) {
    // If it's combat, handle drag gestures and selection in a slightly stricter way
    if (isInCombat) {
      bool hasDragged = false;

      return Listener(
        onPointerDown: (_) => hasDragged = false,
        onPointerMove: (_) => hasDragged = true,

        // Wraps the unit in a Draggable with proper drag data and visuals
        child: Draggable<Map<String, dynamic>>(
          data: {
            'type': 'unit',
            'unit': unit,
            'sourceIndex': unit.benchIndex,
            'sourceType': unit.isOnBoard ? 'board' : 'bench',
          },

          // What appears during drag
          feedback: Material(
            elevation: 8,
            color: Colors.transparent,
            child: Container(
              width: tileSize * 1.1,
              height: tileSize * 1.1,
              child: UnitWidget(unit: unit, isEnemy: unit.isEnemy),
            ),
          ),

          // Placeholder widget when unit is being dragged
          childWhenDragging: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey, width: 1),
            ),
          ),

          onDragStarted: () => hasDragged = true,

          // Allows tapping the unit to select it (if it wasn’t dragged)
          child: GestureDetector(
            onTap: () {
              if (!hasDragged) {
                _selectUnit(unit);
              }
            },
            child: UnitWidget(unit: unit, isEnemy: unit.isEnemy),
          ),
        ),
      );
    } else {
      // During non-combat, allow regular drag behavior with selection on tap
      return Listener(
        onPointerDown: (_) {},
        onPointerMove: (_) {
          _isDragging = true;
        },
        onPointerUp: (_) {
          if (!_isDragging) {
            _selectUnit(unit);
          }
          _isDragging = false;
        },

        // Standard draggable for unit when not in combat
        child: Draggable<Map<String, dynamic>>(
          data: {
            'type': 'unit',
            'unit': unit,
            'sourceIndex': unit.benchIndex,
            'sourceType': unit.isOnBoard ? 'board' : 'bench',
          },
          feedback: Material(
            elevation: 8,
            color: Colors.transparent,
            child: Container(
              width: tileSize * 1.1,
              height: tileSize * 1.1,
              child: UnitWidget(unit: unit, isEnemy: unit.isEnemy),
            ),
          ),
          childWhenDragging: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: UnitWidget(unit: unit, isEnemy: unit.isEnemy),
        ),
      );
    }
  }

  // Builds a draggable item widget, tapping reveals item info, and dragging allows swapping
  Widget _buildDraggableItemWidget(
    Item item,
    double tileSize,
    bool isInCombat,
  ) {
    final int benchIndex = item.benchIndex;

    return GestureDetector(
      // On tap, open the info box for this item
      onTap: () {
        setState(() {
          _infoItem = item;
        });
      },

      // If in combat, don't allow drag behavior
      child:
          isInCombat
              ? ItemWidget(item: item)
              // Otherwise allow item to be dragged with proper drag metadata
              : Draggable<Map<String, dynamic>>(
                data: {
                  'type': 'item',
                  'item': item,
                  'sourceIndex': benchIndex,
                  'sourceType': 'bench',
                },
                feedback: Material(
                  elevation: 8,
                  color: Colors.transparent,
                  child: Container(
                    width: tileSize * 1.1,
                    height: tileSize * 1.1,
                    child: ItemWidget(item: item),
                  ),
                ),
                childWhenDragging: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: ItemWidget(item: item),
              ),
    );
  }
}
