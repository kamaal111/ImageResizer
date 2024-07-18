//
//  ImageResizerScreen.swift
//  ImageResizer
//
//  Created by Kamaal M Farah on 13/07/2024.
//

import SwiftUI
import KamaalUI

struct ImageResizerScreen: View {
    @StateObject private var selectedImageManager = SelectedImageManager()

    @State private var isSelectingImage = false
    @State private var alertMessage: (title: String, description: String?)?
    @State private var viewSize: CGSize = .zero

    var body: some View {
        VStack {
            if let selectedImage = selectedImageManager.selectedImage {
                selectedImage
                    .image
                    .resizable()
                    .frame(
                        width: resizeSelectedImageSize(image: selectedImage).width,
                        height: resizeSelectedImageSize(image: selectedImage).height
                    )
            }
            Button(action: handleSelectFile) {
                Text("Select file")
            }
        }
        .fileImporter(
            isPresented: $isSelectingImage,
            allowedContentTypes: ImageTypes.supportedUTTypes,
            allowsMultipleSelection: false,
            onCompletion: handleSelectedFile
        )
        .ktakeSizeEagerly()
        .formattedAlert(message: $alertMessage)
        .kBindToFrameSize($viewSize)
    }

    private func resizeSelectedImageSize(image: SelectedImage) -> CGSize {
        let divider: Double = 2
        let shortestSide = min(viewSize.width, viewSize.height, 250)
        switch image.sizing {
        case .laying:
            let width = shortestSide
            let shrinkage = width / image.metadata.dimensions.width
            return CGSize(width: width / divider, height: (image.metadata.dimensions.height * shrinkage) / divider)
        case .standing:
            let height = shortestSide
            let shrinkage = height / image.metadata.dimensions.height
            return CGSize(width: (image.metadata.dimensions.width * shrinkage) / divider, height: height / divider)
        case .square:
            return CGSize(width: shortestSide / divider, height: shortestSide / divider)
        }
    }

    private func handleSelectFile() {
        isSelectingImage = true
    }

    private func handleSelectedFile(_ result: Result<[URL], Error>) {
        let urls: [URL]
        switch result {
        case .failure:
            showAlert(
                title: NSLocalizedString("Unable to read file", comment: ""),
                description: NSLocalizedString(
                    "Couldn't read the selected file\nTry again with another file",
                    comment: ""
                )
            )
            return
        case .success(let success): urls = success
        }

        guard let url = urls.first else {
            showAlert(
                title: NSLocalizedString("Unable to read file", comment: ""),
                description: NSLocalizedString(
                    "Couldn't read the selected file\nTry again with another file",
                    comment: ""
                )
            )
            return
        }

        Task {
            let result = await selectedImageManager.selectImage(url: url)
            switch result {
            case .failure(let failure):
                let errorMessage = failure.errorMessage
                showAlert(title: errorMessage.title, description: errorMessage.description)
                return
            case .success: break
            }
        }
    }

    private func showAlert(title: String, description: String?) {
        alertMessage = (title, description)
    }
}

#Preview {
    ImageResizerScreen()
}
