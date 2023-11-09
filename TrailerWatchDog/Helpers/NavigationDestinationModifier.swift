//
//  NavigationDestinationModifier.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation
import SwiftUI

struct NavigationDestinationsViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: SettingPathItem.self) { pathItem in
                Text("Settings")
            }
            .navigationDestination(for: TerminalPathItem.self) { pathItem in
                Text("Terminal")
            }
            .navigationDestination(for: HistoryPathItem.self) { pathItem in
                Text("History")
            }
    }
}
