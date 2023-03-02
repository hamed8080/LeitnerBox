//
//  QuestionTagList.swift
//  LeitnerBox
//
//  Created by hamed on 2/15/23.
//

import SwiftUI

struct QuestionTagList: View {
    var tags: [Tag]
    var addPadding: Bool = false
    var longPressCompletion: ((Tag) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(tags) { tag in
                    Text("\(tag.name ?? "")")
                        .foregroundColor(((tag.color as? UIColor)?.isLight() ?? false) ? .black : .white)
                        .font(.footnote.weight(.semibold))
                        .padding([.top, .bottom], 4)
                        .padding([.trailing, .leading], 8)
                        .background(
                            tag.tagSwiftUIColor ?? .gray
                        )
                        .cornerRadius(6)
                        .onTapGesture {} // do not remove this line it'll stop scrolling
                        .onLongPressGesture {
                            longPressCompletion?(tag)
                        }
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .padding(addPadding ? [.leading, .bottom] : [])
        }
        .animation(.easeInOut, value: tags.count)
    }
}

struct QuestionTagList_Previews: PreviewProvider {
    static var previews: some View {
        QuestionTagList(tags: [])
    }
}
