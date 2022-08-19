//
//  TopSheetTextEditorView.swift
//  LeitnerBox
//
//  Created by hamed on 5/26/22.
//

import SwiftUI

struct TopSheetTextEditorView: View {

    @Binding
    var searchText:String
    let placeholder: String

    var body: some View {
        TextEditor(text: $searchText)
            .padding([.leading, .trailing], 4)
            .font(.system(.body))
            .frame(height: 48)
            .foregroundColor(Color(named: "textColor"))
            .overlay(
                HStack{
                    HStack {
                        if searchText.isEmpty {
                            Image(systemName: "magnifyingglass")
                        }
                        Text("\(searchText.isEmpty ? placeholder : "")")
                    }
                    .foregroundColor(.gray)
                    .disabled(true)
                    .allowsHitTesting(false)

                    Spacer()

                    if searchText.isEmpty == false {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.gray.opacity(0.8))
                            .onTapGesture {
                                searchText = ""
                            }
                    }
                }
                    .padding([.leading, .trailing], 12)
            )

        Divider()
    }
}
