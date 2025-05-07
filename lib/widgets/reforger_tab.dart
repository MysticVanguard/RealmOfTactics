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
    final int cost =
        hasUnit ? ((slotContent as Unit).cost * (slotContent as Unit).tier) : 5;

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
            "Place a unit or item here to reforge it into another of the same cost and tier.\n"
            "Units cost their gold value * their tier, items cost 5 gold.\n"
            "Leaving a unit or item here when closing the tab or starting combat moves them to your bench.\n"
            "If your unit bench is full, the unit will be sold instead.",
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
                          onDragCompleted: () => onSlotUpdate(null),
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
          if (slotContent != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ElevatedButton.icon(
                onPressed: (playerGold >= cost) ? onReforgePressed : null,
                icon: Icon(Icons.autorenew),
                label: Text(
                  hasUnit ? "Reforge Unit: $cost Gold" : "Reforge Item: 5 Gold",
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
