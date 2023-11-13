//
//  ViewExtensions.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation
import SwiftUI

extension View {
    func navigationDestinations() -> some View {
        modifier(NavigationDestinationsViewModifier())
    }
}
