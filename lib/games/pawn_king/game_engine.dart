import 'dart:math';
import 'game_state.dart';
import 'helper_functions.dart';

Move pawnKingMove(
  GameState gameState,
  List<int> kingsPawn,
  List<int> playersPawn,
) {
  Move move = Move(-1, -1);
  //int kCount = kingsPawn.where((p) => p != -1).length;
  searchPawnKingMove(gameState, kingsPawn, playersPawn, 0, move, 0, 0);
  return move;
}

int searchPawnKingMove(
  GameState gameState,
  List<int> kingsPawn,
  List<int> playersPawn,
  int depth,
  Move kingMove,
  int kCount, // no of kings pawn died
  int pCount, // no of players pawn died
) {
  if (depth == 6) {
    int ppKing = passPawnKing(gameState, kingsPawn);
    int ppPlayer = passPawnPlayer(gameState, playersPawn);
    if (ppKing != 100 || ppPlayer != 100) {
      if (ppKing <= ppPlayer)
        return 100 - depth;
      else
        return 0;
    }
    return 50 + (pCount - kCount) * 5;
  }

  if (depth % 2 == 0) {
    List<Move2> moves = validMovesKing(gameState, kingsPawn, playersPawn);
    int maxp = 0;
    for (Move2 move in moves) {
      //if (maxp == 100) return 100;
      if (winningPos(move.to)) {
        if (depth == 0) {
          kingMove.from = move.from;
          kingMove.to = move.to;
        }
        return 100 - depth;
      }
      bool capture = makeKingMove(gameState, kingsPawn, playersPawn, move);
      int point =
          100 -
          searchPawnKingMove(
            gameState,
            kingsPawn,
            playersPawn,
            depth + 1,
            kingMove,
            kCount,
            pCount + (capture ? 1 : 0),
          );
      undoKingMove(gameState, kingsPawn, playersPawn, move);
      if (depth == 0 &&
          (point > maxp || (point == maxp && Random().nextBool()))) {
        kingMove.from = move.from;
        kingMove.to = move.to;
      }
      maxp = max(maxp, point);
    }
    return maxp;
  } else {
    List<Move2> moves = validMovesPlayer(gameState, kingsPawn, playersPawn);
    int maxp = 0;
    for (Move2 move in moves) {
      //if (maxp == 100) return 100;
      if (winningPos(move.to)) return 100 - depth;
      bool capture = makePlayerMove(gameState, kingsPawn, playersPawn, move);
      int point =
          100 -
          searchPawnKingMove(
            gameState,
            kingsPawn,
            playersPawn,
            depth + 1,
            kingMove,
            kCount + (capture ? 1 : 0),
            pCount,
          );
      undoPlayersMove(gameState, kingsPawn, playersPawn, move);
      maxp = max(maxp, point);
    }
    return maxp;
  }
}
