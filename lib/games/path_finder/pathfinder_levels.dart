import 'package:project_2/games/path_finder/pathfinder_level.dart';

class PathFinderLevels {
  static List<PathFinderLevel> levels = [
    // Level 1: Horizontal Introduction
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
        "###.#.#.#.......#.",
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

    // Level 2: Small Square
    PathFinderLevel(
      id: 2,
      maze: ["#####", "#S..#", "#.#.#", "#..E#", "#####"],
      start: const Point(1, 1),
      end: const Point(3, 3),
    ),

    // Level 3: The Hook
    PathFinderLevel(
      id: 3,
      maze: ["#######", "#S....#", "#.###.#", "#...#E#", "#######"],
      start: const Point(1, 1),
      end: const Point(3, 5),
    ),

    // Level 4: The Snake (Added for Dashboard variety)
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

    // Level 5: The Spiral (Added for Dashboard variety)
    PathFinderLevel(
      id: 5,
      maze: [
        "###########",
        "#S........#",
        "#.#######.#",
        "#.#.....#.#",
        "#.#.###.#.#",
        "#.#.#E#.#.#",
        "#.#.###.#.#",
        "#.#.....#.#",
        "#.#######.#",
        "#.........#",
        "###########",
      ],
      start: const Point(1, 1),
      end: const Point(5, 5),
    ),
  ];
}
