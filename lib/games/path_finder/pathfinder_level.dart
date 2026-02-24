/// Represents a single level configuration for the Pathfinder game.
class PathFinderLevel {
  final int id;
  final List<String> maze; // The visual grid representation
  final Point start; // Starting coordinates (row, col)
  final Point end; // Goal coordinates (row, col)

  PathFinderLevel({
    required this.id,
    required this.maze,
    required this.start,
    required this.end,
  });
}

/// A simple coordinate pair for grid-based positioning.
/// [r] represents the row (Vertical/Y-axis)
/// [c] represents the column (Horizontal/X-axis)
class Point {
  final int r;
  final int c;

  const Point(this.r, this.c);

  // Optional: Adding an equality operator makes it easier to compare points
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          r == other.r &&
          c == other.c;

  @override
  int get hashCode => r.hashCode ^ c.hashCode;
}
