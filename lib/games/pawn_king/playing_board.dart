import 'package:flutter/material.dart';
import 'game_state.dart';
import 'game_engine.dart';
import 'player_move.dart';
import 'helper_functions.dart';

class PawnKingPlayingBoard extends StatefulWidget {
  @override
  State<PawnKingPlayingBoard> createState() => _PawnKingPlayingBoard();
}

class _PawnKingPlayingBoard extends State<PawnKingPlayingBoard> {
  GameState gameState = GameState();

  @override
  void initState() {
    super.initState();

    /// if pawnKing plays the first turn
    if (!gameState.playerTurn) {
      setState(() {
        Move move = Move(-1, -1);
        move = pawnKingMove(
          gameState,
          pawnIndexes(gameState, 2),
          pawnIndexes(gameState, 1),
        );
        executeMove(gameState, move);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const int rows = 8;
    const int cols = 8;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Title(color: Colors.black, child: Text('Board')),
      ),

      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: rows * cols,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),

                itemBuilder: (context, index) {
                  int row = index ~/ cols;
                  int col = index % cols;

                  return GestureDetector(
                    onTap: () async {
                      /// players turn
                      Move move = Move(-1, -1);
                      if (gameState.gameOver) return;
                      if (gameState.playerTurn) {
                        /// checking if the player has no valid move
                        List<Move2> Moves = validMovesPlayer(
                          gameState,
                          pawnIndexes(gameState, 2),
                          pawnIndexes(gameState, 1),
                        );
                        if (Moves.isEmpty) {
                          setState(() {
                            gameState.gameOver = true;
                            gameState.winner = 0;
                          });
                          return;
                        }

                        /// checking if some valid cell is already selected or not
                        if (gameState.selectedIndex == -1) {
                          setState(() {
                            selectPawn(index, gameState);
                          });
                        } else {
                          setState(() {
                            move = playerMove(index, gameState);
                          });
                        }
                      }

                      if (move != Move(-1, -1)) {
                        setState(() {
                          executeMove(gameState, move);
                        });
                      } else {
                        return;
                      }

                      await Future.delayed(const Duration(milliseconds: 20));
                      if (gameState.gameOver) return;

                      /// pawnKings turn
                      if (!gameState.playerTurn) {
                        move = pawnKingMove(
                          gameState,
                          pawnIndexes(gameState, 2),
                          pawnIndexes(gameState, 1),
                        );
                      }

                      if (move != Move(-1, -1)) {
                        setState(() {
                          executeMove(gameState, move);
                        });
                      } else {
                        setState(() {
                          gameState.gameOver = true;
                          gameState.winner = 0;
                        });
                        return;
                      }
                    },

                    // const Color.fromARGB(255, 224, 224, 67)
                    child: Container(
                      decoration: BoxDecoration(
                        color: gameState.validMove[index] == 1
                            ? Colors.amberAccent
                            : (row + col) % 2 == 0
                            ? Colors.white
                            : Colors.grey,
                        border: Border.all(color: Colors.black),
                      ),

                      /// pawn placing
                      child: Center(
                        child: () {
                          if (gameState.board[index] == 1) {
                            return gameState.playerWhite
                                ? Image.asset('assets/icons/whitepawn.png')
                                : Image.asset('assets/icons/blackpawn.png');
                          } else if (gameState.board[index] == 2) {
                            return (gameState.playerWhite)
                                ? Image.asset('assets/icons/blackpawn.png')
                                : Image.asset('assets/icons/whitepawn.png');
                          }
                        }(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Container(
            color: Colors.teal.shade100,
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  (gameState.gameOver == true)
                      ? (gameState.winner == 0)
                            ? 'DRAW'
                            : 'GAMEOVER!! you ${gameState.winner == 1 ? 'won' : 'lose'} the game'
                      : '${gameState.playerTurn ? 'Your turn' /*{pkmoves(gameState, pawnIndexes(gameState, 2), pawnIndexes(gameState, 1))}*/ : 'thinking....'}',
                  style: TextStyle(
                    fontSize: 20,
                    color: gameState.gameOver
                        ? gameState.winner == 1
                              ? Colors.green
                              : Colors.red
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
