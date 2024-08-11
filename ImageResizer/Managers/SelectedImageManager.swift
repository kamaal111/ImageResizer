//
//  SelectedImageManager.swift
//  ImageResizer
//
//  Created by Kamaal M Farah on 13/07/2024.
//

import Foundation
import KamaalLogger

private let logger = KamaalLogger(from: SelectedImageManager.self, failOnError: true)

final class SelectedImageManager: ObservableObject {
    @Published private(set) var selectedImage: SelectedImage?
    @Published private(set) var loadingInitialData = true

    let fileManager: FileManager

    convenience init() {
        self.init(fileManager: .default)
    }

    init(fileManager: FileManager) {
        self.fileManager = fileManager

        Task { await getStoredImage() }
    }

    func selectImage(url: URL) async -> Result<Void, SelectImageErrors> {
        guard url.startAccessingSecurityScopedResource() else { return .failure(.fileReadPermissionDenied) }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let image = SelectedImage.from(url: url) else { return .failure(.fileCorrupt) }

        try? storeImage(image)
        await setSelectedImage(image)

        return .success(())
    }

    private func getStoredImage() async {
        defer { Task { await setLoadingInitialData(false) } }

        let content: [String]
        do {
            content = try fileManager.contentsOfDirectory(atPath: Self.directoryToStoreImage.path())
        } catch {
            logger.error(label: "Failed to load initial selected image", error: error)
            return
        }

        guard let selectedImageName = content.first(where: { $0.starts(with: Self.storedImageFilename) }) else { return }

        let selectedImageURL = Self.directoryToStoreImage.appending(path: selectedImageName)
        guard let selectedImage = SelectedImage.from(url: selectedImageURL) else { return }

        logger.info("Loaded store selected image")
        await setSelectedImage(selectedImage)
    }

    private func storeImage(_ image: SelectedImage) throws {
        try createDirectoryIfItDoesntExist(Self.directoryToStoreImage)
        let imageURL = Self.directoryToStoreImage
            .appending(path: Self.storedImageFilename)
            .appendingPathExtension(image.metadata.type.rawValue)
        try image.data.write(to: imageURL)
    }

    private func createDirectoryIfItDoesntExist(_ url: URL) throws {
        var isDirectory: ObjCBool = false
        let directoryExists = fileManager.fileExists(atPath: url.path(), isDirectory: &isDirectory)
        if !directoryExists {
            logger.info("Creating \(url.lastPathComponent) directory")
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            return
        }

        if !isDirectory.boolValue {
            logger.info("Removing file with the same name as file that will get created")
            try fileManager.removeItem(at: url)
            logger.info("Creating \(url.lastPathComponent) directory")
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    @MainActor
    private func setSelectedImage(_ image: SelectedImage) {
        selectedImage = image
    }

    @MainActor
    private func setLoadingInitialData(_ state: Bool) {
        loadingInitialData = state
    }

    private static let directoryToStoreImage = URL.homeDirectory.appending(path: "Images")
    private static let storedImageFilename = "selected_image"
}

enum SelectImageErrors: Error {
    case fileReadPermissionDenied
    case fileCorrupt

    var errorMessage: (title: String, description: String?) {
        switch self {
        case .fileReadPermissionDenied, .fileCorrupt:
            return (
                NSLocalizedString("Unable to read file", comment: ""),
                NSLocalizedString("Couldn't read the selected file\nTry again with another file", comment: "")
            )
        }
    }
}
