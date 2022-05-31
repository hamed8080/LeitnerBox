//
//  TextEditorView.swift
//  LeitnerBox
//
//  Created by hamed on 5/26/22.
//

import SwiftUI



struct TextEditorView: View {
    
    var placeholder : String = ""
    @Binding var string: String
    @State var textEditorHeight : CGFloat = 20
    @FocusState private var isFocused: Bool
    
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
                .cornerRadius(10.0)
                .foregroundColor(Color(named: "textColor"))
                .multilineTextAlignment(string.isContainPersianCharacter ? .trailing : .leading)
                .focused($isFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(isFocused ? .accentColor : Color.primary.opacity(0.5))
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
                        .cornerRadius(10)
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
