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
        VStack {
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
                                .padding(8)
                                .frame(width: 36, height: 36)
                                .foregroundColor(.gray.opacity(0.8))
                                .contentShape(Rectangle())
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
}


struct TopSheetTextEditorView_Previews: PreviewProvider {

    @State
    static var searchText: String = "Test"

    static var previews: some View {
        TopSheetTextEditorView(searchText: $searchText, placeholder: "Short")
    }
}
