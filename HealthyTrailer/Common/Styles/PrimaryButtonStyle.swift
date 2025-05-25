//
//  PrimaryButtonStyle.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 11.05.2025.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    var backgroundColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        
        configuration.label
            .font(.roboto500, size: 18)
            .foregroundStyle(isEnabled ? Color.green11 : Color.grayBA)
            .frame(maxWidth: .infinity, minHeight: 48)
            .contentShape(Rectangle())
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEnabled ? Color.green11 : Color.grayBA, lineWidth: 1)
            )
            .animation(.easeIn(duration: 0.16), value: pressed)
    }
}

struct SocialLoginButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        
        configuration.label
            .font(.roboto500, size: 18)
            .foregroundStyle(Color.green11)
            .frame(maxWidth: .infinity, minHeight: 48)
            .contentShape(Rectangle())
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green11, lineWidth: 1)
            )
            .animation(.easeIn(duration: 0.16), value: pressed)
    }
}

struct PrimaryWithBackgroundButtonStyle: ButtonStyle {
    var disabled = false
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        
        configuration.label
            .font(.roboto500, size: 18)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 48)
            .contentShape(Rectangle())
            .background(disabled ? Color.grayBA : Color.green11)
            .clipToRoundedRect(cornerRadius: 12)
            .animation(.easeIn(duration: 0.16), value: pressed)
    }
}

struct SkipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        configuration.label
            .font(.roboto500, size: 18)
            .foregroundStyle(Color.blue07)
            .frame(maxWidth: .infinity, minHeight: 48)
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue07, lineWidth: 1)
            )
            .animation(.easeIn(duration: 0.16), value: pressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }
    static var primaryWithBackground: PrimaryWithBackgroundButtonStyle {
        PrimaryWithBackgroundButtonStyle()
    }
    static var socialLogin: SocialLoginButtonStyle {
        SocialLoginButtonStyle()
    }
}

extension View {
    func clipToRoundedRect(cornerRadius: CGFloat) -> some View {
        self.clipShape(
            RoundedRectangle(cornerRadius: cornerRadius)
        )
    }
}
