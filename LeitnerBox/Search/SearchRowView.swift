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
        VStack(alignment:.leading, spacing: 4){
            questionAndAnswer
                .padding(.top, 8)
                .padding([.leading,.trailing])
            HStack{
                levelAndAvailibility
                Spacer()
                completed
                controls
            }
            .padding([.leading, .trailing])
            if let tags = question.tagsArray{
                QuestionTagsView(tags: tags){ tag in
                    vm.removeTagForQuestion(question, tag)
                }
            }
        }
    }
    
    var iphoneView:some View{
        VStack{
            VStack(alignment:.leading, spacing: 4){
                questionAndAnswer
                levelAndAvailibility
                HStack{
                    completed
                    Spacer()
                    controls
                }
            }.padding()
            
            if let tags = question.tagsArray{
                QuestionTagsView(tags: tags){ tag in
                    vm.removeTagForQuestion(question, tag)
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
        if let answer = question.answer, !answer.isEmpty {
            Text(answer.uppercased())
                .foregroundColor(.gray)
                .font(.headline.bold())
        }
        
        if let detailDescription = question.detailDescription, !detailDescription.isEmpty{
            Text(detailDescription.uppercased())
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
                    let vm = LeitnerViewModel(viewContext: PersistenceController.shared.container.viewContext)
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
                    let vm = TagViewModel(viewContext: PersistenceController.shared.container.viewContext, leitner: vm.leitner)
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
    
    static var tag:Tag{
        let req = Tag.fetchRequest()
        req.fetchLimit = 1
        let tag = (try! PersistenceController.preview.container.viewContext.fetch(req)).first!
        return tag
    }
    
    static var previews: some View {
        let leitner  = LeitnerView_Previews.leitner
        let question = leitner.levels.filter({$0.level == 1}).first?.allQuestions.first as? Question
        SearchRowView(question: question ?? Question(context: PersistenceController.preview.container.viewContext), vm: SearchViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: leitner))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
