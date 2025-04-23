class Position {
  // Row and Column indexes for the position on the board
  final int row;
  final int col;

  const Position(this.row, this.col);

  // Overrid for equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  // Override for the hashcode
  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  // Overide for the toString
  @override
  String toString() => 'Position(row: $row, col: $col)';
}
