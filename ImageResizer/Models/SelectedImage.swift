//
//  SelectedImage.swift
//  ImageResizer
//
//  Created by Kamaal M Farah on 14/07/2024.
//

import SwiftUI

struct SelectedImage {
    let image: Image
    let data: Data
    let metadata: Metadata

    init(image: Image, data: Data, metadata: Metadata) {
        self.image = image
        self.data = data
        self.metadata = metadata
    }

    static func from(url: URL) -> SelectedImage? {
        guard let fileExtension = url.absoluteString.split(separator: ".").last else { return nil }
        guard let imageType = ImageTypes.from(string: String(fileExtension)) else { return nil }

        let imageData: Data
        do {
            imageData = try Data(contentsOf: url)
        } catch {
            return nil
        }

        guard let image = imageData.toImage() else { return nil }
        guard let metadata = Metadata.from(type: imageType, data: imageData) else { return nil }

        return SelectedImage(image: image, data: imageData, metadata: metadata)
    }
}

extension SelectedImage {
    struct Metadata {
        let type: ImageTypes
        let dimensions: CGSize

        init(type: ImageTypes, dimensions: CGSize) {
            self.type = type
            self.dimensions = dimensions
        }

        static func from(type: ImageTypes, data: Data) -> Metadata? {
            guard let dimensions = data.getDimensions() else { return nil }

            return Metadata(type: type, dimensions: dimensions)
        }
    }
}
