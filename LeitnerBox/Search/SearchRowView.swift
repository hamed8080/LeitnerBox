//
//  SearchRowView.swift
//  LeitnerBox
//
//  Created by hamed on 5/21/22.
//

import SwiftUI

struct SearchRowView: View {
    
    @ObservedObject
    var question:Question

    @ObservedObject
    var vm:SearchViewModel
    
    var questionState:((QuestionStateChanged)->())? = nil
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment:.leading, spacing: 8){
                    Text(question.question ?? "")
                        .font(.title2.bold())
                    
                    Text(question.answer?.uppercased() ?? "")
                        .foregroundColor(.gray)
                        .font(.headline.bold())
                    
                    if question.detailDescription != nil{
                        Text(question.detailDescription?.uppercased() ?? "")
                            .foregroundColor(.gray)
                            .font(.headline.bold())
                    }
                    
                    HStack{
                        Text(verbatim: "LEVEL: \(question.level?.level ?? 0)")
                            .foregroundColor(.blue)
                            .font(.footnote.bold())
                        
                        Text(question.remainDays)
                            .foregroundColor(.gray)
                            .font(.footnote.bold())
                    }
                }
                
                Spacer()
                HStack(spacing:8){
                    if question.completed{
                        Text("COMPLETED")
                            .foregroundColor(.blue)
                            .font(.subheadline.bold())
                    }
                    
                    Button {
                        vm.pronounceOnce(question)
                    } label: {
                        Image(systemName: "mic.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.borderless)
                    
                    Button {
                        withAnimation {
                            vm.toggleFavorite(question)
                        }
                    } label: {
                        
                        Image(systemName: question.favorite ? "star.fill" : "star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.borderless)
                    
                    Menu {
                        Button(role: .destructive) {
                            withAnimation {
                                vm.delete(question)
                                questionState?(.DELTED(question))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Divider()
                        
                        Button {
                            vm.selectedQuestion = question
                            vm.showAddQuestionView.toggle()
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button {
                            withAnimation {
                                vm.resetToFirstLevel(question)
                            }
                        } label: {
                            Label("Reset to first level", systemImage: "goforward")
                        }
                        
                        Menu("Move"){
                            let vm = LeitnerViewModel()
                            ForEach(vm.leitners){ leitner in
                                Button {
                                    withAnimation {
                                        self.vm.selectedQuestion = question
                                        self.vm.moveQuestionTo(leitner)
                                    }
                                } label: {
                                    Label( "\(leitner.name ?? "")", systemImage: "folder")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
    
}

struct SearchRowView_Previews: PreviewProvider {
    
    static var previews: some View {
        SearchRowView(question: Question(context: PersistenceController.preview.container.viewContext), vm: SearchViewModel(leitner: Leitner()))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
