//
// ReviewView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/28/22.

import CoreData
import SwiftUI

struct ReviewView: View {
    @ObservedObject
    var vm: ReviewViewModel

    @State
    private var isAnimationShowAnswer = false

    @Environment(\.horizontalSizeClass)
    var sizeClass

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if vm.isFinished {
            NotAnyToReviewView()
        } else if vm.level.hasAnyReviewable {
            ZStack {
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 48) {
                            if sizeClass == .regular {
                                ipadHeader
                            } else {
                                headers
                            }
                            questionView
                            VStack(alignment: .leading, spacing: 4) {
                                tags
                                synonyms
                            }
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
            .background(Color(named: "dialogBackground"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: LazyView(AddOrEditQuestionView(vm: .init(viewContext: vm.viewContext, level: insertQuestion.level!, question: insertQuestion, isInEditMode: false)))) {
                        Label("Add Item", systemImage: "plus.square")
                            .font(.title3)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
                    }

                    if let leitner = vm.level.leitner {
                        NavigationLink {
                            SearchView(vm: SearchViewModel(viewContext: PersistenceController.shared.container.viewContext, leitner: leitner))
                        } label: {
                            Label("Search View", systemImage: "square.text.square")
                                .font(.title3)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
                        }
                    }
                }
            }
            .customDialog(isShowing: $vm.showDelete, content: {
                deleteDialog
            })
        } else {
            NotAnyToReviewView()
        }
    }

    var insertQuestion: Question {
        let question = Question(context: vm.viewContext)
        question.level = vm.level.leitner?.firstLevel
        return question
    }

    var deleteDialog: some View {
        VStack {
            Text(attributedText(text: "Are you sure you want to delete \(vm.selectedQuestion?.question ?? "") question?", textRange: vm.selectedQuestion?.question ?? ""))

            Button {
                vm.showDelete.toggle()
            } label: {
                HStack {
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
                HStack {
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

    var headers: some View {
        VStack {
            Text(verbatim: "Level: \(vm.level.level)")
                .font(.title.weight(.semibold))
                .padding(.bottom)
                .foregroundColor(.accentColor)
            Text("Total: \(vm.passCount + vm.failedCount) / \(vm.totalCount), Passed: \(vm.passCount), Failed: \(vm.failedCount)".uppercased())
                .font(sizeClass == .compact ? .body.bold() : .title3.bold())
        }
    }

    var ipadHeader: some View {
        HStack {
            LinearGradient(colors: [.mint.opacity(0.8), .mint.opacity(0.5), .blue.opacity(0.3)], startPoint: .top, endPoint: .bottom).mask {
                Text(verbatim: "\(vm.passCount)")
                    .fontWeight(.semibold)
                    .font(.system(size: 96, weight: .bold, design: .rounded))
            }

            Spacer()
            Text("Total: \(vm.totalCount)".uppercased())
                .font(sizeClass == .compact ? .body.bold() : .title3.bold())
            Spacer()
            LinearGradient(colors: [.yellow.opacity(0.8), .yellow.opacity(0.5), .orange.opacity(0.3)], startPoint: .top, endPoint: .bottom).mask {
                Text(verbatim: "\(vm.failedCount)")
                    .fontWeight(.semibold)
                    .font(.system(size: 96, weight: .bold, design: .rounded))
            }
        }
        .frame(height: 128)
        .padding([.leading, .trailing], 64)
    }

    var reviewControls: some View {
        HStack(spacing: sizeClass == .regular ? 48 : 8) {
            Button {
                withAnimation {
                    vm.pass()
                }
            } label: {
                HStack {
                    Spacer()
                    Label("PASS", systemImage: "checkmark.circle.fill")
                    Spacer()
                }
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            .tint(.accentColor)

            Button {
                withAnimation {
                    vm.fail()
                }
            } label: {
                HStack {
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

    var questionView: some View {
        HStack {
            Spacer()
            VStack(spacing: 16) {
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
                if let ps = vm.partOfspeech {
                    Text(ps)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.accentColor)
                }
            }

            Spacer()
        }
    }

    @ViewBuilder
    var tags: some View {
        if let selectedQuestion = vm.selectedQuestion, let leitner = vm.level.leitner {
            QuestionTagsView(question: selectedQuestion, viewModel: .init(viewContext: vm.viewContext, leitner: leitner), accessControls: [.addTag, .showTags, .removeTag])
                .frame(maxWidth: sizeClass == .compact ? .infinity : 350)
        }
    }

    @ViewBuilder
    var synonyms: some View {
        if let question = vm.selectedQuestion {
            QuestionSynonymsView(viewModel: .init(viewContext: vm.viewContext, question: question), accessControls: [.addSynonym, .showSynonyms, .removeSynonym])
        }
    }

    var tapToAnswerView: some View {
        Text("Tap to show answer")
            .foregroundColor(.accentColor)
            .colorMultiply(isAnimationShowAnswer ? .accentColor : .accentColor.opacity(0.5))
            .font(.title2.weight(.medium))
            .scaleEffect(isAnimationShowAnswer ? 1.05 : 1)
            .rotation3DEffect(.degrees(isAnimationShowAnswer ? 0 : 90), axis: (x: 100, y: 1, z: 0), anchor: .leading, anchorZ: 10)
            .animation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true), value: isAnimationShowAnswer)
            .onAppear {
                isAnimationShowAnswer = true
            }
            .onDisappear {
                isAnimationShowAnswer = false
            }
            .onTapGesture {
                vm.toggleAnswer()
            }
    }

    @ViewBuilder
    var answerView: some View {
        HStack {
            Spacer()
            Text(vm.selectedQuestion?.answer ?? "")
                .font(sizeClass == .compact ? .title3.weight(.semibold) : .title2.weight(.medium))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .onTapGesture {
            vm.toggleAnswer()
        }
        .transition(.scale)
    }

    @ViewBuilder
    var answersAndDetails: some View {
        if vm.isShowingAnswer {
            answerView
        } else {
            tapToAnswerView
        }
    }

    var controls: some View {
        HStack(spacing: sizeClass == .compact ? 26 : 48) {
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

            if let question = vm.selectedQuestion {
                NavigationLink {
                    AddOrEditQuestionView(vm: .init(viewContext: PersistenceController.shared.container.viewContext, level: vm.level, question: question, isInEditMode: true))
                } label: {
                    Image(systemName: "pencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.accentColor)
                }
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

            Button {
                withAnimation {
                    vm.copyQuestionToClipboard()
                }
            } label: {
                Image(systemName: "doc.on.doc")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.orange)
            }
            Spacer()
        }
    }

    func attributedText(text: String, textRange: String) -> AttributedString {
        var text = AttributedString(text)
        if let range = text.range(of: textRange) {
            text[range].foregroundColor = .purple
            text[range].font = .title2.bold()
        }
        return text
    }
}

struct NotAnyToReviewView: View {
    @State
    private var isAnimating = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64, alignment: .center)
                .foregroundStyle(.white, Color("green_light"))
                .scaleEffect(isAnimating ? 1 : 0.8)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color("green_light").opacity(0.5), lineWidth: 16)
                        .scaleEffect(isAnimating ? 1.1 : 0.8)
                )
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
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
        let level = (LeitnerView_Previews.leitner.levels).filter { $0.level == 1 }.first
        ReviewView(vm: ReviewViewModel(viewContext: PersistenceController.preview.container.viewContext, level: level!))
            .preferredColorScheme(.light)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
