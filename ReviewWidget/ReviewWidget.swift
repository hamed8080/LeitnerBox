//
//  ReviewWidget.swift
//  ReviewWidget
//
//  Created by hamed on 7/22/22.
//

import WidgetKit
import SwiftUI
import Intents
import AVFoundation
import CoreData

var previewQuestion:WidgetQuestion{
    return WidgetQuestion(question: "Insomnia",
                          answer: "کم خونی",
                          tags: [.init(name:"Health"), .init(name: "Sport")],
                          detailedDescription: "Detailed answer",
                          level: 1,
                          isFavorite: true,
                          isCompleted: true)
}

struct Provider: IntentTimelineProvider {

    @AppStorage("TopQuestionsForWidget", store: UserDefaults.group)
    var topQuestionsData:Data?

    var allQuestion:[WidgetQuestion]{
        if let topQuestionsData = topQuestionsData, let questions  = try? JSONDecoder().decode([WidgetQuestion].self, from: topQuestionsData){
            return questions
        }else{
            return []
        }
    }

    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), question: previewQuestion, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry:Entry
        if context.isPreview {
            entry = SimpleEntry(date: Date(), question: previewQuestion, configuration: configuration)
        }else{
            let first = allQuestion.first ?? previewQuestion
            entry = SimpleEntry(date: Date(), question: first, configuration: configuration)
        }
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        var currentDate = Date()
        for index in 1..<allQuestion.count{
            let question = allQuestion[index]
            let entryDate = Calendar.current.date(byAdding: .minute, value: index + 10, to: currentDate)!
            currentDate = entryDate
            let entry = SimpleEntry(date: entryDate, question: question, configuration: configuration)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)

        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let question:WidgetQuestion
    let configuration: ConfigurationIntent
}

struct ReviewWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var widgetFamily

    @ViewBuilder
    var body: some View {
        switch widgetFamily{
        case .systemExtraLarge:
            large
        case .systemSmall:
            medium
        case .systemMedium:
            medium
        case .systemLarge:
            large
        @unknown default:
            medium
        }
    }

    var medium: some View{
        ZStack{
            Color("WidgetBackground")
            VStack(alignment:.leading, spacing:4){
                HStack{
                    Image(systemName: "square.stack.3d.forward.dottedline.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .scaledToFit()
                        .foregroundColor(.white)
                        .padding([.bottom], 4)
                    Text("Level: \(entry.question.level)")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.gray)

                    Spacer()
                }
                Text(entry.question.question ?? "")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(entry.question.detailedDescription ?? "")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)

                Text(entry.question.answer ?? "")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                Spacer()
           }
            .padding()
        }
    }

    var large: some View {
        ZStack{
            Color("WidgetBackground")

            VStack{
                HStack{
                    Image(systemName: "square.stack.3d.forward.dottedline.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .scaledToFit()
                        .foregroundColor(.white)
                    Text("It will update approximately every 10 minutes.")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                }
                Spacer()
            }.padding()

            HStack(spacing:24){
                if entry.question.isCompleted {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .scaledToFit()
                        .foregroundColor(.yellow)
                }

                VStack(alignment:.leading, spacing:16){
                    Text(entry.question.question ?? "")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(entry.question.detailedDescription ?? "")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)

                    Text(entry.question.answer ?? "")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)

                    Text("Level: \(entry.question.level)")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)

                    let colors:[Color] = [.mint, .red, .brown, .orange, .cyan]
                    HStack{
                        ForEach(entry.question.tags) { tag in
                            Text(tag.name)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(colors.randomElement())
                                .cornerRadius(12)
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

@main
struct ReviewWidget: Widget {
    let kind: String = "ReviewWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            ReviewWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Review words")
        .description("With this widget you could review words randomly in a specific leitner")
        .supportedFamilies([.systemExtraLarge, .systemLarge, .systemMedium])
    }
}

struct ReviewWidget_Previews: PreviewProvider {
    static var previews: some View {
        ReviewWidgetEntryView(entry: SimpleEntry(date: Date(), question: previewQuestion, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
