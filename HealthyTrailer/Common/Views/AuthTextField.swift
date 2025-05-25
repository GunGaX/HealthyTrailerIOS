//
//  AuthTextField.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 11.05.2025.
//


import SwiftUI

struct AuthTextField: View {
    @Binding var text: String
    public var placeholder: String
    public var isSecure: Bool
    
    let isFocused: Bool
    @State private var isVisible = false
    
    var body: some View {
        Group {
            if isSecure, !isVisible {
                SecureField("", text: $text)
                    .foregroundStyle(.black)
                    .autocapitalization(.none)
            } else {
                TextField("", text: $text)
                    .foregroundStyle(.black)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
        .frame(height: 58)
        .overlay(toggleVisibleButton)
        .overlay(placeholderView)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.grayF3)
        )
    }
    
    @ViewBuilder
    private var placeholderView: some View {
        if text.isEmpty {
            Text(.init(placeholder))
                .font(.roboto400, size: 18)
                .foregroundStyle(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .allowsHitTesting(false)
        }
    }
    
    @ViewBuilder
    private var toggleVisibleButton: some View {
        let icon = isVisible ? Image("eyeOn") : Image("eyeOff")
        if isSecure {
            Button {
                isVisible.toggle()
            } label: {
                icon
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(Color.gray)
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
