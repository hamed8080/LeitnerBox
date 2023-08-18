//
//  ReviewControls.swift
//  LeitnerBox
//
//  Created by hamed on 11/1/22.
//

import SwiftUI

struct ReviewControls: View {
    @EnvironmentObject var viewModel: ReviewViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var objVM: ObjectsContainer

    var body: some View {
        if sizeClass == .compact {
            iphoneView
        } else {
            ipadView
        }
    }

    var iphoneView: some View {
        VStack(spacing: sizeClass == .regular ? 12 : 8) {
            HStack(spacing: 4) {
                buttons
            }
            HStack {
                passOrFalView
            }
        }
    }

    var ipadView: some View {
        HStack(spacing: sizeClass == .regular ? 12 : 8) {
            buttons
            passOrFalView
        }
    }

   @ViewBuilder var passOrFalView: some View {
        Button {
            withAnimation {
                viewModel.pass()
            }
        } label: {
            HStack {
                Spacer()
                Label("PASS", systemImage: "checkmark.circle.fill")
                Spacer()
            }
        }
        .keyboardShortcut(.return, modifiers: [.command])
        .frame(height: 22)
        .padding()
        .cornerRadius(6)
        .background(Color.accentColor.opacity(0.09).cornerRadius(12))
        .foregroundColor(Color.accentColor)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor, lineWidth: 1)
        }

        Button {
            withAnimation {
                viewModel.fail()
            }
        } label: {
            HStack {
                Spacer()
                Label("FAIL", systemImage: "xmark.circle.fill")
                Spacer()
            }
        }
        .keyboardShortcut(.return, modifiers: [.command, .shift])
        .frame(height: 22)
        .padding()
        .cornerRadius(6)
        .background(Color.red.opacity(0.09).cornerRadius(12))
        .foregroundColor(Color.red)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red, lineWidth: 1)
        }
    }

    @ViewBuilder var buttons: some View {
        Button {
            withAnimation {
                viewModel.toggleFavorite()
            }
        } label: {
            IconButtonKeyboardShortcut(title: "Favorite", systemImageName: viewModel.selectedQuestion?.favorite == true ? "star.fill" : "star")
        }
        .reviewIconStyle()
        .keyboardShortcut("f", modifiers: [.command])

        compactSpacer

        Button {
            withAnimation {
                viewModel.toggleDeleteDialog()
            }
        } label: {
            IconButtonKeyboardShortcut(title: "Delete", systemImageName: "trash")
        }
        .reviewIconStyle(accent: false)
        .keyboardShortcut(.delete, modifiers: [.command])

        compactSpacer

        if let question = viewModel.selectedQuestion {
            NavigationLink {
                AddOrEditQuestionView()
                    .environmentObject(objVM)
                    .onAppear {
                        objVM.questionVM.question = question
                        objVM.questionVM.setEditQuestionProperties(editQuestion: question)
                    }
            } label: {
                IconButtonKeyboardShortcut(title: "Edit", systemImageName: "pencil")
            }
            .reviewIconStyle()
            .keyboardShortcut("e", modifiers: [.command])
        }

        compactSpacer

        Button {
            viewModel.pronounce()
        } label: {
            IconButtonKeyboardShortcut(title: "Pronounce", systemImageName: "mic.fill")
        }
        .reviewIconStyle()
        .keyboardShortcut("p", modifiers: [.command])

        compactSpacer

        Button {
            withAnimation {
                viewModel.copyQuestionToClipboard()
            }
        } label: {
            IconButtonKeyboardShortcut(title: "Copy To Clipbaord", systemImageName: "doc.on.doc")
        }
        .reviewIconStyle(accent: false)
        .keyboardShortcut("c", modifiers: [.command])
    }

   @ViewBuilder var compactSpacer: some View {
        if sizeClass == .compact {
            Spacer()
        }
    }
}
