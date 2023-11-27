//
//  MainGreenButtonStyle.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 14.11.2023.
//

import SwiftUI

import SwiftUI

struct MainGreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.roboto700, size: 14)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background (
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.mainGreen)
                }
            )
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

extension ButtonStyle where Self == MainGreenButtonStyle {
    static var mainGreenButton: MainGreenButtonStyle { MainGreenButtonStyle() }
}

#Preview {
    Button(action: {}) {
        Text("Try to connect")
    }
    .buttonStyle(.mainGreenButton)
    .padding(.horizontal)
}
