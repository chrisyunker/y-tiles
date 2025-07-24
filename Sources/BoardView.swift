//
//  BoardView.swift
//  Y-Tiles
//
//  Copyright 2025 Chris Yunker. All rights reserved.
//
import SwiftUI

struct BoardView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var board: Board

    @State private var tiles: [TileView] = []
    @State private var showWaitView: Bool = false
    @State private var showStartMenu: Bool = false
    @State private var showRestartMenu: Bool = false
    @State private var showCompleteMenu: Bool = false
    @State private var showBoardMenu: Bool = false
    @State private var lastProcessedStatus: GameStatus = .newGame

    init(gameState: GameState) {
        self.gameState = gameState
        self.board = Board(gameState: gameState)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    boardView
                    startMenu
                    restartMenu
                    completeMenu
                    waitView
                }
                .navigationBarHidden(true)
            }
            .navigationViewStyle(.stack)
        }
        .onReceive(gameState.$gameStatus) { newValue in
            handleGameStatusChange(newValue)
        }
    }

    private var boardView: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                if showBoardMenu {
                    let _ = logDebug("Show board view")
                    
                    // Game Tiles
                    ForEach(tiles, id: \.id) { tile in
                        tile
                    }
                }
            }
            .task {
                // Set the game board size
                gameState.updateBoardSize(
                    CGSize(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                )
            }
        }
    }

    private var waitView: some View {
        ZStack {
            if showWaitView {
                let _ = logDebug("Show wait view")
                Color.gray.opacity(0.3)
                VStack {
                    Text(NSLocalizedString("CreatingBoard", comment: "Loading message when board is being created"))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(30)
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(30)
                .frame(alignment: .center)
            }
        }
    }

    // Start Button
    private var startMenu: some View {
        ZStack {
            if showStartMenu {
                let _ = logDebug("Show start menu")
                
                Color.gray.opacity(0.3)
                VStack {
                    HStack(spacing: 20) {
                        Button(action: gameState.startGame) {
                            HStack {
                                Image(systemName: "play")
                                Text(NSLocalizedString("Start", comment: "Start game button"))
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: 80)
                            .padding(Constants.buttonPadding)
                            .background(.black)
                            .foregroundColor(.white)
                            .cornerRadius(Constants.buttonCornerRadius)
                        }
                        .padding(10)

                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }

    // Restart/Resume Buttons
    private var restartMenu: some View {
        ZStack {
            if showRestartMenu {
                let _ = logDebug("Show restart menu")
                
                Color.gray.opacity(0.3)
                VStack {
                    HStack(spacing: 20) {
                        // Start/Pause Button
                        Button(action: gameState.resumeGame) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text(NSLocalizedString("Resume", comment: "Resume game button"))
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Constants.buttonPadding)
                            .background(.black)
                            .foregroundColor(.white)
                            .cornerRadius(Constants.buttonCornerRadius)
                        }
                        .padding(10)

                        // Restart Button
                        Button(action: gameState.restartGame) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text(NSLocalizedString("Restart", comment: "Restart game button"))
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Constants.buttonPadding)
                            .background(.black)
                            .foregroundColor(.white)
                            .cornerRadius(Constants.buttonCornerRadius)
                        }
                        .padding(10)
                        .disabled(gameState.gameStatus == .newGame)
                    }
                    Spacer()
                }
            }
        }
    }

    private var completeMenu: some View {
        ZStack {
            if showCompleteMenu {
                let _ = logDebug("Show complete menu")

                Color.gray.opacity(0.3)
                VStack {
                    Text(NSLocalizedString("YTilesSolved", comment: "Game completion message"))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(30)

                    Button(action: dismissCompleteMenu) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(NSLocalizedString("OK", comment: "OK button")).fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Constants.buttonPadding)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.buttonCornerRadius)
                    }.padding(10)
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(30)
                .frame(alignment: .center)
            }
        }
    }

    func dismissCompleteMenu() {
        Task { @MainActor in
            gameState.gameStatus = .readyToPlay
        }
        showCompleteMenu = false
    }

    func displayStartMenu() {
        showStartMenu = true
        showRestartMenu = false
    }

    func displayRestartMenu() {
        showStartMenu = false
        showRestartMenu = true
    }

    func playGame() {
        showStartMenu = false
        showRestartMenu = false
    }

    func showWinAlert() {
        showStartMenu = false
        showRestartMenu = false
    }

    func displayWaitView() {
        showStartMenu = false
        showRestartMenu = false
    }

    private func createTiles() async {
        guard let boardSize = gameState.boardSize else {
            logError("Error - boardSize is nil")
            return
        }
        logDebug("createTiles for board size: \(boardSize)")
        
        self.board.tiles.removeAll()
        self.tiles.removeAll()
        self.board.initBoard()

        guard let tileSize = gameState.tileSize else {
            logError("Error - tileSize is nil")
            return
        }

        self.showWaitView = true

        Task { @MainActor in
            guard let boardPhoto = gameState.boardPhoto else {
                logError("Error - boardPhoto is nil")
                return
            }
            let tileImages = await createTileImages(
                boardPhoto: boardPhoto,
                rows: gameState.rows,
                columns: gameState.columns
            )

            self.tiles = tileImages.enumerated().map { index, tileImage in
                let coord = Point(
                    x: index % gameState.columns,
                    y: index / gameState.columns
                )
                let tileData = Tile(
                    boardData: board,
                    id: index + 1,
                    homeCoord: coord,
                    size: tileSize
                )
                tileData.updateFrame()

                board.tiles.append(tileData)
                board.grid[coord.x][coord.y] = tileData

                let tile = TileView(
                    gameState: gameState,
                    board: board,
                    tile: tileData,
                    id: tileData.id,
                    size: tileSize,
                    image: tileImage
                )
                return tile
            }

            board.resetEmptyPosition()
            showWaitView = false
            Task { @MainActor in
                gameState.gameStatus = .readyToPlay
            }
            logDebug("tiles created: \(tiles.count)")
        }
    }

    private func createTileImages(boardPhoto: UIImage, rows: Int, columns: Int)
        async -> [UIImage]
    {
        let cgImage = boardPhoto.cgImage
        // Calculate pixel ratio between UIImage and CGImage
        let ratio = CGFloat(cgImage!.height) / CGFloat(boardPhoto.size.height)

        var tileSize = gameState.tileSize ?? .zero
        // Apply ratio to tilesize
        tileSize.width = tileSize.width * ratio
        tileSize.height = tileSize.height * ratio

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var tileImages: [UIImage] = []

                for y in 0..<rows {
                    for x in 0..<columns {

                        // Skip last tile (empty space)
                        if x == columns - 1 && y == rows - 1 {
                            continue
                        }

                        let tileRect = CGRect(
                            x: CGFloat(x) * tileSize.width,
                            y: CGFloat(y) * tileSize.height,
                            width: tileSize.width,
                            height: tileSize.height
                        )

                        if let cgImage = boardPhoto.cgImage?.cropping(
                            to: tileRect
                        ) {
                            let tileImage = UIImage(
                                cgImage: cgImage,
                                scale: boardPhoto.scale,
                                orientation: boardPhoto.imageOrientation
                            )
                            tileImages.append(tileImage)
                        }
                    }
                }
                continuation.resume(returning: tileImages)
            }
        }
    }
    
    private func handleGameStatusChange(_ newValue: GameStatus) {
        // Prevent processing the same status change multiple times
        guard newValue != lastProcessedStatus else { return }
        
        let oldValue = lastProcessedStatus
        lastProcessedStatus = newValue
        
        logDebug("GameStatus change: \(oldValue) -> \(newValue)")
        
        // Use DispatchQueue to defer all status changes to prevent frame conflicts
        DispatchQueue.main.async {
            
            switch newValue {
            case .readyToPlay:
                logDebug("New game")
                displayStartMenu()
                showBoardMenu = true
                
            case .playing:
                if oldValue == .readyToPlay {
                    logDebug("Start game")
                    board.scrambleBoard()
                    playGame()
                } else if oldValue == .paused {
                    logDebug("Resume game")
                    playGame()
                }
                
            case .paused:
                logDebug("Pause game")
                displayRestartMenu()
                
            case .complete:
                logDebug("Game complete")
                displayStartMenu()
                showCompleteMenu = true
                
            case .readyToBuild:
                Task {
                    await createTiles()
                    await MainActor.run {
                        gameState.gameStatus = .buildingBoard
                    }
                }
                
            case .restart:
                logDebug("Restart game")
                board.resetBoard()
                Task { @MainActor in
                    gameState.gameStatus = .readyToPlay
                }
                
            default:
                break
            }
        }
    }
}
