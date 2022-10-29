//
// ReviewView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import CoreData
import SwiftUI
import AVFoundation

struct ReviewView: View {
    @EnvironmentObject
    var vm: ReviewViewModel

    @State
    private var isAnimationShowAnswer = false

    @Environment(\.horizontalSizeClass)
    var sizeClass

    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext

    @Environment(\.avSpeechSynthesisVoice)
    var voiceSpeech: AVSpeechSynthesisVoice

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
                    ToolbarNavigation(title: "Add Item", systemImageName: "plus.square") {
                        LazyView(
                            AddOrEditQuestionView(
                                vm: .init(viewContext: context, level: insertQuestion.level!, question: insertQuestion, isInEditMode: false),
                                synonymsVM: SynonymViewModel(viewContext: context, question: insertQuestion),
                                tagVM: TagViewModel(viewContext: context, leitner: vm.level.leitner!)
                            )
                        )
                    }
                    .keyboardShortcut("a", modifiers: [.command, .option])

                    if let leitner = vm.level.leitner {
                        ToolbarNavigation(title: "Search View", systemImageName: "square.text.square") {
                            SearchView()
                                .environmentObject(SearchViewModel(viewContext: context, leitner: leitner, voiceSpeech: voiceSpeech))
                        }
                        .keyboardShortcut("s", modifiers: [.command, .option])
                    }
                }
            }
            .customDialog(isShowing: $vm.showDelete, content: {
                deleteDialog
            })
            .onDisappear {
                vm.stopPronounce()
            }

        } else {
            NotAnyToReviewView()
        }
    }

    var insertQuestion: Question {
        let question = Question(context: context)
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
            .keyboardShortcut("d", modifiers: [.command])
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
            .keyboardShortcut(.return, modifiers: [.command])
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
            .keyboardShortcut(.return, modifiers: [.command, .shift])
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
            QuestionTagsView(question: selectedQuestion, viewModel: .init(viewContext: context, leitner: leitner), accessControls: [.addTag, .showTags, .removeTag])
        }
    }

    @ViewBuilder
    var synonyms: some View {
        if let question = vm.selectedQuestion {
            QuestionSynonymsView(viewModel: .init(viewContext: context, question: question), accessControls: [.addSynonym, .showSynonyms, .removeSynonym])
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
                IconButtonKeyboardShortcut(title: "Delete", systemImageName: "trash")
            }
            .reviewIconStyle(accent: false)
            .keyboardShortcut(.delete, modifiers: [.command])

            if let question = vm.selectedQuestion {
                NavigationLink {
                    AddOrEditQuestionView(
                        vm: .init(viewContext: context, level: vm.level, question: question, isInEditMode: true),
                        synonymsVM: SynonymViewModel(viewContext: context, question: question),
                        tagVM: TagViewModel(viewContext: context, leitner: vm.level.leitner!)
                    )
                } label: {
                    IconButtonKeyboardShortcut(title: "Edit", systemImageName: "pencil")
                }
                .reviewIconStyle()
                .keyboardShortcut("e", modifiers: [.command])
            }

            Button {
                withAnimation {
                    vm.toggleFavorite()
                }
            } label: {
                IconButtonKeyboardShortcut(title: "Favorite", systemImageName: vm.selectedQuestion?.favorite == true ? "star.fill" : "star")
            }
            .reviewIconStyle()
            .keyboardShortcut("f", modifiers: [.command])

            Button {
                vm.pronounce()
            } label: {
                IconButtonKeyboardShortcut(title: "Pronounce", systemImageName: "mic.fill")
            }
            .reviewIconStyle()
            .keyboardShortcut("p", modifiers: [.command])

            Button {
                withAnimation {
                    vm.copyQuestionToClipboard()
                }
            } label: {
                IconButtonKeyboardShortcut(title: "Copy To Clipbaord", systemImageName: "doc.on.doc")
            }
            .reviewIconStyle(accent: false)
            .keyboardShortcut("c", modifiers: [.command])
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

struct FinishedReviewView: View {
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

struct ReviewView_Previews: PreviewProvider {
    struct Preview: View {
        static let level = (LeitnerView_Previews.leitner.levels).filter { $0.level == 1 }.first
        @StateObject
        var vm = ReviewViewModel(viewContext: PersistenceController.previewVC, level: level!, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)
        var body: some View {
            ReviewView()
                .environment(\.managedObjectContext, PersistenceController.previewVC)
                .environment(\.avSpeechSynthesisVoice, EnvironmentValues().avSpeechSynthesisVoice)
                .environmentObject(vm)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
