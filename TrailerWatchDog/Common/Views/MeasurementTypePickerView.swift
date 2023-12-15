//
//  MeasurementTypePickerView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 13.11.2023.
//

import SwiftUI

enum PreasureType: CaseIterable, Codable {
    case kpa, bar, psi
    
    var title: String {
        switch self {
        case .kpa: "Kpa"
        case .bar: "Bar"
        case .psi: "Psi"
        }
    }
    
    var measureMark: String {
        switch self {
        case .kpa: "kpa"
        case .bar: "bar"
        case .psi: "psi"
        }
    }
}

enum TemperatureType: CaseIterable, Codable {
    case fahrenheit
    case celsius
    
    var title: String {
        switch self {
        case .fahrenheit: "Fahrenheit"
        case .celsius: "Celsius"
        }
    }
    
    var measureMark: String {
        switch self {
        case .fahrenheit: "°F"
        case .celsius: "°C"
        }
    }
}

struct PreassureTypePickerView: View {
    @Binding var selectedPreassureType: PreasureType
    @State private var isExpanded = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.lightBlue.opacity(0.75))
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(Color.mainBlue)
            
            HStack {
                Text(selectedPreassureType.title)
                    .foregroundStyle(Color.textDark)
                    .font(.roboto400, size: 20)
                    .frame(maxWidth: .infinity)
                expandedArrow
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
        }
        .frame(height: 50)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
        .overlay (
            expandedSection,
            alignment: .top
        )
    }
    
    private var expandedArrow: some View {
        Image(systemName: "chevron.down")
            .bold()
            .foregroundStyle(Color.textDark)
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
    }
    
    @ViewBuilder
    private var expandedSection: some View {
        if isExpanded {
            VStack(spacing: 20) {
                ForEach(PreasureType.allCases, id: \.self) { type in
                    Text(type.title)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                selectedPreassureType = type
                                isExpanded = false
                            }
                        }
                }
            }
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4)
            )
            .offset(y: 60)
        }
    }
}

struct TemperatureTypePickerView: View {
    @Binding var selectedPreassureType: TemperatureType
    @State private var isExpanded = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.lightBlue.opacity(0.75))
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(Color.mainBlue)
            
            HStack {
                Text(selectedPreassureType.title)
                    .foregroundStyle(Color.textDark)
                    .font(.roboto400, size: 20)
                    .frame(maxWidth: .infinity)
                expandedArrow
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
        }
        .frame(height: 50)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
        .overlay (
            expandedSection,
            alignment: .top
        )
    }
    
    private var expandedArrow: some View {
        Image(systemName: "chevron.down")
            .bold()
            .foregroundStyle(Color.textDark)
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
    }
    
    @ViewBuilder
    private var expandedSection: some View {
        if isExpanded {
            VStack(spacing: 20) {
                ForEach(TemperatureType.allCases, id: \.self) { type in
                    Text(type.title)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                selectedPreassureType = type
                                isExpanded = false
                            }
                        }
                }
            }
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4)
            )
            .offset(y: 60)
        }
    }
}

#Preview {
    HStack {
        PreassureTypePickerView(selectedPreassureType: .constant(.bar))
        TemperatureTypePickerView(selectedPreassureType: .constant(.celsius))
    }
    .padding()
}
