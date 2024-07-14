//
//  Data+extensions.swift
//  ImageResizer
//
//  Created by Kamaal M Farah on 14/07/2024.
//

import SwiftUI

extension Data {
    var asCFData: CFData {
        self as CFData
    }

    func toImage() -> Image? {
        #if canImport(UIKit)
        guard let uiImage = UIImage(data: self) else { return nil }

        return Image(uiImage: uiImage)
        #else
        guard let nsImage = NSImage(data: self) else { return nil }

        return Image(nsImage: nsImage)
        #endif
    }

    func getDimensions() -> CGSize? {
        guard let imageSource = CGImageSourceCreateWithData(asCFData, nil) else { return nil }
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? else {
            return nil
        }
        guard let dimensionsWidth = imageProperties[kCGImagePropertyPixelWidth] as? Int else { return nil }
        guard let dimensionsHeight = imageProperties[kCGImagePropertyPixelHeight] as? Int else { return nil }

        return CGSize(width: dimensionsWidth, height: dimensionsHeight)
    }
}
