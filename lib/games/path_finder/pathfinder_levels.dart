class PathFinderLevels {
  static List<PathFinderLevel> levels = [
    PathFinderLevel(
      id: 1,
      maze: [
        "###################",
        "#.#######.....#...#",
        "#.......#######.#.#",
        "######.#.......##.#",
        "###....#.#####.##.#",
        "###.###..#.....#..#",
        "#S..#..E###.####.##",
        "#.#######...#.....#",
        "#...#...#.#######.#",
        "###.#.#.#.......#.#",
        "#...#...#######.#.#",
        "#.####.#..#####.#.#",
        "#.####.#.#....#.#.#",
        "#........#.####.#.#",
        "#.###.####.#....#.#",
        "#....###...#.####.#",
        "####.....###.##...#",
        "####.#######.###.##",
        "#....#.....#.###.##",
        "#.####.###.#......#",
        "#.#...####.######.#",
        "#...#.............#",
        "###################",
      ],
      start: const Point(6, 1),
      end: const Point(6, 7),
    ),

    PathFinderLevel(
      id: 2,
      maze: ["#####", "#S..#", "#.#.#", "#..E#", "#####"],
      start: const Point(1, 1),
      end: const Point(3, 3),
    ),

    PathFinderLevel(
      id: 3,
      maze: ["#######", "#S....#", "#.###.#", "#...#E#", "#######"],
      start: const Point(1, 1),
      end: const Point(3, 5),
    ),

    PathFinderLevel(
      id: 4,
      maze: [
        "#########",
        "#S..#...#",
        "###.#.#.#",
        "#...#.#.#",
        "#.###.#.#",
        "#.....#E#",
        "#########",
      ],
      start: const Point(1, 1),
      end: const Point(5, 7),
    ),

    // PathFinderLevel(
    //   id: 5,
    //   maze: [
    //     "###########",
    //     "#S........#",
    //     "#.#######.#",
    //     "#.#.....#.#",
    //     "#.#.###.#.#",
    //     "#.#.#E#.#.#",
    //     "#.#.###.#.#",
    //     "#.#.....#.#",
    //     "#.#######.#",
    //     "#.........#",
    //     "###########",
    //   ],
    //   start: const Point(1, 1),
    //   end: const Point(5, 5),
    // ),
  ];
}

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
