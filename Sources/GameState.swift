//
//  GameState.swift
//  Y-Tiles
//
//  Observable game state management for SwiftUI
//  Copyright 2025 Chris Yunker. All rights reserved.
//
import SwiftUI
import UIKit

enum GameStatus: Int, CaseIterable {
    case newGame = 0
    case readyToBuild = 1
    case buildingBoard = 2
    case readyToPlay = 3
    case playing = 4
    case paused = 5
    case restart = 6
    case complete = 7
}

@MainActor
class GameState: ObservableObject {
    @Published var gameStatus: GameStatus = .newGame {
        didSet {
            logDebug("GameState: GameStatus changed to: \(gameStatus)")
        }
    }
    @Published var numbersEnabled = Constants.numbersEnabledDefault
    @Published var photoEnabled = Constants.photoEnabledDefault
    @Published var soundEnabled = Constants.soundEnabledDefault
    @Published var boardPhoto: UIImage?

    // User Settings
    var photoType: PhotoType = Constants.lastPhotoTypeDefault
    var originalBoardPhoto: UIImage?
    var tileSize: CGSize?

    init() {
        loadSettings()
    }

    // Updates which require recalculations
    var rows = Constants.rowsDefault {
        didSet {
            updateConfiguration()
        }
    }

    var columns = Constants.columnsDefault {
        didSet {
            updateConfiguration()
        }
    }

    var boardSize: CGSize? {
        didSet {
            updateConfiguration()
        }
    }

    func updateColumns(_ newColumns: Int) {
        if columns != newColumns {
            logDebug("update columns: \(newColumns)")
            columns = newColumns
            saveSettings()
        }
    }

    func updateRows(_ newRows: Int) {
        if rows != newRows {
            logDebug("update rows: \(newRows)")
            rows = newRows
            saveSettings()
        }
    }

    func updateBoardSize(_ newSize: CGSize) {
        if boardSize != newSize {
            logDebug("update boardSize from: \(boardSize ?? .zero) to: \(newSize)")
            boardSize = newSize
        }
    }

    func setStockPhoto(_ newPhotoType: PhotoType) {
        if photoType != newPhotoType {
            logDebug("newPhotoType: \(newPhotoType)")
            photoType = newPhotoType
            loadStockPhoto()
            updateConfiguration(newPhoto: true)
            saveSettings()
            deleteCustomPhoto()
        }
    }

    func setCustomPhoto(_ newPhoto: UIImage) {
        photoType = PhotoType.customPhoto
        self.originalBoardPhoto = newPhoto
        updateConfiguration(newPhoto: true)
        saveSettings()
    }

    private func updateConfiguration(
        newPhoto: Bool = false
    ) {
        logDebug("updateConfiguration")

        guard let boardSize = boardSize else { return }

        let tileWidth = boardSize.width / CGFloat(columns)
        let tileHeight = boardSize.height / CGFloat(rows)
        self.tileSize = CGSize(width: tileWidth, height: tileHeight)
        guard let tileSize = self.tileSize else { return }
        logDebug("tileSize updated to \(tileSize))")
        
        if newPhoto {
            setBoardPhoto()
            if photoType == .customPhoto {
                saveCustomPhoto()
            }
        } else if self.boardPhoto == nil {
            setBoardPhoto()
        }

        guard boardPhoto != nil else { return }

        Task { @MainActor in
            self.gameStatus = .readyToBuild
        }
    }

    private func loadSettings() {
        logDebug("Load settings")

        let defaults = UserDefaults.standard
        let savedDefaults = defaults.bool(forKey: Constants.keySavedDefaults)

        if savedDefaults {
            logDebug("Load saved defaults")

            columns = defaults.integer(forKey: Constants.keyColumns)
            rows = defaults.integer(forKey: Constants.keyRows)
            numbersEnabled = defaults.bool(forKey: Constants.keyNumbersEnabled)
            photoEnabled = defaults.bool(forKey: Constants.keyPhotoEnabled)
            soundEnabled = defaults.bool(forKey: Constants.keySoundEnabled)

            let photoTypeInt = defaults.integer(
                forKey: Constants.keyLastPhotoType
            )
            photoType =
                if let validPhototype = PhotoType(rawValue: photoTypeInt) {
                    validPhototype
                } else {
                    Constants.lastPhotoTypeDefault
                }
        }

        if photoType == .customPhoto {

            if let customPhoto = loadCustomPhoto() {
                logInfo("Loaded custom photo")
                boardPhoto = customPhoto
            } else {
                logWarning("Failed to load custom photo, defaulting to stock photo")
                photoType = Constants.lastPhotoTypeDefault
                loadStockPhoto()
                deleteCustomPhoto()
            }

        } else {
            loadStockPhoto()
        }
    }

