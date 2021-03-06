//
//  ReviewView.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI
import CoreData

struct ReviewView: View {
    
    @ObservedObject
    var vm:ReviewViewModel
    
    @State
    private var isAnimationShowAnswer = false
    
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    var body: some View {
        if vm.isFinished{
            NotAnyToReviewView()
        }
        else if vm.level.hasAnyReviewable{
            ZStack{
                VStack{
                    ScrollView(showsIndicators: false){
                        VStack(spacing:48){
                            if sizeClass == .regular{
                                ipadHeader
                            }else{
                                headers
                            }
                            questionView
                            tags
                            controls
                            answersAndDetails
                        }
                    }
                    Spacer()
                    reviewControls
                }
            }
            .animation(.easeInOut, value: vm.isShowingAnswer)
            .padding()
            .background( Color(named: "dialogBackground"))
            .toolbar {
                
                ToolbarItem {
                    
                    NavigationLink{
                        let levels = vm.level.leitner?.levels
                        let firstLevel = levels?.first(where: {$0.level == 1})
                        AddOrEditQuestionView(vm: .init(viewContext: PersistenceController.shared.container.viewContext, level: firstLevel!))
                    } label: {
                        Label("Add Item", systemImage: "plus.square")
                    }
                }
                
                ToolbarItem {
                    
                    if let leitner = vm.level.leitner{
                        NavigationLink{
                            SearchView(vm: SearchViewModel(viewContext: PersistenceController.shared.container.viewContext, leitner: leitner))
                        } label: {
                            Label("Search View", systemImage: "list.bullet.rectangle.portrait")
                        }
                    }
                }
            }
            .customDialog(isShowing: $vm.showDelete, content: {
                deleteDialog
            })
        }else{
            NotAnyToReviewView()
        }
    }
    
