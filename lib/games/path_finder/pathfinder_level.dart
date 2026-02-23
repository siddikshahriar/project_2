class PathFinderLevel {
  final int id;
  final List<String> maze;
  final Point start;
  final Point end;

  PathFinderLevel({
    required this.id,
    required this.maze,
    required this.start,
    required this.end,
  });
}

class Point {
  final int r;
  final int c;
  const Point(this.r, this.c);
}
