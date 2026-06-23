import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'block_breaker.dart';
import 'components/ball_component.dart';
import 'components/brick_component.dart';
import 'components/paddle_component.dart';
import 'components/star_component.dart';
import 'restart_overlay.dart';

class BlockBreakerLevels {
  final List<Level> levelList = [
    Level(
      levelId: 1,
      layout: [
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
      ],
    ),
    Level(
      levelId: 2,
      layout: [
        [0, 1, 1, 1, 0],
        [1, 0, 1, 0, 1],
        [1, 1, 0, 1, 1],
        [1, 0, 0, 0, 1],
      ],
    ),
  ];
}

class Level {
  final int levelId;
  final List<List<int>> layout;

  Level({required this.levelId, required this.layout});
}