    var deleteDialog:some View{
        VStack{
            Text(attributedText(text: "Are you sure you want to delete \(vm.selectedQuestion?.question ?? "") question?", textRange: vm.selectedQuestion?.question ?? ""))
            
            Button {
                vm.showDelete.toggle()
            } label: {
                HStack{
                    Spacer()
                    Text("Cancel")
                        .foregroundColor(.accentColor)
                    Spacer()
                }
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            
            Button {
                vm.deleteQuestion()
            } label: {
                HStack{
                    Spacer()
                    Text("Delete")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
    }
    
    var headers:some View{
        VStack{
            Text(verbatim: "Level: \(vm.level.level)")
                .font(.title.weight(.semibold))
                .padding(.bottom)
                .foregroundColor(.accentColor)
            Text("Total: \(vm.passCount + vm.failedCount) / \(vm.totalCount), Passed: \(vm.passCount), Failed: \(vm.failedCount)".uppercased())
                .font( sizeClass == .compact ? .body.bold() : .title3.bold())
        }
    }
    
    
    
    var ipadHeader:some View{
        HStack{
            LinearGradient(colors: [.mint.opacity(0.8), .mint.opacity(0.5), .blue.opacity(0.3)], startPoint: .top, endPoint: .bottom).mask {
                Text("\(vm.passCount)")
                    .fontWeight(.semibold)
                    .font(.system(size: 96, weight: .bold, design: .rounded))
            }

            Spacer()
            Text("Total: \(vm.totalCount)".uppercased())
                .font( sizeClass == .compact ? .body.bold() : .title3.bold())
            Spacer()
            LinearGradient(colors: [.yellow.opacity(0.8), .yellow.opacity(0.5) , .orange.opacity(0.3)], startPoint: .top, endPoint: .bottom).mask {
                Text("\(vm.failedCount)")
                    .fontWeight(.semibold)
                    .font(.system(size: 96, weight: .bold, design: .rounded))
            }
        }
        .frame(height:128)
        .padding([.leading, .trailing],64)
    }
    
    var reviewControls:some View{
        HStack(spacing: sizeClass == .regular ? 48 : 8){
            Button {
                withAnimation {
                    vm.pass()
                }
            } label: {
                HStack{
                    Spacer()
                    Label("PASS", systemImage: "checkmark.circle.fill")
                    Spacer()
                }
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            .tint(.accentColor)
            
            Button{
                withAnimation {
                    vm.fail()
                }
            } label: {
                HStack{
                    Spacer()
                    Label("FAIL", systemImage: "xmark.circle.fill")
                    Spacer()
                }
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            .tint(.red)
        }
        .padding([.leading, .trailing])
    }
    
    var questionView:some View{
        HStack{
            Spacer()
            VStack(spacing:16){
                Text(vm.selectedQuestion?.question ?? "")
                    .multilineTextAlignment(.center)
                    .font(sizeClass == .compact ? .title2.weight(.semibold) : .largeTitle.weight(.bold))
               
                Text(vm.selectedQuestion?.detailDescription ?? "")
                    .font(sizeClass == .compact ? .title3.weight(.semibold) : .title2.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("subtitleTextColor"))
                    .transition(.scale)
                    .onTapGesture {
                        vm.toggleAnswer()
                    }
                if let ps = vm.partOfspeech{
                    Text(ps)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.accentColor)
                }
            }
           
            Spacer()
        }
    }
    
    @ViewBuilder
    var tags:some View{
        if let selectedQuestion = vm.selectedQuestion, let tags = selectedQuestion.tagsArray{
            QuestionTagsView(tags: tags) { tag in
                vm.removeTagForQuestion(tag)
            }.frame(maxWidth: sizeClass == .compact ? .infinity : 350)
        }
    }
    
    var tapToAnswerView:some View{
        Text("Tap to show answer")
            .foregroundColor(.accentColor)
            .colorMultiply(isAnimationShowAnswer ? .accentColor : .accentColor.opacity(0.5))
            .font(.title2.weight(.medium))
            .scaleEffect(isAnimationShowAnswer ? 1.05 : 1)
            .rotation3DEffect(.degrees(isAnimationShowAnswer ? 0 : 90), axis: (x: 100, y: 1, z: 0), anchor: .leading, anchorZ: 10)
            .animation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true), value: isAnimationShowAnswer)
            .onAppear{
                isAnimationShowAnswer = true
            }
            .onDisappear{
                isAnimationShowAnswer = false
            }
            .onTapGesture {
                vm.toggleAnswer()
            }
    }
    
    @ViewBuilder
    var answerView:some View{
        HStack{
            Spacer()
            Text(vm.selectedQuestion?.answer ?? "")
                .font( sizeClass == .compact ? .title3.weight(.semibold) : .title2.weight(.medium))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .onTapGesture {
            vm.toggleAnswer()
        }
        .transition(.scale)
    }
    
    @ViewBuilder
    var answersAndDetails: some View{
        if vm.isShowingAnswer{
           answerView
        }else{
            tapToAnswerView
        }
    }
    
    var addTagsView:some View{
        Menu {
            ForEach(vm.tags){ tag in
                Button {
                    withAnimation {
                        vm.addTagToQuestion(tag)
                    }
                } label: {
                    Label( "\(tag.name ?? "")", systemImage: "tag")
                }
            }
        } label: {
            Image(systemName: "tag")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(.accentColor)
        }
    }
    
    var controls:some View{
        HStack(spacing: sizeClass == .compact ? 26 : 48){
            
            Spacer()
            
            Button {
                withAnimation {
                    vm.toggleDeleteDialog()
                }
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.orange)
            }
            
            NavigationLink{
                AddOrEditQuestionView(vm: .init(viewContext: PersistenceController.shared.container.viewContext, level: vm.level, editQuestion: vm.selectedQuestion))
            } label: {
                Image(systemName: "pencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.accentColor)
            }
            
            Button {
                withAnimation {
                    vm.toggleFavorite()
                }
            } label: {
                Image(systemName: vm.selectedQuestion?.favorite == true ? "star.fill" : "star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.accentColor)
            }
            
            addTagsView
            
            Button {
                vm.pronounce()
            } label: {
                Image(systemName: "mic.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.accentColor)
            }
            
            Spacer()
        }
    }
    
    func attributedText(text:String, textRange:String)->AttributedString{
        var text = AttributedString(text)
        if let range = text.range(of: textRange) {
            text[range].foregroundColor = .purple
            text[range].font = .title2.bold()
        }
        return text
    }
}

struct NotAnyToReviewView:View{
    
    @State
    private var isAnimating = false
    
    var body: some View{
        VStack(spacing:12){
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64,alignment: .center)
                .foregroundStyle(.white, Color("green_light") )
                .scaleEffect(isAnimating ? 1 : 0.8)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color("green_light").opacity(0.5), lineWidth: 16)
                        .scaleEffect(isAnimating ? 1.1 : 0.8)
                )
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                        isAnimating = true
                    }
                }
            
            Text("There is nothing to review here at the moment.")
                .font(.body.weight(.medium))
                .foregroundColor(.gray)
        }
        .frame(height: 96)
    }
}

struct NotAnyToReviewView_Previews: PreviewProvider {
    static var previews: some View {
        NotAnyToReviewView()
    }
}


struct ReviewView_Previews: PreviewProvider {
    
    static var previews: some View {
        let level = (LeitnerView_Previews.leitner.levels).filter({$0.level == 1}).first
        ReviewView(vm: ReviewViewModel(viewContext: PersistenceController.preview.container.viewContext,level: level!))
            .preferredColorScheme(.light)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
