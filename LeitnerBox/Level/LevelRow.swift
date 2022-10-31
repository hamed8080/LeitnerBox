//
// LevelRow.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import SwiftUI
import AVFoundation
import CoreData

struct LevelRow: View {
    @StateObject
    var level: Level

    @State
    var showDaysAfterDialog: Bool = false

    @Environment(\.horizontalSizeClass)
    var sizeClass

    @Environment(\.avSpeechSynthesisVoice)
    var voiceSpeech: AVSpeechSynthesisVoice

    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext

    @State
    var progress: Int = 0

    var body: some View {
        NavigationLink {
            LazyView(ReviewView(vm: ReviewViewModel(viewContext: context, level: level, voiceSpeech: voiceSpeech)))
        } label: {
            HStack {
                HStack {
                    Text(verbatim: "\(level.level)")
                        .foregroundColor(.white)
                        .font(.title.weight(.bold))
                        .frame(width: 48, height: 48)
                        .accessibilityIdentifier("levelRow")
                        .background(
                            Circle()
                                .fill(Color.blue)
                        )
                    let favCount = level.allQuestions.filter { $0.favorite == true }.count

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.accentColor)
                        Text(verbatim: "\(favCount)")
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                VStack {
                    HStack(spacing: 0) {
                        Text(verbatim: "\(level.reviewableCountInsideLevel)")
                            .foregroundColor(.accentColor.opacity(1))
                        Spacer()
                        Text(verbatim: "\(level.notCompletdCount)")
                            .foregroundColor(.primary.opacity(1))
                    }
                    .font(.footnote)

                    ProgressView(
                        value: Float(progress),
                        total: Float(level.notCompletdCount)
                    )
                    .progressViewStyle(.linear)
                    .animation(.easeInOut, value: progress)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                            progress = level.reviewableCountInsideLevel
                        }
                    }
                }
                .frame(maxWidth: sizeClass == .regular ? 192 : 128)
            }
            .contextMenu {
                Button {
                    showDaysAfterDialog.toggle()
                } label: {
                    Label("Days to recommend", systemImage: "calendar")
                }
            }
            .padding([.leading, .top, .bottom], 8)
        }
        .popover(isPresented: $showDaysAfterDialog,attachmentAnchor: .point(UnitPoint(x: 2000, y: 20)) ) {
            LevelConfigView(level: level)
        }
    }
}

struct LevelConfigView: View {
    @StateObject
    var level: Level

    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext

    var body: some View {
        Form {
            VStack(spacing: 24) {
                VStackLayout(spacing: 24) {
                    Text(verbatim: "Level \(level.level)")
                        .font(.title2.bold())

                    Stepper(value: $level.daysToRecommend, in: 1 ... 365, step: 1) {
                        Text(verbatim: "Days to recommend: \(level.daysToRecommend)")
                    }.onChange(of: level.daysToRecommend) { value in
                        level.daysToRecommend = Int32(value)
                        PersistenceController.saveDB(viewContext: context)
                    }

                }
                .padding()
                .cornerRadius(12)
                Spacer()
            }
        }
    }
}

struct LevelRow_Previews: PreviewProvider {
    static var previews: some View {
        LevelRow(level: LeitnerView_Previews.leitner.firstLevel!)
            .environment(\.avSpeechSynthesisVoice, EnvironmentValues().avSpeechSynthesisVoice)
            .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
    }
}
