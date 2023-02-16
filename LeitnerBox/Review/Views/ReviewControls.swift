//
//  ReviewControls.swift
//  LeitnerBox
//
//  Created by hamed on 11/1/22.
//

import CoreData
import SwiftUI

struct ReviewControls: View {
    @EnvironmentObject var viewModel: ReviewViewModel
    @EnvironmentObject var objVM: ObjectsContainer
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext

    var body: some View {
        HStack(spacing: sizeClass == .compact ? 26 : 48) {
            Spacer()

            Button {
                withAnimation {
                    viewModel.toggleDeleteDialog()
                }
            } label: {
                IconButtonKeyboardShortcut(title: "Delete", systemImageName: "trash")
            }
            .reviewIconStyle(accent: false)
            .keyboardShortcut(.delete, modifiers: [.command])

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

            Button {
                withAnimation {
                    viewModel.toggleFavorite()
                }
            } label: {
                IconButtonKeyboardShortcut(title: "Favorite", systemImageName: viewModel.selectedQuestion?.favorite == true ? "star.fill" : "star")
            }
            .reviewIconStyle()
            .keyboardShortcut("f", modifiers: [.command])

            Button {
                viewModel.pronounce()
            } label: {
                IconButtonKeyboardShortcut(title: "Pronounce", systemImageName: "mic.fill")
            }
            .reviewIconStyle()
            .keyboardShortcut("p", modifiers: [.command])

            Button {
                withAnimation {
                    viewModel.copyQuestionToClipboard()
                }
            } label: {
                IconButtonKeyboardShortcut(title: "Copy To Clipbaord", systemImageName: "doc.on.doc")
            }
            .reviewIconStyle(accent: false)
            .keyboardShortcut("c", modifiers: [.command])
            Spacer()
        }
    }
}
