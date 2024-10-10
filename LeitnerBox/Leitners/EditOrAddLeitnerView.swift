//
//  EditOrAddLeitnerView.swift
//  LeitnerBox
//
//  Created by hamed on 10/10/24.
//

import SwiftUI

struct EditOrAddLeitnerView: View {
    @EnvironmentObject var viewModel: LeitnerViewModel

    var body: some View {
        VStack(spacing: 24) {
            nameLabel
            editor
            toggle
            saveButton
            cancelButton
        }
    }

    private var nameLabel: some View {
        Text("Leitner name")
            .foregroundColor(.accentColor)
            .font(.title2.bold())
    }

    private var editor: some View {
        TextEditorView(
            placeholder: "Enter leitner name",
            shortPlaceholder: "Name",
            string: $viewModel.leitnerTitle,
            textEditorHeight: 48
        )
    }

    private var toggle: some View {
        Toggle(isOn: $viewModel.backToTopLevel) {
            Label("Back to top level", systemImage: "arrow.up.to.line")
        }
    }

    private var saveButton: some View {
        Button {
            viewModel.editOrAddLeitner()
        } label: {
            HStack {
                Spacer()
                Text("SAVE")
                    .foregroundColor(.accentColor)
                Spacer()
            }
        }
        .controlSize(.large)
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity)
        .tint(.accentColor)
    }

    private var cancelButton: some View {
        Button {
            withAnimation {
                viewModel.showEditOrAddLeitnerAlert.toggle()
            }
        } label: {
            HStack {
                Spacer()
                Text("Cancel")
                    .foregroundColor(.red)
                Spacer()
            }
        }
        .controlSize(.large)
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity)
        .tint(.red)
        .animation(.easeInOut, value: viewModel.showEditOrAddLeitnerAlert)
    }
}

#Preview {
    EditOrAddLeitnerView()
}
