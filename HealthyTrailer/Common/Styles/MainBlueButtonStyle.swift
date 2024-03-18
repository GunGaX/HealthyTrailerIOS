//
//  MainBlueButtonStyle.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 09.11.2023.
//

import SwiftUI

struct MainBlueButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.roboto500, size: 14)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background (
                ZStack {
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.mainBlue)
                }
            )
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

extension ButtonStyle where Self == MainBlueButtonStyle {
    static var mainBlueButton: MainBlueButtonStyle { MainBlueButtonStyle() }
}

#Preview {
    Button(action: {}) {
        Text("Try to connect")
    }
    .buttonStyle(.mainBlueButton)
    .padding(.horizontal)
}
