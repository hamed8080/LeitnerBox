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
            ScrollView(.horizontal){
                HStack(spacing:4){
                    Image(systemName: "tag")
                        .resizable()
                        .frame(width: 22, height: 22, alignment: .leading)
                        .foregroundColor(.accentColor)
                        .padding([.leading])
                        .padding(.trailing, 8)
                    
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
                            .onTapGesture {  }
                            .onLongPressGesture {
                                onLongPress?(tag)
                            }
                            .transition(.asymmetric(insertion: .slide, removal: .scale))
                    }
                }
                .padding([.bottom])
            }
        }
    }
}

struct QuestionTagsView_Previews: PreviewProvider {
    static var previews: some View {
        let tags = LeitnerView_Previews.leitner.tagsArray
        QuestionTagsView(tags: tags) { tag in
            print("tag long press\(tag.name ?? "")")
        }
    }
}
