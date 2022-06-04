//
//  QuestionTagsView.swift
//  LeitnerBox
//
//  Created by hamed on 6/4/22.
//

import SwiftUI

struct QuestionTagsView: View {
    
    var tags:[Tag]
    
    var onLongPress:((Tag)->())? = nil
    
    var body: some View {
        if tags.count > 0{
            HStack(spacing:6){
                Image(systemName: "tag")
                    .frame(width: 36, height: 36, alignment: .leading)
                    .foregroundColor(.accentColor)
                
                ScrollView{
                    LazyHGrid(rows: [.init(.flexible(minimum: 48, maximum: 48), spacing: 8, alignment: .leading)]) {
                        ForEach(tags) { tag in
                            Text("\(tag.name ?? "")")
                                .foregroundColor( ((tag.color as? UIColor)?.isLight() ?? false) ? .black : .white)
                                .font(.footnote.weight(.semibold))
                                .padding([.top, .bottom], 4)
                                .padding([.trailing, .leading], 8)
                                .background(
                                    (tag.tagSwiftUIColor ?? .gray)
                                )
                                .cornerRadius(6)
                                .onLongPressGesture {
                                    onLongPress?(tag)
                                }
                                .transition(.asymmetric(insertion: .slide, removal: .scale))
                        }
                    }
                }
            }
        }
    }
}

struct QuestionTagsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionTagsView(tags: [Tag()] ) { tag in
            print("tag long press\(tag.name ?? "")")
        }
    }
}
