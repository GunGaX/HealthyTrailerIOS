//
//  ChartScreen.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 18.05.2025.
//

import SwiftUI
import Charts

struct ChartScreen: View {
    @StateObject var viewModel: ChartViewModel = ChartViewModel()
    
    let sensorId: String
    
    var body: some View {
        VStack {
            Picker("Data Type", selection: $viewModel.selectedType) {
                ForEach(DataType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding()
            
            if viewModel.filteredData.isEmpty {
                Text("No data")
                    .frame(maxHeight: .infinity)
            } else {
                chartView
            }
        }
        .onAppear {
            viewModel.getDataForSensor(sensorId: sensorId)
        }
    }
    
    private var chartView: some View {
        Chart(viewModel.filteredData) { item in
            LineMark(
                x: .value("Hour", item.date),
                y: .value(viewModel.selectedType.rawValue, viewModel.selectedType == .temperature ? item.temperature : item.pressure)
            )
            .foregroundStyle(Color.green11)
            .lineStyle(StrokeStyle(lineWidth: 3))
        }
        .chartXAxis {
            AxisMarks(values: stride(from: 0, through: 23, by: 4).map { hour in
                Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: viewModel.selectedDate)!
            }) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
            }
        }
        .chartXScale(domain: Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: viewModel.selectedDate)!
                     ...
                     Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: viewModel.selectedDate)!)
        .chartYAxisLabel(viewModel.selectedType == .temperature ? "F" : "kpa")
        .padding()
    }
}
