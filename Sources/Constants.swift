//
//  Constants.swift
//  Y-Tiles
//
//  Copyright Chris Yunker 2025. All rights reserved.
//
import Foundation
import UIKit

struct Constants {

    // MARK: - Version Info
    static let versionMajor = 3
    static let versionMinor = 1
    static let copyrightYear = "2025"

    // MARK: - User Default Keys
    static let keySavedDefaults = "savedDefaults"
    static let keyColumns = "columns"
    static let keyRows = "rows"
    static let keyLastPhotoType = "lastPhotoType"
    static let keyPhotoEnabled = "photoEnabled"
    static let keyNumbersEnabled = "numbersEnabled"
    static let keySoundEnabled = "soundEnabled"

    // MARK: - Default Values
    static let columnsDefault = 4
    static let rowsDefault = 4
    static let emptyPositionDefault = 15
    static let lastPhotoTypeDefault = PhotoType.stockPhoto1
    static let photoEnabledDefault = true
    static let numbersEnabledDefault = true
    static let soundEnabledDefault = true

    // MARK: - Controller Indices
    static let tabBarBoardTag = 0
    static let tabBarPhotoTag = 1
    static let tabBarSettingsTag = 2

    // MARK: - Grid Limits
    static let rowsMin = 3
    static let rowsMax = 6
    static let columnsMin = 3
    static let columnsMax = 6

    // MARK: - File Paths and Photo Types
    static let customPhoto = "YTilesCustomPhoto"

    // MARK: - Tile Appearance
    static let tileSpacingWidth: CGFloat = 1.0
    static let tileCornerRadius: CGFloat = 10.0
    static let tileNumberRadios: CGFloat = 8.0
    
    static let buttonCornerRadius: CGFloat = 12.0
    static let buttonPadding: CGFloat = 10.0

    // MARK: - Animation Timing
    static let tileScrambleTime: TimeInterval = 1.0
    static let tileMoveTime: TimeInterval = 0.1
    
    // MARK: - Debug Settings
    static let debugTestCompleteGame: Bool = false

}
