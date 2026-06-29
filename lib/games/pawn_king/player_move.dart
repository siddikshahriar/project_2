import 'game_state.dart';
import 'game_engine.dart';
import 'helper_functions.dart';
import 'package:project_2/services/local_progress_store.dart';
import 'package:project_2/services/progress_sync_service.dart';

/// Rindex : index counted from bottom-left to top right
/// Rrow : row from right to left
/// Rcol : column from bottom to top
/// Rindex = 63-index
/// index-7 : up-right cell
/// index-8 : up cell
/// index-9 : up-left cell

void selectPawn(int index, GameState gameState) {
  if (gameState.gameOver == true) return;
  int Rindex = (63 - index);
  int Rrow = Rindex ~/ 8;
  int Rcol = Rindex % 8;

  if (gameState.board[index] == 1) {
    gameState.selectedIndex = index;

    if (index - 8 >= 0 && gameState.board[index - 8] == 0) {
      gameState.validMove[index - 8] = 1;
    }
    if (Rcol > 0 && index - 7 >= 0 && gameState.board[index - 7] == 2) {
      gameState.validMove[index - 7] = 1;
    }
    if (Rcol < 7 && index - 9 >= 0 && gameState.board[index - 9] == 2) {
      gameState.validMove[index - 9] = 1;
    }
  }
}

Move playerMove(int index, GameState gameState) {
  if (gameState.validMove[index] == 0) {
    /// selected another pawn
    if (gameState.board[index] == 1) {
      gameState.validMove.fillRange(0, 64, 0);
      selectPawn(index, gameState);
      return Move(-1, -1);
    }
    gameState.validMove.fillRange(0, 64, 0);
    gameState.selectedIndex = -1;
    return Move(-1, -1);
  } else {
    gameState.validMove.fillRange(0, 64, 0);
    return Move(gameState.selectedIndex, index);
  }
}

void executeMove(GameState gameState, Move move) {
  if (gameState.playerTurn) {
    gameState.board[move.from] = 0;
    gameState.board[move.to] = 1;
    gameState.playerTurn = false;
    gameState.selectedIndex = -1;
    if (move.to <= 7) {
      gameState.gameOver = true;
      gameState.winner = 1;
      _saveProgress();
    }
  } else {
    gameState.board[move.from] = 0;
    gameState.board[move.to] = 2;
    gameState.playerTurn = true;
    gameState.selectedIndex = -1;
    if (move.to >= 56) {
      gameState.gameOver = true;
      gameState.winner = 2;
    }
  }
}

Future<void> _saveProgress() async {
  final existing = LocalProgressStore.loadProgress('pawn_king');
  final gameXP = existing?['gameXP'] as int? ?? 0;

  await LocalProgressStore.saveProgress('pawn_king', {'gameXP': gameXP + 100});
  ProgressSyncService.syncNow(); // pushes now if online; quietly skipped if not
}
