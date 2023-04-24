//
// StatisticsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Charts
import SwiftUI

enum ChartStyle {
    case bar
    case line
    case area
}

struct StatisticsView: View {
    @EnvironmentObject var viewModel: StatisticsViewModel
    @State var chartStyle: ChartStyle = .line

    var body: some View {
        ScrollView {
            VStack {
                Picker("Timeframe", selection: $viewModel.timeframe) {
                    Label("Week", systemImage: "calendar")
                        .tag(Timeframe.week)

                    Label("Month", systemImage: "calendar")
                        .tag(Timeframe.month)

                    Label("Year", systemImage: "calendar")
                        .tag(Timeframe.year)
                }
                .pickerStyle(.segmented)
                .padding([.leading, .trailing, .bottom], 10)
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    if viewModel.statistics.isEmpty {
                        Text("No record has been found for the selected period!")
                            .font(.title3)
                            .foregroundColor(Color.accentColor.opacity(0.5))
                    }
                    chartMark
                        .animation(.easeInOut, value: chartStyle)
                        .disabled(viewModel.isLoading)
                }
            }
        }
        .navigationTitle("Statistics")
        .onAppear {
            viewModel.load()
        }
        .onDisappear {
            viewModel.reset()
        }
        .toolbar {
            Menu {
                Button {
                    chartStyle = .line
                } label: {
                    Label("Line", systemImage: "chart.xyaxis.line")
                }

                Button {
                    chartStyle = .bar
                } label: {
                    Label("Bars", systemImage: "chart.bar.xaxis")
                }
                Button {
                    chartStyle = .area
                } label: {
                    Label("Area", systemImage: "chart.line.uptrend.xyaxis")
                }

            } label: {
                Label("Sort Type", systemImage: "chart.xyaxis.line")
            }
        }
    }

    @ViewBuilder
    var chartMark: some View {
        Chart {
            ForEach(viewModel.plottables, id: \.self) { dayStatic in
                RuleMark(y: .value("Base Per day", 200))
                    .lineStyle(.init(lineWidth: 1, lineCap: .round,
                                     lineJoin: .miter,
                                     miterLimit: 5,
                                     dash: [5],
                                     dashPhase: 5))
                    .foregroundStyle(.mint.opacity(0.2))
                if chartStyle == .area {
                    AreaMark(
                        x: .value("Day", dayStatic.date, unit: .day),
                        y: .value("Count", dayStatic.count)
                    )
                    .foregroundStyle(dayStatic.isPassed ? Color.accentColor.gradient : Color.red.gradient)
                    .foregroundStyle(by: .value("IsPassed", "\(dayStatic.isPassed ? "isPassed" : "Failed")"))
                } else if chartStyle == .bar {
                    BarMark(
                        x: .value("Day", dayStatic.date, unit: .day),
                        y: .value("Count", dayStatic.count)
                    )
                    .cornerRadius(12, style: .circular)
                    .foregroundStyle(dayStatic.isPassed ? Color.accentColor.gradient : Color.red.gradient)
                    .foregroundStyle(by: .value("IsPassed", "\(dayStatic.isPassed ? "isPassed" : "Failed")"))
                } else if chartStyle == .line {
                    LineMark(
                        x: .value("Day", dayStatic.date, unit: .day),
                        y: .value("Count", dayStatic.count)
                    )
                    .foregroundStyle(dayStatic.isPassed ? Color.accentColor.gradient : Color.red.gradient)
                    .foregroundStyle(by: .value("IsPassed", "\(dayStatic.isPassed ? "isPassed" : "Failed")"))

                    PointMark(
                        x: .value("Day", dayStatic.date, unit: .day),
                        y: .value("Count", dayStatic.count)
                    )
                    .foregroundStyle(dayStatic.isPassed ? Color.accentColor.gradient : Color.red.gradient)
                }
            }
        }
        .chartLegend(position: .bottom, alignment: .leading, spacing: 8)
        .chartForegroundStyleScale(domain: .automatic, range: [Color.accentColor, .red])
        .frame(height: 300)
        .padding()
    }
}

struct StatisticsView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject var viewModel = StatisticsViewModel(viewContext: PersistenceController.shared.viewContext)
        var body: some View {
            StatisticsView()
                .environmentObject(viewModel)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
