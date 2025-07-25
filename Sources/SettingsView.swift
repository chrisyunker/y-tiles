//
//  SettingsView.swift
//  Y-Tiles
//
//  Copyright 2025 Chris Yunker. All rights reserved.
//
import SwiftUI

struct SettingsView: View {
    @ObservedObject var gameState: GameState
    @Binding var selectedTab: Int
    @State private var showAboutMenu = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Picker(
                            NSLocalizedString(
                                "Columns",
                                comment: "Grid columns setting"
                            ),
                            selection: Binding(
                                get: { gameState.columns },
                                set: { gameState.updateColumns($0) }
                            )
                        ) {
                            ForEach(
                                Constants.columnsMin...Constants.columnsMax,
                                id: \.self
                            ) { number in
                                Text("\(number)").tag(number)
                            }
                        }
                        .pickerStyle(.menu)

                        Spacer()

                        Picker(
                            NSLocalizedString(
                                "Rows",
                                comment: "Grid rows setting"
                            ),
                            selection: Binding(
                                get: { gameState.rows },
                                set: { gameState.updateRows($0) }
                            )
                        ) {
                            ForEach(
                                Constants.rowsMin...Constants.rowsMax,
                                id: \.self
                            ) { number in
                                Text("\(number)").tag(number)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    HStack {
                        Image(systemName: "photo")
                            .foregroundColor(.red)
                            .frame(width: 30)
                        Text(
                            NSLocalizedString(
                                "UsePhoto",
                                comment: "Photo mode toggle"
                            )
                        )

                        Spacer()

                        Toggle(
                            "",
                            isOn: Binding(
                                get: { gameState.photoEnabled },
                                set: { _ in gameState.togglePhotoVisibility()
                                }
                            )
                        )
                    }

                    // Show Numbers Toggle
                    HStack {
                        Image(systemName: "textformat.123")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        Text(
                            NSLocalizedString(
                                "ShowNumbers",
                                comment: "Numbers mode toggle"
                            )
                        )

                        Spacer()

                        Toggle(
                            "",
                            isOn: Binding(
                                get: { gameState.numbersEnabled },
                                set: { _ in gameState.toggleNumbersVisibility()
                                }
                            )
                        )
                    }

                    // Sound Effects Toggle
                    HStack {
                        Image(
                            systemName: gameState.soundEnabled
                                ? "speaker.wave.2" : "speaker.slash"
                        )
                        .foregroundColor(.orange)
                        .frame(width: 30)
                        Text(
                            NSLocalizedString(
                                "SoundEffects",
                                comment: "Sound effects toggle"
                            )
                        )

                        Spacer()

                        Toggle(
                            "",
                            isOn: Binding(
                                get: { gameState.soundEnabled },
                                set: { _ in gameState.toggleSound() }
                            )
                        )
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Button(action: {
                            showAboutMenu = true
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.white)
                                    .frame(width: 30)
                                
                                Text(
                                    NSLocalizedString(
                                        "About",
                                        comment: "About button"
                                    )
                                )
                                .fontWeight(.semibold)
                            }
                            .frame(maxWidth: 250)
                            .padding(Constants.buttonPadding)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(Constants.buttonCornerRadius)
                        }
                        Spacer()
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Button(action: {
                            gameState.pauseGame()
                            selectedTab = 0
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text(
                                    NSLocalizedString(
                                        "RestartGame",
                                        comment: "Restart game button"
                                    )
                                )
                                .fontWeight(.semibold)
                            }
                            .frame(maxWidth: 250)
                            .padding(Constants.buttonPadding)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(Constants.buttonCornerRadius)
                        }
                        Spacer()
                    }
                }
            }
            .sheet(isPresented: $showAboutMenu) {
                AboutView()
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Text(
                                NSLocalizedString(
                                    "Done",
                                    comment: "Done button"
                                )
                            )
                            .fontWeight(.semibold)
                        }
                        .frame(maxWidth: 80)
                        .padding(Constants.buttonPadding)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.buttonCornerRadius)
                    }
                }

                // App Icon
                Image("About")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                    .shadow(radius: 5)

                // App Info
                VStack(spacing: 8) {
                    Text(
                        NSLocalizedString(
                            "AppName",
                            comment: "Application name"
                        )
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)

                    Text(
                        String(
                            format: NSLocalizedString(
                                "Version",
                                comment: "Version string format"
                            ),
                            Constants.versionMajor,
                            Constants.versionMinor
                        )
                    )
                    .font(.title2)
                    .foregroundColor(.secondary)

                    Text(
                        NSLocalizedString(
                            "AppDescription",
                            comment: "App description"
                        )
                    )
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }

                Divider()

                // Description
                VStack(spacing: 8) {
                    Text(
                        NSLocalizedString(
                            "Developer",
                            comment: "Developer name"
                        )
                    )
                    .font(.title2)
                    .foregroundColor(.secondary)
                    Text(
                        String(
                            format: NSLocalizedString(
                                "Copyright",
                                comment: "Copyright year"
                            ),
                            Constants.copyrightYear
                        )
                    )
                    .font(.body)
                    .foregroundColor(.secondary)
                    Text("[yunker.dev](https://yunker.dev)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
    }
}
