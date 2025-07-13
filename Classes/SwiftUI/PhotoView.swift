//
//  PhotoView.swift
//  Y-Tiles
//
//  Copyright 2025 Chris Yunker. All rights reserved.
//
import PhotosUI
import SwiftUI

struct PhotoView: View {
    var gameState: GameState
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingStockPhotoMenu = false
    @State private var selectedBoardPhoto: UIImage?

    var body: some View {
        ZStack {
            // Photo Display Area
            if let boardPhoto = selectedBoardPhoto {
                let _ = logDebug("Displaying board photo size: \(boardPhoto.size)")
                Image(uiImage: boardPhoto)
            } else {
                VStack {
                    Text(NSLocalizedString("NoPhotoSelected", comment: "Message when no photo is selected"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(
                        NSLocalizedString("ChoosePhotoMessage", comment: "Instructions for photo selection")
                    )
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                }
            }

            // Button Menu
            VStack {
                HStack(spacing: 20) {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        HStack {
                            Text(NSLocalizedString("PhotoLibrary", comment: "Photo library button"))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Constants.buttonPadding)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.buttonCornerRadius)
                    }

                    Spacer()

                    Button(action: {
                        showingStockPhotoMenu = true
                    }) {
                        HStack {
                            Text(NSLocalizedString("StockPhotos", comment: "Stock photos button"))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Constants.buttonPadding)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.buttonCornerRadius)
                    }
                }
                .padding(10)

                Spacer()
            }
        }
        .onReceive(gameState.$boardPhoto) { newValue in
            selectedBoardPhoto = newValue
        }
        .onAppear {
            selectedBoardPhoto = gameState.boardPhoto
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            loadSelectedPhoto(newPhoto)
        }
        .sheet(isPresented: $showingStockPhotoMenu) {
            StockPhotosView(gameState: gameState)
        }
        .navigationViewStyle(.stack)
    }

    private func loadSelectedPhoto(_ photo: PhotosPickerItem?) {
        guard let photo = photo else { return }

        Task {
            if let imageData = try? await photo.loadTransferable(
                type: Data.self
            ),
                let image = UIImage(data: imageData)
            {
                await MainActor.run {
                    gameState.setCustomPhoto(image)
                }
            }
        }
    }
}

struct StockPhotosView: View {
    var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    private let stockPhotos = [
        ("stockPhoto1", 0),
        ("stockPhoto2", 1),
        ("stockPhoto3", 2),
        ("stockPhoto4", 3),
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ],
                    spacing: 5
                ) {
                    let height =
                        ((gameState.boardSize?.height ?? 400) / 2.0) - 10.0
                    let width =
                        ((gameState.boardSize?.width ?? 400) / 2.0) - 5.0
                    ForEach(stockPhotos, id: \.1) { item in
                        Button(action: {
                            selectStockPhoto(item.1)
                        }) {
                            VStack {

                                if let image = UIImage(named: item.0) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: width, height: height)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("StockPhotos", comment: "Stock photos navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("Cancel", comment: "Cancel button")) {
                        dismiss()
                    }
                    .frame(alignment: .center)
                    .padding(Constants.buttonPadding)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.buttonCornerRadius)
                }
            }
            .padding(5)
        }
    }

    private func selectStockPhoto(_ index: Int) {
        logDebug("Load stock photo: \(index)")

        // Map index to PhotoType (0->stockPhoto1, 1->stockPhoto2, etc.)
        if let photoType = PhotoType.init(id: index) {
            gameState.setStockPhoto(photoType)
        } else {
            logError("Error selecting stock photo: \(index)")
        }
        dismiss()
    }
}

/*
#Preview {
    PhotoView(gameState: GameState())
        .preferredColorScheme(.dark)
}
*/
