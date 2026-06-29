import 'dart:math';
import 'game_state.dart';
import 'game_engine.dart';

/// actual move
class Move {
  int from;
  int to;
  Move(this.from, this.to);
}

/// moves for function run
class Move2 {
  int pawnIndx; // index in pawn list, -1 if captured
  int from; // board index
  int to; // board index
  int capturedPawnIndx; //captured pawn index in its pawn list, -1 if no capture
  Move2(this.pawnIndx, this.from, this.to, this.capturedPawnIndx);
}

/// if the current position is a winning position for any player
bool winningPos(int pos) {
  return (pos < 8 || pos > 55);
}

/// minimum number of moves required for any of the players free pass pawn to reach to the end
///
int passPawnPlayer(GameState gameState, List<int> playersPawn) {
  int minMove = 100;
  for (int index in playersPawn) {
    if (index == -1) continue;
    int Rindex = (63 - index);
    int cnt = index ~/ 8;
    int Rcol = Rindex % 8;
    bool ok = true;
    index -= 8;
    while (index >= 0) {
      if (Rcol > 0 && gameState.board[index + 1] == 2) {
        ok = false;
        break;
      } else if (gameState.board[index] != 0) {
        ok = false;
        break;
      } else if (Rcol < 7 && gameState.board[index - 1] == 2) {
        ok = false;
        break;
      }
      index -= 8;
    }
    if (ok) minMove = min(minMove, cnt);
  }
  return minMove;
}

/// minimum number of moves required for any of the kings free pass pawn to reach to the end
int passPawnKing(GameState gameState, List<int> kingsPawn) {
  int minMove = 100;
  for (int index in kingsPawn) {
    if (index == -1) continue;
    bool ok = true;
    int Rindex = (63 - index);
    int col = index % 8;
    int cnt = Rindex ~/ 8;
    index += 8;
    while (index <= 63) {
      if (col > 0 && gameState.board[index - 1] == 1) {
        ok = false;
        break;
      } else if (gameState.board[index] != 0) {
        ok = false;
        break;
      } else if (col < 7 && gameState.board[index + 1] == 1) {
        ok = false;
        break;
      }
      index += 8;
    }
    if (ok) minMove = min(minMove, cnt);
  }
  return minMove;
}

/// point is calculated with respect to kings current turn
int pointOfState(
  GameState gameState,
  List<int> playersPawn,
  List<int> kingsPawn,
  int stateOwner,
) {
  int ppKing = passPawnKing(gameState, kingsPawn);
  int ppPlayer = passPawnPlayer(gameState, playersPawn);
  if (stateOwner == 1 && ppPlayer != 100) {
    return ppPlayer;
  }
  if (stateOwner == 2 && ppKing != 100) {
    return 100 - ppKing;
  }

  Random rng = Random();
  return rng.nextInt(100);
}

int findPawnIndex(List<int> pawns, int square) {
  for (int i = 0; i < pawns.length; i++) {
    if (pawns[i] == square) return i;
  }
  return -1;
}

/// returns current moves of king as a string ,,
/// testing purpose
String pkmoves(
  GameState gameState,
  List<int> kingsPawn,
  List<int> playersPawn,
) {
  List<Move2> moves = validMovesKing(gameState, kingsPawn, playersPawn);
  return moves
      .map((m) {
        String captureText = m.capturedPawnIndx != -1
            ? " (CAPS Player Pawn ${m.capturedPawnIndx})"
            : "";
        return "From ${m.from} to ${m.to}$captureText";
      })
      .join("\n");
}

List<Move2> validMovesKing(
  GameState gameState,
  List<int> kingsPawn,
  List<int> playersPawn,
) {
  List<Move2> moves = [];
  for (int i = 0; i < kingsPawn.length; i++) {
    int from = kingsPawn[i];
    if (from == -1) continue; // captured pawn
    int col = from % 8;
    if (from + 8 < 64 && gameState.board[from + 8] == 0) {
      moves.add(Move2(i, from, from + 8, -1));
    }
    if (col < 7 && from + 9 < 64 && gameState.board[from + 9] == 1) {
      int capIndx = findPawnIndex(playersPawn, from + 9);
      if (capIndx != -1) moves.add(Move2(i, from, from + 9, capIndx));
    }
    if (col > 0 && from + 7 < 64 && gameState.board[from + 7] == 1) {
      int capIndx = findPawnIndex(playersPawn, from + 7);
      if (capIndx != -1) moves.add(Move2(i, from, from + 7, capIndx));
    }
  }
  return moves;
}

