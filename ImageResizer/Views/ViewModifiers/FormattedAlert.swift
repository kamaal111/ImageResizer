//
//  FormattedAlert.swift
//  ImageResizer
//
//  Created by Kamaal M Farah on 13/07/2024.
//

import SwiftUI

extension View {
    func formattedAlert(message: Binding<(title: String, description: String?)?>) -> some View {
        self
            .modifier(FormattedAlert(message: message))
    }
}

private struct FormattedAlert: ViewModifier {
    @State private var alertIsShown = false

    @Binding var message: (title: String, description: String?)?

    func body(content: Content) -> some View {
        content
            .onChange(of: message?.title) { newValue in
                alertIsShown = newValue != nil
            }
            .onChange(of: alertIsShown) { newValue in
                if !alertIsShown {
                    message = nil
                }
            }
            .alert(message?.title ?? "", isPresented: $alertIsShown, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(message?.description ?? "")
            })
    }
}
