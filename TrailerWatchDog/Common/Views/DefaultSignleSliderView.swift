//
//  DefaultSignleSliderView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct DefaultSignleSliderView: View {
    @Binding var value: Double
    @Binding var selectedTemperatureType: TemperatureType
    @State var lastCoordinateValue: CGFloat = 50
    
    let titleText: String
    let minValue: Double
    let maxValue: Double
    
    var minBound: Double {
        switch selectedTemperatureType {
        case .fahrenheit: return self.minValue
        case .celsius: return self.minValue.fromFahrenheitToCelsius() < 0 ? 0 : self.minValue.fromFahrenheitToCelsius()
        }
    }
    
    var maxBound: Double {
        switch selectedTemperatureType {
        case .fahrenheit: return self.maxValue
        case .celsius: return self.maxValue.fromFahrenheitToCelsius()
        }
    }
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                title
                Spacer()
                bubleValue
            }
            actualSlider
            bottomLegend
                .padding(.top, 10)
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
                    .frame(width: gr.size.width * value, height: 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Circle()
                        .foregroundColor(Color.mainBlue)
                        .frame(width: 20, height: 20)
                        .offset(x: gr.size.width * value - 10)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if (abs(v.translation.width) < 0.1) {
                                        self.lastCoordinateValue = self.value
                                    }
                                    if v.translation.width > 0 {
                                        self.value = min(1.0, self.lastCoordinateValue + v.translation.width / gr.size.width)
                                    } else {
                                        self.value = max(0.0, self.lastCoordinateValue + v.translation.width / gr.size.width)
                                    }
                                    
                                }
                        )
                    Spacer()
                }
            }
        }
    }
    
    private var title: some View {
        Text(titleText)
            .foregroundStyle(Color.textDark)
            .font(.roboto500, size: 16)
            .multilineTextAlignment(.leading)
    }
    
    private var bubleValue: some View {
        HStack(alignment: .bottom, spacing: 4) {
            Text("\(Double(value * maxBound).formattedToOneDecimalPlace())")
                .foregroundStyle(Color.mainBlue)
                .font(.roboto700, size: 20)
            
            Text(selectedTemperatureType.measureMark)
                .foregroundStyle(Color.mainBlue)
                .font(.roboto700, size: 12)
                .padding(.bottom, 3)
        }
        .padding(.vertical, 16)
        .frame(width: 110)
        .background(
            Capsule()
                .foregroundStyle(Color.lightBlue)
        )
    }
    
    private var bottomLegend: some View {
        HStack {
            Text("\(minBound.formattedToOneDecimalPlace()) \(selectedTemperatureType.measureMark)")
            Spacer()
            Text("\(maxBound.formattedToOneDecimalPlace()) \(selectedTemperatureType.measureMark)")
        }
        .font(.roboto500, size: 16)
        .foregroundStyle(Color.mainGrey)
    }
}


#Preview {
    DefaultSignleSliderView(value: .constant(0.5), selectedTemperatureType: .constant(.celsius), titleText: "MAX temperature", minValue: 0, maxValue: 160)
        .frame(height: 20)
        .padding(.horizontal)
}
