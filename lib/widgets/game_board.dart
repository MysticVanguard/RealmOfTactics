import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm_of_tactics/models/summoned_unit.dart';
import '../models/board_manager.dart';
import '../models/game_manager.dart';
import '../models/combat_manager.dart';
import '../models/unit.dart';
import 'unit_widget.dart';
import '../models/board_position.dart';

// Widget representing the main game board where units are placed and interact
class GameBoard extends StatefulWidget {
  final BoardManager boardManager;
  final Function(Unit) onUnitSelected;
  final VoidCallback onClearSelection;
  final Unit? selectedUnit;

  const GameBoard({
    Key? key,
    required this.boardManager,
    required this.onUnitSelected,
    required this.onClearSelection,
    this.selectedUnit,
  }) : super(key: key);

  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  @override
  Widget build(BuildContext context) {
    // Watch the necessary managers
    final boardManager = context.watch<BoardManager>();
    final gameManager = context.watch<GameManager>();
    context.watch<CombatManager>(); // Ensures rebuilds on combat changes

    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey[600]!, width: 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the optimal tile size based on available space
          final availableHeight = constraints.maxHeight;
          final widthBasedSize = constraints.maxWidth / BoardManager.boardCols;
          final heightBasedSize = availableHeight / BoardManager.boardRows;
          final tileSize =
              widthBasedSize < heightBasedSize
                  ? widthBasedSize
                  : heightBasedSize;
          final finalTileSize = tileSize < 40 ? 40.0 : tileSize;

          // Notify the GameManager of the new tile size
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GameManager.instance?.setTileSize(finalTileSize);
          });

          // Determine if enemy units should be shown (in preview before combat)
          List<Unit> enemyUnitsToDisplay = [];
          if (gameManager.currentState == GameState.shopping) {
            enemyUnitsToDisplay = gameManager.nextRoundEnemies;
          }

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: _buildBoard(
                        context,
                        boardManager,
                        finalTileSize,
                        enemyUnitsToDisplay,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Constructs the board widget with rows and columns of tiles
  Widget _buildBoard(
    BuildContext context,
    BoardManager boardManager,
    double tileSize,
    List<Unit> previewEnemies,
  ) {
    final gameManager = context.read<GameManager>();
    final isInCombat = gameManager.currentState == GameState.combat;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(BoardManager.boardRows, (row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(BoardManager.boardCols, (col) {
                final position = Position(row, col);

                Unit? unit = boardManager.getUnitAt(position);
                bool isPreviewEnemy = false;

                // If not in combat and position is enemy side, show preview unit
                if (unit == null &&
                    !isInCombat &&
                    boardManager.isEnemyTerritory(position)) {
                  Unit? previewUnit;
                  for (var enemy in previewEnemies) {
                    if (enemy.boardX == col && enemy.boardY == row) {
                      previewUnit = enemy;
                      break;
                    }
                  }
                  unit = previewUnit;
                  if (unit != null) {
                    isPreviewEnemy = true;
                  }
                }

                return _buildBoardTile(
                  context,
                  boardManager,
                  row,
                  col,
                  tileSize,
                  unit,
                  isPreviewEnemy,
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  // Builds each individual board tile and handles unit placement/swapping
  Widget _buildBoardTile(
    BuildContext context,
    BoardManager boardManager,
    int row,
    int col,
    double tileSize,
    Unit? unit,
    bool isPreviewEnemy,
  ) {
    final position = Position(row, col);
    final isEnemyTerritory = boardManager.isEnemyTerritory(position);
    final gameManager = context.read<GameManager>();
    final bool isInCombat = gameManager.currentState == GameState.combat;

    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) {
        if (data == null || data['type'] != 'unit') return false;
        return !isPreviewEnemy && !isEnemyTerritory;
      },
      onAccept: (data) {
        if (isInCombat) return;

        final Unit draggedUnit = data['unit'] as Unit;
        final Position targetPosition = Position(row, col);
        final Unit? targetUnit = boardManager.getUnitAt(targetPosition);

        if (targetUnit != null) {
          final int? benchIndex = draggedUnit.benchIndex;
          if (benchIndex != null && benchIndex >= 0) {
            boardManager.remove(draggedUnit);
            boardManager.addUnitToBench(targetUnit, benchIndex);
            boardManager.placeUnit(draggedUnit, targetPosition, true);
          } else {
            final Position? sourcePosition = draggedUnit.getBoardPosition();
            if (sourcePosition != null) {
              boardManager.swapBoardUnits(sourcePosition, targetPosition);
            }
          }
        } else {
          boardManager.placeUnit(draggedUnit, targetPosition, true);
        }
      },
      builder: (context, candidateData, rejectedData) {
        bool canAcceptDrop = false;
        if (!isInCombat && candidateData.isNotEmpty) {
          var data = candidateData.first;
          if (data != null && data['type'] == 'unit') {
            final Unit? draggedUnit = data['unit'] as Unit?;
            if (draggedUnit != null) {
              canAcceptDrop =
                  !isPreviewEnemy &&
                  !isEnemyTerritory &&
                  (draggedUnit is! SummonedUnit || draggedUnit.isOnBoard);
            }
          }
        }

        return Container(
          width: tileSize,
          height: tileSize,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color:
                isInCombat
                    ? Colors.grey.withOpacity(0.3)
                    : _getTileColor(
                      isEnemyTerritory,
                      canAcceptDrop,
                      isPreviewEnemy,
                    ),
            border: Border.all(
              color:
                  isInCombat
                      ? Colors.grey
                      : _getTileBorderColor(
                        isEnemyTerritory,
                        canAcceptDrop,
                        isPreviewEnemy,
                      ),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child:
              unit != null
                  ? Opacity(
                    opacity: isPreviewEnemy && !isInCombat ? 0.5 : 1.0,
                    child: _buildDraggableUnit(
                      context,
                      unit,
                      tileSize,
                      !isPreviewEnemy && !isInCombat,
                    ),
                  )
                  : null,
        );
      },
    );
  }

  // Determines tile background color based on its state
  Color _getTileColor(
    bool isEnemyTerritory,
    bool isDropTarget,
    bool isPreviewEnemy,
  ) {
    if (isDropTarget) return Colors.green.withOpacity(0.5);
    if (isPreviewEnemy) return Colors.deepPurple.withOpacity(0.2);
    if (isEnemyTerritory) return Colors.red.withOpacity(0.15);
    return Colors.blueGrey[600]!;
  }

  // Determines tile border color based on its state
  Color _getTileBorderColor(
    bool isEnemyTerritory,
    bool isDropTarget,
    bool isPreviewEnemy,
  ) {
    if (isDropTarget) return Colors.green;
    if (isPreviewEnemy) return Colors.deepPurple.withOpacity(0.5);
    if (isEnemyTerritory) return Colors.red.withOpacity(0.5);
    return Colors.blueGrey[500]!;
  }

  // Builds a draggable unit widget to be placed on the board
  Widget _buildDraggableUnit(
    BuildContext context,
    Unit unit,
    double tileSize,
    bool draggable,
  ) {
    Widget unitWidget = UnitWidget(
      unit: unit,
      isBoardUnit: unit.isOnBoard,
      isEnemy: unit.isEnemy,
    );

    return Listener(
      onPointerDown: (_) {
        GameManager.instance?.isDragging = false;
      },
      onPointerMove: (_) {
        GameManager.instance?.isDragging = true;
      },
      onPointerUp: (_) {
        if (GameManager.instance?.isDragging == false) {
          widget.onUnitSelected(unit);
        }
        GameManager.instance?.isDragging = false;
      },
      child:
          draggable
              ? Draggable<Map<String, dynamic>>(
                data: {
                  'type': 'unit',
                  'unit': unit,
                  'sourceIndex': unit.benchIndex,
                  'sourceType': unit.isOnBoard ? 'board' : 'bench',
                },
                feedback: Opacity(
                  opacity: 0.8,
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: tileSize * 1.1,
                      height: tileSize * 1.1,
                      child: UnitWidget(
                        unit: unit,
                        isBoardUnit: unit.isOnBoard,
                        isEnemy: unit.isEnemy,
                      ),
                    ),
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
                child: Container(
                  decoration: _unitTileDecoration(unit),
                  child: unitWidget,
                ),
              )
              : Container(
                decoration: _unitTileDecoration(unit),
                child: unitWidget,
              ),
    );
  }

  // Adds a visual selection border around the selected unit
  BoxDecoration _unitTileDecoration(Unit unit) {
    return BoxDecoration(
      border: Border.all(
        color:
            widget.selectedUnit?.id == unit.id
                ? Colors.yellowAccent
                : Colors.transparent,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(4),
    );
  }
}
