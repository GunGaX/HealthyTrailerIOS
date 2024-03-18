//
//  TireTemperaturePlotView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI
import Charts

struct TireTemperaturePlotView: View {
    var data: [Double]
    
    var foregroundColor: Color
    
    var maxValue: Double {
        return data.max() ?? 100.0
    }
    
    var minValue: Double {
        return data.min() ?? 0.0
    }
    
    var body: some View {
        Chart {
            ForEach(data.indices, id: \.self) { index in
                let value = data[index]
                LineMark(x: .value("time", index), y: .value("value", value))
                    .foregroundStyle(foregroundColor)
                    .interpolationMethod(.stepCenter)
                
                if index == data.indices.last {
                    PointMark(
                        x: .value("time", index),
                        y: .value("value", value)
                    )
                    .foregroundStyle(foregroundColor)
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
    TireTemperaturePlotView(data: [56.1, 72.5, 74.5, 24.2, 26.1, 34.1, 36.5], foregroundColor: Color.mainGreen)
        .frame(height: 100)
        .padding()
}
