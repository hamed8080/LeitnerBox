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
    @EnvironmentObject var searchVM: SearchViewModel
    @State var showDaysAfterDialog: Bool = false
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.avSpeechSynthesisVoice) var voiceSpeech: AVSpeechSynthesisVoice
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @State var reviewableCount: Int = 0

    var body: some View {
        NavigationLink {
            LazyView(
                ReviewView(viewModel: ReviewViewModel(viewContext: context, levelValue: levelRowData.level.level, leitnerId: Int64(levelRowData.leitnerId), voiceSpeech: voiceSpeech))
                    .environmentObject(searchVM)
            )
        } label: {
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
                    .animation(.easeInOut, value: reviewableCount)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
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
        }
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
    static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
    static var previews: some View {
        LevelRow(levelRowData: .init(leitnerId: 1, level: Level(), favCount: 25, reviewableCount: 50, totalCountInsideLevel: 100))
            .environment(\.avSpeechSynthesisVoice, EnvironmentValues().avSpeechSynthesisVoice)
            .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
    }
}
