//
//  TileView.swift
//  Y-Tiles
//
//  Copyright © 2025 Chris Yunker. All rights reserved.
//
import SwiftUI

struct TileView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var board: Board
    @ObservedObject var tile: Tile
    @State var haveLock: Bool = false

    let id: Int
    let size: CGSize
    let image: UIImage

    var body: some View {
        tileView
            .position(
                x: tile.position.x + tile.dragOffset.x,
                y: tile.position.y + tile.dragOffset.y
            )
            .gesture(drag)
    }

    private var tileView: some View {
        ZStack {
            // Tile Image
            Color.white
                .frame(
                    width: size.width - Constants.tileSpacingWidth,
                    height: size.height - Constants.tileSpacingWidth
                )
                .cornerRadius(Constants.tileCornerRadius)
            if gameState.photoEnabled {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: size.width - Constants.tileSpacingWidth,
                        height: size.height - Constants.tileSpacingWidth
                    )
                    .clipped()
                    .cornerRadius(Constants.tileCornerRadius)
            }
            // Number Overlay
            if gameState.numbersEnabled {
                VStack {
                    HStack {
                        Spacer()
                        numberOverlay
                    }
                    Spacer()
                }
                .padding(6)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private var numberOverlay: some View {
        Text("\(self.id)")
            .font(
                .system(
                    size: min(size.width * 0.15, 20),
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: Constants.tileNumberRadios)
                    .fill(Color.black.opacity(0.7))
            )
    }

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in

                // Try to acquire a lock
                if !haveLock {
                    if board.lock.try() {
                        logDebug("[\(id)] Locked")
                        haveLock = true
                    } else {
                        // NOP if we don't get lock
                        return
                    }
                }

                switch tile.direction {
                case .up:
                    if value.translation.height < -size.height {
                        tile.dragOffset.y = -size.height
                    } else if value.translation.height > 0 {
                        tile.dragOffset.y = 0
                    } else {
                        tile.dragOffset.y = value.translation.height
                    }

                    if let pushTile = tile.pushTile {
                        pushTile.slideInDirection(
                            direction: .up,
                            distance: tile.dragOffset.y
                        )
                    }
                case .down:
                    if value.translation.height > size.height {
                        tile.dragOffset.y = size.height
                    } else if value.translation.height < 0 {
                        tile.dragOffset.y = 0
                    } else {
                        tile.dragOffset.y = value.translation.height
                    }

                    if let pushTile = tile.pushTile {
                        pushTile.slideInDirection(
                            direction: .down,
                            distance: tile.dragOffset.y
                        )
                    }
                case .left:
                    if value.translation.width < -size.width {
                        tile.dragOffset.x = -size.width
                    } else if value.translation.width > 0 {
                        tile.dragOffset.x = 0
                    } else {
                        tile.dragOffset.x = value.translation.width
                    }

                    if let pushTile = tile.pushTile {
                        pushTile.slideInDirection(
                            direction: .left,
                            distance: tile.dragOffset.x
                        )
                    }
                case .right:
                    if value.translation.width > size.width {
                        tile.dragOffset.x = size.width
                    } else if value.translation.width < 0 {
                        tile.dragOffset.x = 0
                    } else {
                        tile.dragOffset.x = value.translation.width
                    }

                    if let pushTile = tile.pushTile {
                        pushTile.slideInDirection(
                            direction: .right,
                            distance: tile.dragOffset.x
                        )
                    }
                default:
                    logError("[\(self.id)] Error: Trying to move a locked tile in direction: \(tile.direction)")
                }

            }
            .onEnded { value in
                if tile.direction == .right
                    && value.translation.width > (size.width / 2)
                {
                    // Move right
                    tile.moveInDirection(direction: .right)
                    board.updateGrid()
                } else if tile.direction == .left
                    && value.translation.width < -(size.width / 2)
                {
                    // Move left
                    tile.moveInDirection(direction: .left)
                    board.updateGrid()
                } else if tile.direction == .down
                    && value.translation.height > (size.height / 2)
                {
                    // Move down
                    tile.moveInDirection(direction: .down)
                    board.updateGrid()
                } else if tile.direction == .up
                    && value.translation.height < -(size.height / 2)
                {
                    // Move up
                    tile.moveInDirection(direction: .up)
                    board.updateGrid()
                } else {
                    tile.updateFrame(updatePushTiles: true)
                }

                // Release lock
                if haveLock {
                    board.lock.unlock()
                    haveLock = false
                    logDebug("[\(id)] Unlocked")
                }
            }
    }

    private func snapToGrid(_ point: CGPoint) -> CGPoint {
        let snappedX = round(point.x / size.width) * size.width
        let snappedY = round(point.y / size.height) * size.height
        logDebug("snap: x: \(snappedX), y: \(snappedY)")
        return CGPoint(x: snappedX, y: snappedY)
    }
}
