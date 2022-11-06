//
// CustomDialog.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI

struct CustomDialog<DialogContent: View>: ViewModifier {
    @Binding
    private var isShowing: Bool
    private var dialogContent: DialogContent

    @Environment(\.colorScheme) var colorScheme

    init(isShowing: Binding<Bool>, @ViewBuilder dialogContent: @escaping () -> DialogContent) {
        _isShowing = isShowing
        self.dialogContent = dialogContent()
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                // the semi-transparent overlay
                Rectangle().foregroundColor(Color.black.opacity(0.6))
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .animation(.easeInOut, value: isShowing)
                // the dialog content is in a ZStack to pad it from the edges
                // of the screen
                ZStack {
                    dialogContent
                        .frame(maxWidth: 300)
                }
                .transition(.scale)
                .padding(40)
                .background(.thinMaterial)
                .cornerRadius(24)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: isShowing ? 0.6 : 1, blendDuration: isShowing ? 1 : 0.2).speed(isShowing ? 1 : 3), value: isShowing)
    }
}

struct CustomDialog_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {}
            .preferredColorScheme(.dark)
            .customDialog(isShowing: .constant(true)) {
                VStack {
                    Text("Hello".uppercased())
                        .fontWeight(.bold)
                    Text("Message")

                    HStack {
                        Button("Hello") {}

                        Button("Hello") {}
                    }
                }
                .padding()
            }
    }
}

extension View {
    func customDialog<DialogContent: View>(isShowing: Binding<Bool>, @ViewBuilder content: @escaping () -> DialogContent) -> some View {
        modifier(CustomDialog(isShowing: isShowing, dialogContent: content))
    }
}
