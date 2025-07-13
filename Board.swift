//
//  Board.swift
//  Y-Tiles
//
//  Copyright © 2025 Chris Yunker. All rights reserved.
//
import AVFoundation
import SwiftUI

class Board: ObservableObject {
    @ObservedObject var gameState: GameState
    
    var lock: NSLock = NSLock()
    var tiles: [Tile] = []
    var grid: [[Tile?]] = []
    var debug: Bool = false
    private var emptyLoc: Point = Point(x: 0, y: 0)
    
    var totalPositions: Int {
        gameState.columns * gameState.rows
    }

    init(gameState: GameState) {
        self.gameState = gameState
        initBoard()
        resetEmptyPosition()
    }
    
    func initBoard() {
        grid = Array(
            repeating: Array(repeating: nil, count: gameState.rows),
            count: gameState.columns
        )
    }

    func resetEmptyPosition() {
        emptyLoc = Point(x: gameState.columns - 1, y: gameState.rows - 1)
    }

    func resetBoard() {
        for index in tiles.indices {
            tiles[index].loc = tiles[index].homeLoc
            tiles[index].updateFrame()
        }
        resetEmptyPosition()
    }

    func updateGrid() {

        // Reset the move state in all tiles
        for tile in tiles {
            tile.direction = .none
            tile.pushTile = nil
        }

        // Go left from empty location
        for i in stride(from: emptyLoc.x - 1, to: -1, by: -1) {
            guard i >= 0 && i < gameState.columns && emptyLoc.y >= 0 && emptyLoc.y < gameState.rows,
                  let tile = grid[i][emptyLoc.y] else { continue }
            tile.direction = Direction.right
            if i > 0,
               let pushTile = grid[i][emptyLoc.y],
               i - 1 >= 0 && i - 1 < gameState.columns {
                grid[i - 1][emptyLoc.y]?.pushTile = pushTile
            }
        }
        // Go right from empty location
        for i in stride(from: emptyLoc.x + 1, to: gameState.columns, by: 1) {
            guard i >= 0 && i < gameState.columns && emptyLoc.y >= 0 && emptyLoc.y < gameState.rows,
                  let tile = grid[i][emptyLoc.y] else { continue }
            tile.direction = Direction.left
            if i < gameState.columns - 1,
               let pushTile = grid[i][emptyLoc.y],
               i + 1 >= 0 && i + 1 < gameState.columns {
                grid[i + 1][emptyLoc.y]?.pushTile = pushTile
            }
        }
        // Go up from empty location
        for i in stride(from: emptyLoc.y - 1, to: -1, by: -1) {
            guard emptyLoc.x >= 0 && emptyLoc.x < gameState.columns && i >= 0 && i < gameState.rows,
                  let tile = grid[emptyLoc.x][i] else { continue }
            tile.direction = Direction.down
            if i > 0,
               let pushTile = grid[emptyLoc.x][i],
               i - 1 >= 0 && i - 1 < gameState.rows {
                grid[emptyLoc.x][i - 1]?.pushTile = pushTile
            }
        }
        // Go down from empty location
        for i in stride(from: emptyLoc.y + 1, to: gameState.rows, by: 1) {
            guard emptyLoc.x >= 0 && emptyLoc.x < gameState.columns && i >= 0 && i < gameState.rows,
                  let tile = grid[emptyLoc.x][i] else { continue }
            tile.direction = Direction.up
            if i < gameState.rows - 1,
               let pushTile = grid[emptyLoc.x][i],
               i + 1 >= 0 && i + 1 < gameState.rows {
                grid[emptyLoc.x][i + 1]?.pushTile = pushTile
            }
        }
    }

    func moveTile(from: Point, to: Point) {
        logDebug("Move tile from: \(from) to: \(to)")

        grid[to.x][to.y] = grid[from.x][from.y]
        grid[from.x][from.y] = nil
        emptyLoc = from
        playSound()
        checkIsComplete()
    }

    func checkIsComplete() {
        let isComplete = tiles.allSatisfy { $0.isInCorrectPosition }
        if isComplete {
            Task { @MainActor in
                gameState.gameStatus = .complete
            }
        }
    }

    func scrambleBoard() {
        if debug {
            
            logDebug("MOVE from \(gameState.columns - 2), \(gameState.rows - 1) to \(gameState.columns - 1), \(gameState.rows - 1)")
            
            grid[gameState.columns - 1][gameState.rows - 1] = grid[gameState.columns - 2][gameState.rows - 1]
                //tiles[gameState.columns * gameState.rows - 2]
            
            grid[gameState.columns - 1][gameState.rows - 1]!.loc =
                Point(x: gameState.columns - 1, y: gameState.rows - 1)
            grid[gameState.columns - 2][gameState.rows - 1] = nil
            
            emptyLoc = Point(x: gameState.columns - 2, y:  gameState.rows - 1)
            
            logDebug("EMPTY: \(emptyLoc)")
        } else {

            // Clear board
            for x in 0..<gameState.columns {
                for y in 0..<gameState.rows {
                    grid[x][y] = nil
                }
            }

            var positions = Array(0..<(totalPositions - 1))
            // Add '-1' to represent empty spot
            positions.append(-1)
            positions.shuffle()

            var i = 0
            for x in 0..<gameState.columns {
                for y in 0..<gameState.rows {
                    if positions[i] >= 0 {
                        grid[x][y] = tiles[positions[i]]
                        grid[x][y]!.loc = Point(x: x, y: y)
                    } else {
                        emptyLoc = Point(x: x, y: y)
                    }
                    i += 1
                }
            }
        }

        // Update tiles
        for (index, _) in tiles.enumerated() {
            tiles[index].updateFrame(time: Constants.tileScrambleTime)
        }
        updateGrid()
        playSound()
    }
    
    func playSound() {
        if gameState.soundEnabled {
            AudioServicesPlayAlertSound(SystemSoundID(1105))
        }
    }
}
