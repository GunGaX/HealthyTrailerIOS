//
//  ViewModifiers.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 13.11.2023.
//

import Foundation
import SwiftUI

struct HeaderShadowRectangle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Rectangle()
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
            )
    }
}

struct AlertView: ViewModifier {
    
    @Binding public var alertStep: AlertType?
    
    func body(content: Content) -> some View { content
        .overlay(contentOverlay)
        .overlay(alert)
        .animation(.spring(), value: alertStep)
    }
    
    @ViewBuilder
    private var contentOverlay: some View {
        if alertStep != nil {
            Color.black
                .opacity(0.5)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var alert: some View {
        if let alertStep {
            
            VStack(spacing: 0) {
                switch alertStep {
                case .delete:
                    Text("Delete")
                }
            }
            .frame(width: 237, height: 276)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .transition(.opacity.combined(with: .scale(scale: 0.5)))
            
        }
    }
}

extension View {
    func headerShadowRectangle() -> some View {
        self.modifier(HeaderShadowRectangle())
    }
}
