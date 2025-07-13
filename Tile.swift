//
//  Tile.swift
//  Y-Tiles
//
//  Copyright © 2025 Chris Yunker. All rights reserved.
//
import SwiftUI

class Tile: ObservableObject {
    let id: Int
    var homeLoc: Point
    let board: Board
    let size: CGSize
    @Published var loc: Point
    @Published var direction: Direction = .none
    @Published var position: CGPoint = .zero
    @Published var dragOffset: CGPoint = .zero
    @Published var pushTile: Tile?

    init(
        boardData: Board,
        id: Int,
        homeCoord: Point,
        size: CGSize
    ) {
        self.id = id
        self.homeLoc = homeCoord
        self.board = boardData
        self.size = size
        self.loc = homeCoord
    }

    var isInCorrectPosition: Bool {
        homeLoc == loc
    }

    func slideInDirection(direction: Direction, distance: CGFloat) {
        if let pushTile = self.pushTile {
            pushTile.slideInDirection(
                direction: direction,
                distance: distance
            )
        }
        switch direction {
        case .up:
            self.dragOffset.y = distance
        case .down:
            self.dragOffset.y = distance
        case .left:
            self.dragOffset.x = distance
        case .right:
            self.dragOffset.x = distance
        default:
            logError("[\(self.id)] Error: Trying to move a locked tile with location: \(loc)")
        }
    }

    func moveInDirection(direction: Direction) {
        logDebug("[\(self.id)] moved: \(direction)")

        if let pushTile = self.pushTile {
            pushTile.moveInDirection(
                direction: direction
            )
        }
        let origin = self.loc

        switch direction {
        case .up:
            loc.y -= 1
            board.moveTile(from: origin, to: self.loc)
        case .down:
            loc.y += 1
            board.moveTile(from: origin, to: self.loc)
        case .left:
            loc.x -= 1
            board.moveTile(from: origin, to: self.loc)
        case .right:
            loc.x += 1
            board.moveTile(from: origin, to: self.loc)
        default:
            logDebug("\(id) Cant move")
        }
        updateFrame()
    }

    func updateFrame(
        time: TimeInterval = Constants.tileMoveTime,
        updatePushTiles: Bool = false) {
        
        if updatePushTiles {
            if let pushTile = self.pushTile {
                pushTile.updateFrame(updatePushTiles: true)
            }
        }
        
        self.position.x += self.dragOffset.x
        self.position.y += self.dragOffset.y
        self.dragOffset = .zero

        let snappedPosition = self.computeLocation()

        withAnimation(.easeOut(duration: time)) {
            position = snappedPosition
        }
    }
    
    private func computeLocation() -> CGPoint {
        let x = CGFloat(loc.x) * size.width + (size.width / 2)
        let y = CGFloat(loc.y) * size.height + (size.height / 2)
        return CGPoint(x: x, y: y)
    }
}
