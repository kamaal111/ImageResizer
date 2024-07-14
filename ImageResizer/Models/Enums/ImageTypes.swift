//
//  ImageTypes.swift
//  ImageResizer
//
//  Created by Kamaal M Farah on 14/07/2024.
//

enum ImageTypes {
    case jpg
    case png

    static func from(string: String) -> ImageTypes? {
        switch string {
        case "jpg", "jpeg": .jpg
        case "png": .png
        default: nil
        }
    }
}
