import 'package:flutter/material.dart';
import '../models/map_manager.dart';

class MapWidget extends StatelessWidget {
  final MapManager mapManager;
  final void Function(MapNode) onNodeSelected;
  final VoidCallback onConfirmSelection;

  const MapWidget({
    super.key,
    required this.mapManager,
    required this.onNodeSelected,
    required this.onConfirmSelection,
  });

  // Looks for a node in a certain row at a certain index and
  // returns it
  MapNode? _getNodeByIndex(List<MapNode> row, int index) {
    try {
      return row.firstWhere((n) => n.index == index);
    } catch (_) {
      return null;
    }
  }

  // Builds the main map widget
  @override
  Widget build(BuildContext context) {
    final map = mapManager.map;

    return Container(
      color: Colors.black87,
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double nodeSize = 52.0;
                  final double mapWidth = MapManager.nodesPerFloor * nodeSize;
                  final double mapHeight = map.length * nodeSize;

                  return SizedBox(
                    width: constraints.maxWidth,
                    child: FittedBox(
                      // ✨ KEY: auto-shrink horizontally
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: mapWidth,
                        height: mapHeight,
                        child: Stack(
                          children: [
                            CustomPaint(
                              painter: _ConnectionPainter(
                                _generateConnectionLines(map),
                              ),
                              size: Size(mapWidth, mapHeight),
                            ),
                            Column(
                              children: List.generate(map.length, (floor) {
                                final row = map[floor];
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    MapManager.nodesPerFloor,
                                    (i) {
                                      final MapNode? node = _getNodeByIndex(
                                        row,
                                        i,
                                      );
                                      if (node == null)
                                        return SizedBox(width: 52, height: 52);

                                      final isCurrent =
                                          node == mapManager.currentNode;
                                      final isSelectable =
                                          mapManager.currentNode?.connections
                                              .contains(node) ??
                                          false;
                                      final isSelected =
                                          node == mapManager.selectedNode;

                                      return GestureDetector(
                                        onTap: () {
                                          mapManager.selectAnyNode(node);
                                          onNodeSelected(node);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(6),
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _getNodeColor(node.type),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? (isSelectable
                                                          ? Colors.green
                                                          : Colors.red)
                                                      : (isCurrent
                                                          ? Colors.cyan
                                                          : Colors.transparent),
                                              width:
                                                  (isSelected || isCurrent)
                                                      ? 3
                                                      : 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getNodeSymbol(node.type),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          if (mapManager.selectedNode != null &&
              mapManager.currentNode?.connections.contains(
                    mapManager.selectedNode,
                  ) ==
                  true)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                onPressed: onConfirmSelection,
                child: Text("Enter"),
              ),
            ),
        ],
      ),
    );
  }

  List<Offset> _generateConnectionLines(List<List<MapNode>> map) {
    const double columnWidth = 52.0;
    const double rowHeight = 52.0;
    const double margin = 6.0;
    const double radius = 20.0;

    final List<Offset> lines = [];

    for (final floor in map) {
      for (final node in floor) {
        final double x1 = node.index * columnWidth + margin + radius;
        final double y1 = node.floor * rowHeight + margin + radius;

        for (final target in node.connections) {
          final double x2 = target.index * columnWidth + margin + radius;
          final double y2 = target.floor * rowHeight + margin + radius;

          lines.add(Offset(x1, y1));
          lines.add(Offset(x2, y2));
        }
      }
    }

    return lines;
  }

  // Returns the node color based off it's type
  Color _getNodeColor(MapNodeType type) {
    switch (type) {
      case MapNodeType.start:
        return Colors.blue;
      case MapNodeType.combat:
        return Colors.red[800]!;
      case MapNodeType.elite:
        return Colors.purple[800]!;
      case MapNodeType.rest:
        return Colors.green[700]!;
      case MapNodeType.blessing:
        return Colors.teal[700]!;
      case MapNodeType.boss:
        return Colors.black;
    }
  }

  // Returns the node symbol based off of it's type
  String _getNodeSymbol(MapNodeType type) {
    switch (type) {
      case MapNodeType.start:
        return "S";
      case MapNodeType.combat:
        return "C";
      case MapNodeType.elite:
        return "E";
      case MapNodeType.rest:
        return "R";
      case MapNodeType.blessing:
        return "?";
      case MapNodeType.boss:
        return "B";
    }
  }
}

// The painter for all of the lines connecting the nodes
class _ConnectionPainter extends CustomPainter {
  final List<Offset> lines;
  _ConnectionPainter(this.lines);

  // Draw's all the lines already found
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey[300]!
          ..strokeWidth = 2;

    for (int i = 0; i < lines.length; i += 2) {
      canvas.drawLine(lines[i], lines[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) => true;
}
