//
// LevelRow.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import SwiftUI

struct LevelRow: View {
    var levelRowData: LevelRowData
    let container: ObjectsContainer
    @Environment(\.avSpeechSynthesisVoice) var voiceSpeech: AVSpeechSynthesisVoice
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext

    var body: some View {
        LevelRowReview(levelRowData: levelRowData, container: container)
            .environmentObject(
                ReviewViewModel(viewContext: context,
                                levelValue: levelRowData.level.level,
                                leitnerId: Int64(levelRowData.leitnerId),
                                voiceSpeech: voiceSpeech)
            )
    }
}

struct LevelRowReview: View {
    var levelRowData: LevelRowData
    let container: ObjectsContainer
    @EnvironmentObject var viewModel: ReviewViewModel

    var body: some View {
        NavigationLink {
            ReviewView(viewModel: viewModel)
                .environmentObject(container)
        } label: {
            LevelRowLableMutableView(levelRowData: levelRowData)
        }
    }
}

struct LevelRowLableMutableView: View {
    let levelRowData: LevelRowData
    @State var reviewableCount: Int = 0
    @Environment(\.horizontalSizeClass) var sizeClass
    @State var showDaysAfterDialog: Bool = false

    var body: some View {
        HStack {
            HStack {
                Text(verbatim: "\(levelRowData.level.level)")
                    .foregroundColor(.white)
                    .font(.title.weight(.bold))
                    .frame(width: 48, height: 48)
                    .accessibilityIdentifier("levelRow")
                    .background(
                        Circle()
                            .fill(Color.blue)
                    )

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.accentColor)
                    Text(verbatim: "\(levelRowData.favCount)")
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack {
                HStack(spacing: 0) {
                    Text(verbatim: "\(reviewableCount)")
                        .foregroundColor(.accentColor.opacity(1))
                    Spacer()
                    Text(verbatim: "\(levelRowData.totalCountInsideLevel)")
                        .foregroundColor(.primary.opacity(1))
                }
                .font(.footnote)

                ProgressView(
                    value: Float(reviewableCount),
                    total: Float(levelRowData.totalCountInsideLevel)
                )
                .progressViewStyle(.linear)
                .animation(.easeOut(duration: 0.3), value: reviewableCount)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
                        reviewableCount = levelRowData.reviewableCount
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
        .popover(isPresented: $showDaysAfterDialog) {
            LevelConfigView(level: levelRowData.level)
                .frame(width: 640, height: 120)
        }
    }
}

struct LevelConfigView: View {
    @StateObject var level: Level
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext

    var body: some View {
        VStack(spacing: 8) {
            Text(verbatim: "Level \(level.level)")
                .font(.title2.bold())
                .foregroundColor(.accentColor)
            Stepper(value: $level.daysToRecommend, in: 1 ... 365, step: 1) {
                Text(verbatim: "Days to recommend: \(level.daysToRecommend)")
            }.onChange(of: level.daysToRecommend) { value in
                level.daysToRecommend = Int32(value)
                PersistenceController.saveDB(viewContext: context)
            }
        }
        .padding()
        .cornerRadius(16)
    }
}

struct LevelRow_Previews: PreviewProvider {
    struct Preview: View {
        static let leitner = PersistenceController.shared.generateAndFillLeitner().first!
        static let context = PersistenceController.shared.viewContext
        var leitnerViewModel: LeitnerViewModel {
            _ = PersistenceController.shared.generateAndFillLeitner()
            return LeitnerViewModel(viewContext: PersistenceController.shared.viewContext)
        }

        var body: some View {
            LevelRow(levelRowData: .init(leitnerId: 1, level: Level(), favCount: 25, reviewableCount: 50, totalCountInsideLevel: 100),
                     container: ObjectsContainer(context: Preview.context, leitner: Preview.leitner, leitnerVM: leitnerViewModel))
        }
    }

    static var previews: some View {
        Preview()
            .environment(\.avSpeechSynthesisVoice, EnvironmentValues().avSpeechSynthesisVoice)
            .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
    }
}
