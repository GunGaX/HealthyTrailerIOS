//
//  MainRedButtonStyle.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 06.03.2024.
//

import SwiftUI

struct MainRedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.roboto500, size: 14)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background (
                ZStack {
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.mainRed)
                }
            )
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

extension ButtonStyle where Self == MainRedButtonStyle {
    static var mainRedButton: MainRedButtonStyle { MainRedButtonStyle() }
}

#Preview {
    Button(action: {}) {
        Text("Try to connect")
    }
    .buttonStyle(.mainRedButton)
    .padding(.horizontal)
}
