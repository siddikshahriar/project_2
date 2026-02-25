/*
 *   Copyright (c) 2026 Emon Thakur
 *   All rights reserved.
 */
#include<bits/stdc++.h>
using namespace std;
mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());

class StringMazeGenerator {
    int rows, cols;
    vector<string> grid;

public:
    StringMazeGenerator(int n, int m) : rows(n), cols(m) {
        grid.assign(rows, string(cols, '#'));
    }

    void generate(int r, int c) {
        grid[r][c] = '.';
        int dr[] = {-2, 2, 0, 0};
        int dc[] = {0, 0, -2, 2};
        vector<int> dirs = {0, 1, 2, 3};
        random_shuffle(dirs.begin(), dirs.end());

        for (int i : dirs) {
            int nr = r + dr[i];
            int nc = c + dc[i];
            if (nr > 0 && nr < rows - 1 && nc > 0 && nc < cols - 1 && grid[nr][nc] == '#') {
                grid[r + dr[i] / 2][c + dc[i] / 2] = '.';
                generate(nr, nc);
            }
        }
    }

    void print() {
        cout << "maze: [" << endl;
        for (int i = 0; i < rows; i++) {
            cout << "  \"" << grid[i] << "\"," << endl;
        }
        cout << "]," << endl;
    }
};

int main() {
    int n = 20;
    int m = 20;
    StringMazeGenerator maze(n,m); 
    maze.generate(rng()%n, rng()%m);
    maze.print();
    return 0;
}
