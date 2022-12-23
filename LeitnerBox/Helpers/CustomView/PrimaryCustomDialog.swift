//
// PrimaryCustomDialog.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI

struct PrimaryCustomDialog: View {
    var title: String
    var message: String?
    var systemImageName: String?
    var textBinding: Binding<String>?
    @Binding var hideDialog: Bool
    var textPlaceholder: String?
    var submitTitle: String = "Submit"
    var cancelTitle: String = "Cancel"
    var onSubmit: ((String) -> Void)?
    var onClose: (() -> Void)?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 2) {
            if let systemImageName {
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 72)
                    .padding()
                    .foregroundColor(colorScheme == .dark ? Color.gray : Color.gray)
            }

            Text(title)
                .fontWeight(.bold)
                .padding([.top, .bottom])
            if let message {
                Text(message)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color.gray)
                    .padding([.bottom])
            }
            if let textBinding {
                PrimaryTextField(title: textPlaceholder ?? "",
                                 textBinding: textBinding,
                                 isEditing: true,
                                 keyboardType: .alphabet,
                                 backgroundColor: .black.opacity(0.05)) {}
                    .padding([.top, .bottom])
                    .padding(.bottom)
            }

            Button(submitTitle) {
                onSubmit?(textBinding?.wrappedValue ?? "")
                hideDialog.toggle()
            }

            Button(cancelTitle) {
                withAnimation {
                    hideDialog.toggle()
                    onClose?()
                }
            }
        }
    }
}

struct PrimaryCustomDialog_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryCustomDialog(title: "Title",
                            message: "Message",
                            systemImageName: "trash.fill",
                            textBinding: .constant("Text"),
                            hideDialog: .constant(false))
            .preferredColorScheme(.dark)
    }
}
