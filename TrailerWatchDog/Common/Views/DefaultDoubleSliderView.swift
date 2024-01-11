//
//  DefaultDoubleSliderView.swift
//  TrailerWatchDog
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
        case .kpa: minValue.fromPsiToKpa()
        case .bar: minValue.fromPsiToBar()
        case .psi: minValue
        }
    }
    
    var maxBound: Double {
        switch selectedPreassureType {
        case .kpa: maxValue.fromPsiToKpa()
        case .bar: maxValue.fromPsiToBar()
        case .psi: maxValue
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
                    .offset(x: gr.size.width * firstValue)
                    .frame(width: gr.size.width * abs(secondValue - firstValue), height: 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Circle()
                        .foregroundColor(Color.mainBlue)
                        .frame(width: 20, height: 20)
                        .offset(x: gr.size.width * firstValue - 10)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if (abs(v.translation.width) < 0.1) {
                                        self.lastCoordinateFirstValue = self.firstValue
                                    }
                                    if v.translation.width > 0 {
                                        self.firstValue = min(1.0, self.lastCoordinateFirstValue + v.translation.width / gr.size.width)
                                    } else {
                                        self.firstValue = max(0.0, self.lastCoordinateFirstValue + v.translation.width / gr.size.width)
                                    }
                                    
                                }
                        )
                    Spacer()
                }
                HStack {
                    Circle()
                        .foregroundColor(Color.mainBlue)
                        .frame(width: 20, height: 20)
                        .offset(x: gr.size.width * secondValue - 10)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if (abs(v.translation.width) < 0.1) {
                                        self.lastCoordinateSecondValue = self.secondValue
                                    }
                                    if v.translation.width > 0 {
                                        self.secondValue = min(1.0, self.lastCoordinateSecondValue + v.translation.width / gr.size.width)
                                    } else {
                                        self.secondValue = max(0.0, self.lastCoordinateSecondValue + v.translation.width / gr.size.width)
                                    }
                                    
                                }
                        )
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    private var title: some View {
        let from = ((maxBound - minBound) * firstValue + minBound).formattedToOneDecimalPlace()
        let to = ((maxBound - minBound) * secondValue + minBound).formattedToOneDecimalPlace()
        Text("\(titleText) \(from) \(selectedPreassureType.measureMark) to \(to) \(selectedPreassureType.measureMark)")
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
