//
//  ContentView.swift
//  Y-Tiles
//
//  Copyright 2025 Chris Yunker. All rights reserved.
//
import SwiftUI

struct ContentView: View {
    @State private var gameState = GameState()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            BoardView(gameState: gameState)
                .tabItem {
                    Image(systemName: "square.grid.3x3")
                    Text(NSLocalizedString("Board", comment: "Board tab"))
                }
                .tag(Constants.tabBarBoardTag)
            PhotoView(gameState: gameState)
                .tabItem {
                    Image(systemName: "photo")
                    Text(NSLocalizedString("Photo", comment: "Photo tab"))
                }
                .tag(Constants.tabBarPhotoTag)
            SettingsView(
                gameState: gameState,
                selectedTab: $selectedTab
            )
            .tabItem {
                Image(systemName: "gear")
                Text(NSLocalizedString("Settings", comment: "Settings tab"))
            }
            .tag(Constants.tabBarSettingsTag)
        }
        .tint(.blue)
    }
}
