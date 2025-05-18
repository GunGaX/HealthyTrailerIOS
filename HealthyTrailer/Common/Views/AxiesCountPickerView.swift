//
//  AxiesCountPickerView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 07.04.2024.
//

import SwiftUI

struct AxiesCountPickerView: View {
    @Binding var selectedCount: Int
    @State private var isExpanded = false
    
    let pickerOptions: [Int] = [2, 3, 4]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.lightBlue.opacity(0.75))
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(Color.mainBlue)
            
            HStack {
                Text(selectedCount.description)
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
                ForEach(pickerOptions, id: \.self) { option in
                    Text(option.description)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                selectedCount = option
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

enum VehicleType: String, CaseIterable, Identifiable {
    case car = "Car"
    case motorcycle = "Motorcycle"
    
    var id: String { rawValue }
}

struct VehicleTypePickerView: View {
    @Binding var selectedType: VehicleType
    @State private var isExpanded = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.lightBlue.opacity(0.75))
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(Color.mainBlue)
            
            HStack {
                Text(selectedType.rawValue)
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
                ForEach(VehicleType.allCases) { type in
                    Text(type.rawValue)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                selectedType = type
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
    AxiesCountPickerView(selectedCount: .constant(2))
}
