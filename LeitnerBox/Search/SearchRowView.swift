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
    
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @Environment(\.dynamicTypeSize)
    var typeSize
    
    var body: some View {
        HStack{
            if sizeClass == .regular && typeSize == .large{
                ipadView
            }else{
                iphoneView
            }
        }
    }
    
    var ipadView:some View{
        VStack(alignment:.leading, spacing: 8){
            questionAndAnswer
            HStack{
                levelAndAvailibility
                Spacer()
                completed
                controls
            }
            if let tags = question.tagsArray{
                QuestionTagsView(tags: tags){ tag in
                    vm.removeTagForQuestio(question, tag)
                }
            }
        }
    }
    
    var iphoneView:some View{
        VStack(alignment:.leading, spacing: 4){
            questionAndAnswer
            levelAndAvailibility
            HStack{
                completed
                Spacer()
                controls
            }
            
            if let tags = question.tagsArray{
                QuestionTagsView(tags: tags){ tag in
                    vm.removeTagForQuestio(question, tag)
                }
            }
        }
    }
    
    var levelAndAvailibility:some View{
        HStack{
            Text(verbatim: "LEVEL: \(question.level?.level ?? 0)")
                .foregroundColor(.blue)
                .font(.footnote.bold())
            
            Text(question.remainDays)
                .foregroundColor(.gray)
                .font(.footnote.bold())
        }
    }
    
    @ViewBuilder
    var questionAndAnswer:some View{
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
    }
    
    @ViewBuilder
    var completed:some View{
        if question.completed{
            Text("COMPLETED")
                .foregroundColor(.blue)
                .font(.footnote.bold())
        }
    }
    
    var controls:some View{
        HStack(spacing:8){
            let controlSize:CGFloat = 24
            Button {
                vm.pronounceOnce(question)
            } label: {
                Image(systemName: "mic.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: controlSize, height: controlSize)
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
                    .frame(width: controlSize, height: controlSize)
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
                
                Button {
                    withAnimation {
                        vm.complete(question)
                    }
                } label: {
                    Label("Mark as completed", systemImage: "tray.full")
                }
                
                Divider()
                
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
                
                Menu("Tag"){
                    let vm = TagViewModel(leitner: vm.leitner)
                    ForEach(vm.tags){ tag in
                        Button {
                            withAnimation {
                                vm.addToTag(tag, question)
                            }
                        } label: {
                            Label( "\(tag.name ?? "")", systemImage: "tag")
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: controlSize, height: controlSize)
                    .padding(8)
                    .foregroundColor(.accentColor)
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