    private func loadStockPhoto() {
        var photoName: String?
        switch self.photoType {
        case .stockPhoto1:
            photoName = "stockPhoto1"
        case .stockPhoto2:
            photoName = "stockPhoto2"
        case .stockPhoto3:
            photoName = "stockPhoto3"
        case .stockPhoto4:
            photoName = "stockPhoto4"
        default:
            logError("Unsupported photoType: \(self.photoType), defaulting to stockPhoto1")
            photoName = "stockPhoto1"
        }
        guard let photoName = photoName else {
            logError("Error - photoName is nil")
            return
        }
        if let photo = UIImage(named: photoName) {
            logInfo("Loaded stock photo: \(photoName)")
            originalBoardPhoto = photo
        }
    }

    private func saveSettings() {
        logDebug("Save settings")

        let defaults = UserDefaults.standard
        defaults.set(true, forKey: Constants.keySavedDefaults)
        defaults.set(columns, forKey: Constants.keyColumns)
        defaults.set(rows, forKey: Constants.keyRows)
        defaults.set(photoType.rawValue, forKey: Constants.keyLastPhotoType)
        defaults.set(numbersEnabled, forKey: Constants.keyNumbersEnabled)
        defaults.set(photoEnabled, forKey: Constants.keyPhotoEnabled)
        defaults.set(soundEnabled, forKey: Constants.keySoundEnabled)
    }

    // MARK: - Photo Management
    private func setBoardPhoto() {
        guard let originalPhoto = originalBoardPhoto else {
            logError("Error setting boardPhoto: originalBoardPhoto not set")
            return
        }
        guard let boardSize = boardSize else {
            logError("Error setting boardPhoto: boardsize not set")
            return
        }
        guard let cgImage = originalPhoto.cgImage else {
            logError("Error setting boardPhoto: cgImage is nil")
            return
        }

        // Calculate pixel ratio between UIImage and CGImage
        let ratio = CGFloat(cgImage.height) / CGFloat(originalPhoto.size.height)

        let cropWidth = boardSize.width * ratio
        let cropHeight = boardSize.height * ratio
        
        logDebug("Original CGImage size: \(cgImage.width), \(cgImage.height)")
        logDebug("Crop CGImage to: \(cropWidth), \(cropHeight)")

        // Apply ratio to boardPhoto
        let cropRect = CGRect(
            x: (CGFloat(cgImage.width) - cropWidth) / 2,
            y: (CGFloat(cgImage.height) - cropHeight) / 2,
            width: cropWidth,
            height: cropHeight
        )
        
        if let croppedImage = cgImage.cropping(to: cropRect) {
            logDebug("Set board photo")
            self.boardPhoto = UIImage(
                cgImage: croppedImage,
                scale: originalPhoto.scale,
                orientation: originalPhoto.imageOrientation
            )
        }
    }

    func getCustomPhotoUrl() -> URL {
        let baseUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0
        ]
        
        return baseUrl.appendingPathComponent("\(Constants.customPhoto).jpg")
    }

    private func saveCustomPhoto() {
        guard let boardPhoto = boardPhoto else { return }
        
        guard let data = boardPhoto.jpegData(compressionQuality: 0.8) else {
            return
        }

        do {
            try data.write(to: getCustomPhotoUrl())
        } catch {
            logError("Error saving custom photo: \(error)")
        }
    }

    private func loadCustomPhoto() -> UIImage? {
        return UIImage(contentsOfFile: getCustomPhotoUrl().path)
    }
    
    private func deleteCustomPhoto() {
        if FileManager.default.fileExists(atPath: getCustomPhotoUrl().path) {
            do {
                try FileManager.default.removeItem(at: getCustomPhotoUrl())
                logInfo("Deleted custom photo")
            } catch {
                logError("Error deleting custom photo: \(error)")
            }
        }
    }

    // MARK: - Game Logic
    func startGame() {
        logDebug("Start Game")

        guard gameStatus == .readyToPlay else { return }
        gameStatus = .playing
    }

    func pauseGame() {
        logDebug("Pause Game")

        guard gameStatus == .playing else { return }
        gameStatus = .paused
    }

    func resumeGame() {
        logDebug("Resume Game")
        guard gameStatus == .paused else { return }
        gameStatus = .playing
    }

    func restartGame() {
        logDebug("Restart Game")
        gameStatus = .restart
    }

    // MARK: - Settings
    func togglePhotoVisibility() {
        photoEnabled.toggle()
        saveSettings()
    }

    func toggleNumbersVisibility() {
        numbersEnabled.toggle()
        saveSettings()
    }

    func toggleSound() {
        soundEnabled.toggle()
        saveSettings()
    }
}
