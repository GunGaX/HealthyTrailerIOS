//
//  NotificationSoundPickerView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 11.11.2023.
//

import SwiftUI

enum NotificationSound: CaseIterable {
    case chime, trailerWatchDog
    
    var title: String {
        switch self {
        case .chime: "Chime"
        case .trailerWatchDog: "TrailerWatchdog"
        }
    }
}

struct NotificationSoundPickerView: View {
    @Binding var selectedSound: NotificationSound
    
    var body: some View {
        VStack(spacing: 18) {
            ForEach(NotificationSound.allCases, id: \.self) { item in
                caseView(item: item)
            }
        }
    }
    
    @ViewBuilder
    private func caseView(item: NotificationSound) -> some View {
        let isSelected = selectedSound == item
        Button {
            selectedSound = item
        } label: {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 3)
                        .foregroundStyle(isSelected ? Color.mainBlue : Color.mainGrey)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .foregroundStyle(Color.mainBlue)
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text(item.title)
                    .foregroundStyle(Color.textDark)
                    .font(isSelected ? .roboto500 : .roboto400, size: 16)
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NotificationSoundPickerView(selectedSound: .constant(.chime))
        .padding()
}
