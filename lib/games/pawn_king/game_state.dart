import 'dart:math';

/// board: state of the board. 0 means empty, 1 means players pawn, 2 means pawnKings pawn
/// playerTurn : determines if the current turn is of player or pawnKing
/// gameOver : marks the end of the game
/// selectedIndex : currently selected pawn index of the player
/// board is indexed from top left to bottom right
/// Rindex = 63 - index (bottom right to top left)
/// winner : winer of the game, 0 for draw, 1 for player, 2 for bot
/// playerWhite : pawn color of player (selected randomly)
class GameState {
  List<int> board = List.filled(64, 0);
  List<int> validMove = List.filled(64, 0);

  Random rng = Random();
  bool playerTurn = false;
  bool playerWhite = true;
  bool gameOver = false;
  int selectedIndex = -1;
  void setBoard() {
    for (int i = 0; i < 8; i++) board[i] = 2;
    for (int i = 56; i < 64; i++) board[i] = 1;
  }

  int winner = -1;
  GameState() {
    playerWhite = rng.nextBool();
    playerTurn = playerWhite ? true : false;
    setBoard();
  }
}
