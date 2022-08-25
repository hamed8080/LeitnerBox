//
//  StatisticsView.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    
    @ObservedObject
    var vm:StatisticsViewModel
    
    var body: some View {
        
        ScrollView {
            VStack{
                Picker("Timeframe", selection: $vm.timeframe) {
                    Label("Week", systemImage: "calendar")
                        .tag(Timeframe.week)
                    
                    Label("Month", systemImage: "calendar")
                        .tag(Timeframe.month)
                    
                    Label("Year", systemImage: "calendar")
                        .tag(Timeframe.year)
                }
                .pickerStyle(.segmented)
                .padding([.leading, .trailing, .bottom], 10)
                
                Chart{
                    ForEach(vm.plaotsForSelectedTime, id:\.self){ dayStatic in
                        BarMark(
                            x: .value("Day", dayStatic.date, unit: .day),
                            y: .value("Count",dayStatic.count)
                        )
                        .cornerRadius(12 ,style: .circular)
                        .foregroundStyle(dayStatic.isPassed ? Color.accentColor.gradient : Color.red.gradient)
                        .foregroundStyle(by: .value("IsPassed", "\(dayStatic.isPassed ? "isPassed" : "Failed" )" ))
                    }
                }
                .cornerRadius(12)
                .chartLegend(position:.top)
                .chartLegend(.visible)
                .frame(height: 300)
                .padding()
                
                
                PercentageView(
                    percent: $vm.percentage,
                    bottomText: Text("Total Percent")
                        .font(.title3.bold())
                        .foregroundColor(.gray)
                )
                .frame(width:320, height: 320)
                .onAppear{
                    withAnimation {
                        if let leitner = vm.statistics.first?.question?.level?.leitner{
                            vm.percentage = leitner.succcessPercentage
                        }
                    }
                }
            }
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    
    struct Preview: View{
        
        @ObservedObject
        var vm = StatisticsViewModel(isPreview: true)
        var body: some View{
            StatisticsView(vm: vm)
        }
    }
    
    static var previews: some View {
        NavigationStack{
            Preview()
        }
    }
}