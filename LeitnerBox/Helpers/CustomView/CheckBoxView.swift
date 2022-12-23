//
// CheckBoxView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI

struct CheckBoxView: View {
    @Binding var isActive: Bool
    let text: String

    var body: some View {
        Button {
            isActive.toggle()
        } label: {
            HStack {
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text(text)
                Spacer()
            }
        }
    }
}
