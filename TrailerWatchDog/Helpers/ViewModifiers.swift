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

extension View {
    func headerShadowRectangle() -> some View {
        self.modifier(HeaderShadowRectangle())
    }
}
