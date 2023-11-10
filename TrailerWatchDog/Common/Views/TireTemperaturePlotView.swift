//
//  TireTemperaturePlotView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI
import Charts

struct TireTemperaturePlotView: View {
    let data: [ChartData]
    
    var maxValue: Double {
        return data.reduce(-10000, { max($0, $1.value) })
    }
    
    var minValue: Double {
        return data.reduce(1000, { min($0, $1.value) })
    }
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                LineMark(x: .value("time", item.time), y: .value("value", item.value))
                    .foregroundStyle(Color.mainGreen)
                    .interpolationMethod(.catmullRom)
                
                if item == data.last {
                    PointMark(
                        x: .value("time", item.time),
                        y: .value("value", item.value)
                    )
                    .foregroundStyle(Color.black)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .chartYScale(domain: minValue...maxValue)
        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
        
    }
}

#Preview {
    TireTemperaturePlotView(data: ChartData.mockArray)
        .frame(height: 100)
        .padding()
}
