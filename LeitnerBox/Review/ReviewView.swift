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

    var body: some View {
        if vm.isFinished{
            FinishedReviewView()
        }
        else if vm.level.hasAnyReviewable{
            ZStack{
                    VStack{
                        Text("Total: \(vm.passCount + vm.failedCount) / \(vm.totalCount), Passed: \(vm.passCount), Failed: \(vm.failedCount)".uppercased())
                            .font(isIpad ? .title3.bold() : .footnote.bold())
                        
                        Spacer()
                        
                        HStack{
                            Spacer()
                            Text(vm.selectedQuestion?.question ?? "")
                                .font(.largeTitle.weight(.bold))
                            Spacer()
                        }
                        
                        HStack(spacing: isIpad ? 48 : 36){
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    vm.showDeleteDialog()
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.orange)
                            }
                            
                            Button {
                                vm.editQuestion()
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
                        
                        Spacer()
                        HStack{
                            Spacer()
                            Text(vm.selectedQuestion?.answer ?? "")
                                .font(.title2.weight(.medium))
                            Spacer()
                        }.transition(.slide)
                        
                        if vm.selectedQuestion?.detailDescription != nil{
                            HStack{
                                Spacer()
                                Text(vm.selectedQuestion?.detailDescription ?? "")
                                    .font(.title2.weight(.medium))
                                Spacer()
                            }.transition(.slide)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: isIpad ? 48 : 12){
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
                    }
                    
                
                NavigationLink(isActive:$vm.showAddQuestionView) {
                    AddOrEditQuestionView(vm: .init(level: vm.level))
                } label: {
                    EmptyView()
                }
                .hidden()
                
                NavigationLink(isActive:$vm.showEditQuestionView) {
                    AddOrEditQuestionView(vm: .init(level: vm.level, editQuestion: vm.selectedQuestion))
                } label: {
                    EmptyView()
                }
                .hidden()
                
                if let leitner = vm.level.leitner{
                    NavigationLink(isActive:$vm.showSearchView) {
                        SearchView(vm: SearchViewModel(leitner: leitner))
                    } label: {
                        EmptyView()
                    }
                    .hidden()
                }
                
            }
            .customDialog(isShowing: $vm.showDelete, content: {
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
                
            })
            .animation(.easeInOut, value: vm.isShowingAnswer)
            .padding()
            .background( Color(named: "dialogBackground"))
            .toolbar {
                
                ToolbarItem {
                    Button {
                        vm.showAddQuestionView.toggle()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                
                ToolbarItem {
                    Button {
                        vm.showSearchView.toggle()
                    } label: {
                        Label("Search View", systemImage: "list.bullet.rectangle.portrait")
                    }
                }
            }
        }else{
            NotAnyToReviewView()
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
    
    var body: some View{
        VStack{
            Image(systemName: "rectangle.and.text.magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .foregroundColor(.gray)
            Text("There is nothing to review here at the moment.")
                .font(.title2.weight(.medium))
                .foregroundColor(.gray)
        }
    }
}

struct FinishedReviewView:View{
    
    var body: some View{
        VStack{
            Image(systemName: "flag.filled.and.flag.crossed")
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .foregroundColor(.gray)
            
            Text("You have finished all quesitons inside this leitner level.")
                .font(.title2.weight(.medium))
                .foregroundColor(.gray)
        }
    }
}

struct NotAnyToReviewView_Previews: PreviewProvider {
    static var previews: some View {
        NotAnyToReviewView()
            .previewDevice("iPhone 13 Pro Max")
    }
}


struct ReviewView_Previews: PreviewProvider {
    
    static var level:Level?{
        (LeitnerView_Previews.leitner.level?.allObjects as? [Level])?.first
    }
    
    static var previews: some View {
        if let level = level{
            ReviewView(vm: ReviewViewModel(level: level))
                .previewDevice("iPhone 13 mini")
                .preferredColorScheme(.light)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
