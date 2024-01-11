//
//  TireTemperaturePlotView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI
import Charts

struct TireTemperaturePlotView: View {
    let data: [Double]
    
    var maxValue: Double {
        return data.reduce(0, { max($0, $1) })
    }
    
    var minValue: Double {
        return data.reduce(0, { min($0, $1) })
    }
    
    var body: some View {
        Chart {
            ForEach(data.indices, id: \.self) { index in
                let value = data[index]
                LineMark(x: .value("time", index), y: .value("value", value))
                    .foregroundStyle(Color.mainGreen)
                    .interpolationMethod(.catmullRom)
                
                if index == data.indices.last {
                    PointMark(
                        x: .value("time", index),
                        y: .value("value", value)
                    )
                    .foregroundStyle(Color.mainGreen)
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
    TireTemperaturePlotView(data: [56.1, 72.5, 74.5, 24.2, 26.1, 34.1, 36.5])
        .frame(height: 100)
        .padding()
}
