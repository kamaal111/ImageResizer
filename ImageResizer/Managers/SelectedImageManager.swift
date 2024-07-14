//
//  SelectedImageManager.swift
//  ImageResizer
//
//  Created by Kamaal M Farah on 13/07/2024.
//

import Foundation

final class SelectedImageManager: ObservableObject {
    @Published private(set) var selectedImage: SelectedImage?

    func selectImage(url: URL) async -> Result<Void, SelectImageErrors> {
        guard url.startAccessingSecurityScopedResource() else { return .failure(.fileReadPermissionDenied) }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let image = SelectedImage.from(url: url) else { return .failure(.fileCorrupt) }

        await setSelectedImage(image)

        return .success(())
    }

    @MainActor
    private func setSelectedImage(_ image: SelectedImage) {
        selectedImage = image
    }
}

enum SelectImageErrors: Error {
    case fileReadPermissionDenied
    case fileCorrupt

    var errorMessage: (title: String, description: String?) {
        switch self {
        case .fileReadPermissionDenied, .fileCorrupt: (
            NSLocalizedString("Unable to read file", comment: ""),
            NSLocalizedString("Couldn't read the selected file\nTry again with another file", comment: "")
        )
        }
    }
}
