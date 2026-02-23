import 'package:project_2/games/path_finder/pathfinder_level.dart';

class PathFinderLevels {
  static List<PathFinderLevel> levels = [
    PathFinderLevel(
      id: 1,
      maze: [
        "#########",
        "#S.....E#",
        "#.###.###",
        "#...#...#",
        "###.#.#.#",
        "#.......#",
        "#########",
      ],
      start: const Point(1, 1),
      end: const Point(1, 7),
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
  ];
}
