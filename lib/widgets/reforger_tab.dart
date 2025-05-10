import 'package:flutter/material.dart';
import 'package:realm_of_tactics/models/game_manager.dart';
import 'package:realm_of_tactics/models/item.dart';
import 'package:realm_of_tactics/models/unit.dart';
import 'package:realm_of_tactics/widgets/unit_widget.dart';
import 'package:realm_of_tactics/widgets/item_widget.dart';

class ReforgerTab extends StatelessWidget {
  final dynamic slotContent;
  final void Function(dynamic) onSlotUpdate;
  final VoidCallback onReforgePressed;
  final int playerGold;

  final void Function(Unit)? onUnitTapped;
  final void Function(Item)? onItemTapped;

  const ReforgerTab({
    Key? key,
    required this.slotContent,
    required this.onSlotUpdate,
    required this.onReforgePressed,
    required this.playerGold,
    this.onUnitTapped,
    this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasUnit = slotContent is Unit;
    final int tokens =
        hasUnit
            ? (slotContent as Unit).cost <= 3
                ? GameManager.instance!.playerSmallUnitDuplicator
                : GameManager.instance!.playerLargeUnitDuplicator
            : GameManager.instance!.playerItemReforgeTokens;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            "The Reforger",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Place a unit here and duplicate it by using a Unit Duplicator (Small for 1-3 costs, Large for 4-5 costs).\n"
            "Place an item here and reforge it into another item of the same tier by using an Item Reforge Token.\n"
            "Units cost 1 Unit Reforge Token, items cost 1 Item Reforge Token.\n"
            "Leaving a unit or item here when closing the tab or starting combat moves them to your bench.\n"
            "If your unit bench is full, the unit will be sold instead. You cannot duplicate a unit if you have no bench space.",
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),

          // Reforge slot
          DragTarget<Map<String, dynamic>>(
            onWillAccept: (data) {
              if (data == null) return false;
              return data['type'] == 'unit' || data['type'] == 'item';
            },
            onAccept: (data) {
              final boardManager = GameManager.instance!.boardManager!;
              final dynamic dropped = data['unit'] ?? data['item'];

              if (dropped == slotContent) return;

              if (data['type'] == 'unit') {
                boardManager.remove(dropped as Unit);
              } else if (data['type'] == 'item') {
                boardManager.remove(dropped as Item);
              }

              onSlotUpdate(dropped);
            },
            builder: (context, candidateData, rejectedData) {
              final bool isDropping = candidateData.isNotEmpty;

              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      isDropping
                          ? Colors.green.withOpacity(0.3)
                          : Colors.grey[800],
                  border: Border.all(
                    color: isDropping ? Colors.green : Colors.white24,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child:
                    slotContent != null
                        ? Draggable<Map<String, dynamic>>(
                          data: {
                            'type': slotContent is Unit ? 'unit' : 'item',
                            'unit': slotContent is Unit ? slotContent : null,
                            'item': slotContent is Item ? slotContent : null,
                            'sourceType': 'reforger',
                          },
                          feedback: Material(
                            color: Colors.transparent,
                            elevation: 6,
                            child: Container(
                              width: 60,
                              height: 60,
                              child:
                                  slotContent is Unit
                                      ? UnitWidget(unit: slotContent)
                                      : ItemWidget(item: slotContent),
                            ),
                          ),
                          childWhenDragging: Container(),
                          onDraggableCanceled: (_, __) {},
                          child: GestureDetector(
                            onTap: () {
                              if (slotContent is Unit && onUnitTapped != null) {
                                onUnitTapped!(slotContent);
                              } else if (slotContent is Item &&
                                  onItemTapped != null) {
                                onItemTapped!(slotContent);
                              }
                            },
                            child:
                                slotContent is Unit
                                    ? UnitWidget(unit: slotContent)
                                    : ItemWidget(item: slotContent),
                          ),
                        )
                        : Center(
                          child: Icon(
                            Icons.add_circle_outline,
                            color: Colors.white24,
                          ),
                        ),
              );
            },
          ),

          // Reforge button
          if (tokens >= 1 &&
              (slotContent is Item ||
                  (slotContent is Unit &&
                      !GameManager.instance!.boardManager!.isBenchFull())))
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ElevatedButton.icon(
                onPressed: (tokens >= 1) ? onReforgePressed : null,
                icon: Icon(Icons.autorenew),
                label: Text(
                  hasUnit
                      ? (slotContent as Unit).cost <= 3
                          ? "Duplicate Unit: 1 Small Unit Duplicator ($tokens Total)"
                          : "Duplicate Unit: 1 Large Unit Duplicator ($tokens Total)"
                      : "Reforge Item: 1 Item Reforge Token ($tokens Total)",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasUnit ? Colors.orange : Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),

          if (slotContent is Unit &&
              GameManager.instance!.boardManager!.isBenchFull())
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.redAccent, size: 16),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Bench full — unit will be SOLD at combat start!",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
