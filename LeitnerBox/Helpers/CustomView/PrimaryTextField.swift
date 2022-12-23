//
// PrimaryTextField.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI

struct PrimaryTextField: View {
    enum FocusField: Hashable {
        case field
    }

    var title: String
    @Binding var textBinding: String
    @State var isEditing: Bool = false
    var keyboardType: UIKeyboardType = .phonePad
    var corenrRadius: CGFloat = 8
    var backgroundColor: Color = .white
    @FocusState var focusedField: FocusField?
    var onCommit: (() -> Void)?

    var body: some View {
        TextField(
            title,
            text: $textBinding
        ) { isEditing in
            self.isEditing = isEditing
        } onCommit: {
            onCommit?()
        }
        .keyboardType(keyboardType)
        .padding(.init(top: 0, leading: 8, bottom: 0, trailing: 0))
        .frame(minHeight: 56)
        .focused($focusedField, equals: .field)
        .background(
            backgroundColor.cornerRadius(corenrRadius)
                .onTapGesture {
                    if focusedField != .field {
                        focusedField = .field
                    }
                }
        )
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isEditing ? Color.gray : Color.clear))
    }
}

struct PrimaryTextField_Previews: PreviewProvider {
    @State static var text: String = ""

    static var previews: some View {
        VStack {
            PrimaryTextField(title: "Placeholder", textBinding: $text)
            PrimaryTextField(title: "Placeholder", textBinding: $text)
        }
    }
}
