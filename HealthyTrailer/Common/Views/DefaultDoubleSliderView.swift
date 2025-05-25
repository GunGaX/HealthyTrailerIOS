//
//  DefaultDoubleSliderView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 11.11.2023.
//

import SwiftUI

struct DefaultDoubleSliderView: View {
    @Binding var firstValue: Double
    @Binding var secondValue: Double
    @Binding var selectedPreassureType: PreasureType
    @State var lastCoordinateFirstValue: CGFloat = 70
    @State var lastCoordinateSecondValue: CGFloat = 30
    
    let titleText: String
    let minValue: Double
    let maxValue: Double
    
    var minBound: Double {
        switch selectedPreassureType {
        case .kpa: return minValue
        case .bar: return minValue.fromKpaToBar()
        case .psi: return minValue.fromKpaToPsi()
        }
    }
    
    var maxBound: Double {
        switch selectedPreassureType {
        case .kpa: return maxValue
        case .bar: return maxValue.fromKpaToBar()
        case .psi: return maxValue.fromKpaToPsi()
        }
    }
    
    var fromActualValue: Double {
        switch selectedPreassureType {
        case .kpa: return firstValue
        case .bar: return firstValue.fromKpaToBar()
        case .psi: return firstValue.fromKpaToPsi()
        }
    }
    
    var toActualValue: Double {
        switch selectedPreassureType {
        case .kpa: return secondValue
        case .bar: return secondValue.fromKpaToBar()
        case .psi: return secondValue.fromKpaToPsi()
        }
    }
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                title
                Spacer()
            }
            actualSlider
            bottomLegend
                .padding(.top, 10)
        }
        .onChange(of: firstValue) { _ in
            valuesChanged()
        }
        .onChange(of: secondValue) { _ in
            valuesChanged()
        }
    }
    
    private var actualSlider: some View {
        GeometryReader { gr in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.secondaryGrey)
                    .frame(height: 4)
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.mainBlue)
                    .offset(x: gr.size.width * CGFloat((firstValue - minValue) / (maxValue - minValue)))
                    .frame(width: gr.size.width * CGFloat((secondValue - firstValue) / (maxValue - minValue)), height: 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Circle()
                        .foregroundColor(Color.mainBlue)
                        .frame(width: 20, height: 20)
                        .offset(x: gr.size.width * CGFloat((firstValue - minValue) / (maxValue - minValue)) - 10)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if (abs(v.translation.width) < 0.1) {
                                        self.lastCoordinateFirstValue = self.firstValue
                                    }
                                    let newValue = min(max(minValue, self.lastCoordinateFirstValue + Double(v.translation.width) / Double(gr.size.width) * (maxValue - minValue )), maxValue)
                                    self.firstValue = newValue
                                }
                        )
                    Spacer()
                }
                HStack {
                    Circle()
                        .foregroundColor(Color.mainBlue)
                        .frame(width: 20, height: 20)
                        .offset(x: gr.size.width * CGFloat((secondValue - minValue) / (maxValue - minValue)) - 10)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if (abs(v.translation.width) < 0.1) {
                                        self.lastCoordinateSecondValue = self.secondValue
                                    }
                                    let newValue = min(max(minValue, self.lastCoordinateSecondValue + Double(v.translation.width) / Double(gr.size.width) * (maxValue - minValue)), maxValue)
                                    self.secondValue = newValue
                                }
                        )
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    private var title: some View {
        let from = fromActualValue.formattedToOneDecimalPlace()
        let to = toActualValue.formattedToOneDecimalPlace()
        let localizedFormat = NSLocalizedString("PressureRangeFormat", comment: "")
        let localizedTitle = NSLocalizedString(titleText, comment: "")
        let result = String(format: localizedFormat, localizedTitle, from, selectedPreassureType.measureMark, to, selectedPreassureType.measureMark)
        Text(result)
            .foregroundStyle(Color.textDark)
            .font(.roboto500, size: 16)
            .multilineTextAlignment(.leading)
    }
    
    private var bottomLegend: some View {
        HStack {
            Text("\(minBound.formattedToOneDecimalPlace()) \(selectedPreassureType.measureMark)")
            Spacer()
            Text("\(maxBound.formattedToOneDecimalPlace()) \(selectedPreassureType.measureMark)")
        }
        .font(.roboto500, size: 16)
        .foregroundStyle(Color.mainGrey)
    }
    
    private func valuesChanged() {
        if firstValue > secondValue {
            let tempValue = firstValue
            firstValue = secondValue
            secondValue = tempValue
        }
    }
}


#Preview {
    DefaultDoubleSliderView(firstValue: .constant(0.3), secondValue: .constant(0.7), selectedPreassureType: .constant(.bar), titleText: "MAX temperature", minValue: 0, maxValue: 160)
        .frame(height: 20)
        .padding(.horizontal)
}
