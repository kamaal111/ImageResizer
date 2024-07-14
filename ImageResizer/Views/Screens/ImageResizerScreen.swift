//
//  ImageResizerScreen.swift
//  ImageResizer
//
//  Created by Kamaal M Farah on 13/07/2024.
//

import SwiftUI

struct ImageResizerScreen: View {
    @StateObject private var selectedImageManager = SelectedImageManager()

    @State private var isSelectingImage = false
    @State private var alertMessage: (title: String, description: String?)?

    var body: some View {
        VStack {
            if let selectedImage = selectedImageManager.selectedImage?.image {
                selectedImage
                    .resizable()
            }
            Button(action: handleSelectFile) {
                Text("Select file")
            }
        }
        .fileImporter(
            isPresented: $isSelectingImage,
            allowedContentTypes: [.jpeg, .png],
            allowsMultipleSelection: false,
            onCompletion: handleSelectedFile
        )
        .formattedAlert(message: $alertMessage)
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