List<Move2> validMovesPlayer(
  GameState gameState,
  List<int> kingsPawn,
  List<int> playersPawn,
) {
  List<Move2> moves = [];
  for (int i = 0; i < playersPawn.length; i++) {
    int from = playersPawn[i];
    if (from == -1) continue;
    int Rcol = (63 - from) % 8;
    if (from - 8 >= 0 && gameState.board[from - 8] == 0) {
      moves.add(Move2(i, from, from - 8, -1));
    }
    if (Rcol > 0 && from - 7 >= 0 && gameState.board[from - 7] == 2) {
      int capIndx = findPawnIndex(kingsPawn, from - 7);
      if (capIndx != -1) moves.add(Move2(i, from, from - 7, capIndx));
    }
    if (Rcol < 7 && from - 9 >= 0 && gameState.board[from - 9] == 2) {
      int capIndx = findPawnIndex(kingsPawn, from - 9);
      if (capIndx != -1) moves.add(Move2(i, from, from - 9, capIndx));
    }
  }
  return moves;
}

/// checks if the pawn in this index is already a pass pawn for the king
/// if so, then pushing this pawn may work fine but its not the best choice for sure
/// because the opponent may have other plan for a faster pass pawn
bool isAPassPawn(GameState gameState, int index) {
  int Rindex = (63 - index);
  int col = index % 8;
  int cnt = Rindex ~/ 8;
  index += 8;
  while (index <= 63) {
    if (col > 0 && gameState.board[index - 1] != 0) {
      return false;
    } else if (gameState.board[index] != 0) {
      return false;
    } else if (col < 7 && gameState.board[index + 1] != 0) {
      return false;
    }
    index += 8;
  }
  return true;
}

bool makeKingMove(
  GameState gameState,
  List<int> kingsPawn,
  List<int> playersPawn,
  Move2 m,
) {
  gameState.board[m.from] = 0;
  gameState.board[m.to] = 2;
  kingsPawn[m.pawnIndx] = m.to;
  if (m.capturedPawnIndx != -1) {
    playersPawn[m.capturedPawnIndx] = -1;
    return true;
  }
  return false;
}

bool makePlayerMove(
  GameState gameState,
  List<int> kingsPawn,
  List<int> playersPawn,
  Move2 m,
) {
  gameState.board[m.from] = 0;
  gameState.board[m.to] = 1;
  playersPawn[m.pawnIndx] = m.to;
  if (m.capturedPawnIndx != -1) {
    kingsPawn[m.capturedPawnIndx] = -1;
    return true;
  }
  return false;
}

void undoKingMove(
  GameState gameState,
  List<int> kingsPawn,
  List<int> playersPawn,
  Move2 m,
) {
  gameState.board[m.to] = 0;
  gameState.board[m.from] = 2;
  kingsPawn[m.pawnIndx] = m.from;
  if (m.capturedPawnIndx != -1) {
    playersPawn[m.capturedPawnIndx] = m.to;
    gameState.board[m.to] = 1;
  }
}

void undoPlayersMove(
  GameState gameState,
  List<int> kingsPawn,
  List<int> playersPawn,
  Move2 m,
) {
  gameState.board[m.to] = 0;
  gameState.board[m.from] = 1;
  playersPawn[m.pawnIndx] = m.from;
  if (m.capturedPawnIndx != -1) {
    kingsPawn[m.capturedPawnIndx] = m.to;
    gameState.board[m.to] = 2;
  }
}

/// returns all pawn indexes of each player
/// p==1? players pawn : kings pawn;
List<int> pawnIndexes(GameState gameState, int p) {
  List<int> list = [];
  for (int i = 0; i < 64; i++) {
    if (gameState.board[i] == p) list.add(i);
  }
  return list;
}
