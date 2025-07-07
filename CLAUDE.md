# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Y-Tiles is an iOS sliding puzzle game written in Objective-C. The app allows users to solve puzzles using either custom photos or pre-included images, with configurable grid sizes and display modes.

## Architecture

### Core Components

- **Board** (`Board.h/m`): Central game logic managing the puzzle grid, tile movement, game state, and photo handling
- **Tile** (`Tile.h/m`): Individual puzzle pieces with photo/number display, movement animations, and position tracking
- **BoardController** (`BoardController.h/m`): UIViewController managing game UI, menu displays, and user interactions
- **Configuration** (`Configuration.h/m`): Game settings persistence (grid size, photo/number modes, sound)

### Supporting Classes

- **AppDelegate**: Application lifecycle with main window and controller management
- **PhotoController**: Photo selection and management interface
- **SettingsController**: Game configuration UI
- **PhotoDefaultController**: Default photo selection interface
- **WaitImageView**: Loading indicator during board generation
- **Util**: Shared utility functions

### Data Types

- **Coord**: 2D coordinate structure (x, y)
- **Direction**: Movement directions (Up, Down, Left, Right)
- **GameState**: Game status (NotStarted, Paused, InProgress)

## Build Commands

This is an Xcode project that should be built using:

```bash
# Build for simulator (iOS 18)
xcodebuild -project Y-Tiles.xcodeproj -scheme Y-Tiles -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build for device (iOS 18)
xcodebuild -project Y-Tiles.xcodeproj -scheme Y-Tiles -destination 'generic/platform=iOS' build
```

## Key Constants

All game constants are defined in `Constants.h`:
- Grid size limits: 3x3 to 6x6
- Photo types: 4 default photos plus custom board photo
- UI dimensions and colors
- Game settings keys for UserDefaults

## Game Flow

1. **Initialization**: AppDelegate creates Board and controllers
2. **Board Setup**: Board creates tile grid based on Configuration
3. **Photo Processing**: Images are cropped and divided into tiles
4. **Game Loop**: BoardController handles user input and tile movement
5. **Persistence**: Configuration saves/loads game state via UserDefaults

## Development Notes

- **iOS 18 Compatible**: Updated deployment target to iOS 18.0
- **ARC Enabled**: Converted from manual memory management to Automatic Reference Counting
- **Modern APIs**: Updated deprecated UIAlertView to UIAlertController
- XIB files for Settings and About views
- Localization support via `Localizable.strings`
- Asset catalog for app icons and launch images
- Sound effects using AudioToolbox framework

## iOS 18 Upgrade Notes

The project has been fully upgraded for iOS 18 compatibility:
- Deployment target updated from iOS 9.2 to iOS 18.0
- Enabled ARC (Automatic Reference Counting)
- Removed all manual retain/release calls
- Updated property declarations from `retain` to `strong`
- Fixed ARC ownership issues with triple pointers (`Tile * __strong **grid`)
- Removed deprecated UIAccelerometerDelegate references
- Fixed window management in AppDelegate for proper iOS 18 compatibility
- Added scene delegate configuration to prevent snapshot errors
- Fixed all compilation warnings:
  - Updated deprecated UIActivityIndicatorViewStyleWhiteLarge to UIActivityIndicatorViewStyleLarge
  - Updated deprecated UIBarStyleBlackOpaque/UIBarStyleBlackTranslucent to UIBarStyleBlack
  - Replaced deprecated animation APIs with modern block-based UIView animations
  - Replaced deprecated interaction event APIs with userInteractionEnabled property
  - Added proper 1024x1024 App Store icon
  - Replaced deprecated Launch Images with Launch Storyboard