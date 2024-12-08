//
//  QuestionImagesView.swift
//  LeitnerBox
//
//  Created by Hamed Hosseini on 12/8/24.
//

import SwiftUI

struct QuestionImagesView: View {
    @EnvironmentObject var questionVM: QuestionViewModel
    private let itemSize: CGFloat = 128 // Fixed item size
    @State private var screenWidth: CGFloat = 0
    let isInReviewView: Bool
    
    var body: some View {
        let columnsCount = Int(screenWidth / itemSize)
        let columns = Array(repeating: GridItem(.fixed(itemSize), spacing: 16), count: columnsCount)
        VStack {
            headerTitle
            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(questionVM.images, id: \.self) { image in
                    if let urlString = image.url, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: itemSize, height: itemSize)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedCorner(radius: 8))
                        .overlay(alignment: .topLeading) {
                            if !isInReviewView {
                                removeButton(image)
                            }
                        }
                    }
                }
                
                if !isInReviewView {
                    addImageButton
                }
            }
            if !isInReviewView {
                footerView
            }
        }
        .animation(.easeInOut, value: questionVM.images.count)
        .background {
            GeometryReader { reader in
                Color.clear
                    .onAppear {
                        screenWidth = reader.size.width
                    }
            }
        }
    }
    
    private var headerTitle: some View {
        HStack {
            Text("Image links")
                .foregroundStyle(Color("AccentColor"))
                .fontWeight(.bold)
            Spacer()
        }
    }
    
    private var footerView: some View {
        HStack {
            Text("Add your image links copied to the clipborad.")
                .foregroundStyle(.gray)
                .font(.footnote)
            Spacer()
        }
    }
    
    private var addImageButton: some View {
        Button {
            if let link = UIPasteboard.general.string, let _ = URL(string: link) {
                questionVM.addImage(link)
            }
        } label: {
            HStack {
                Image(systemName: "photo.badge.plus")
                    .foregroundStyle(Color("AccentColor"))
            }
            .padding()
            .clipShape(RoundedCorner(radius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("AccentColor"), lineWidth: 1)
            }
        }
    }
    
    @ViewBuilder
    private func removeButton(_ image: ImageURL) -> some View {
        Button {
            questionVM.removeImage(image)
        } label: {
            Image(systemName: "minus.circle.fill")
                .symbolRenderingMode(.multicolor)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(Color.red, Color.white)
        }
        .offset(x: -8, y: -8)
    }
}

struct QuestionImagesView_Previews: PreviewProvider {
    struct Preview: View {
        static let leitner = PersistenceController.shared.generateAndFillLeitner().first!
        static let question = Question(context: PersistenceController.shared.viewContext)
        @StateObject var viewModel = QuestionViewModel(
            viewContext: PersistenceController.shared.viewContext,
            leitner: Preview.leitner,
            question: question
        )

        var body: some View {
            QuestionImagesView(isInReviewView: false)
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
