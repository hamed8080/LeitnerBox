//
//  TextEditorView.swift
//  LeitnerBox
//
//  Created by hamed on 5/26/22.
//

import SwiftUI



struct TextEditorView: View {
    
    var placeholder : String = ""
    var shortPlaceholder : String = ""
    @Binding var string: String
    @State var textEditorHeight : CGFloat = 20
    @FocusState private var isFocused: Bool
    var cornerRadius = 10.0
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            Text(string)
                .font(.system(.body))
                .foregroundColor(.clear)
                .padding(14)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })
            
            TextEditor(text: $string)
                .font(.system(.body))
                .frame(height: max(40,textEditorHeight))
                .cornerRadius(cornerRadius)
                .foregroundColor(Color(named: "textColor"))
                .multilineTextAlignment(string.isContainPersianCharacter ? .trailing : .leading)
                .focused($isFocused)
                .overlay(
                    ZStack{
                        if !string.isEmpty{
                            GeometryReader{ reader in
                                Text(shortPlaceholder.uppercased())
                                    .font(.footnote)
                                    .foregroundColor(isFocused ? .accentColor : Color.primary.opacity(0.5))
                                    .offset(x: cornerRadius / 2, y: -18)
                            }
                        }
                        RoundedRectangle(cornerRadius: cornerRadius).stroke(isFocused ? .accentColor : Color.primary.opacity(0.5))
                    }.animation(.easeInOut, value: string.isEmpty)
                )
                .overlay(
                    HStack{
                        Text(verbatim: string.isEmpty ? placeholder : "")
                            .foregroundColor(.gray)
                            .disabled(true)
                            .allowsHitTesting(false)
                        Spacer()
                    }
                        .padding(.leading, 4)
                )
                .background(
                    Color.primary
                        .opacity(0.1)
                        .cornerRadius(cornerRadius)
                )
        }        
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
        }
        .onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
    }
}
                            
                            
struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
