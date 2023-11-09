//
//  NavigationManager.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation
import SwiftUI

protocol PathItem: Hashable, Codable { }

final class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    
    func append<T: PathItem>(_ pathItem: T) {
        path.append(pathItem)
    }
    
    func removeLast(_ k: Int = 1) {
        path.removeLast(k)
    }
    
    func resetCurrentPath() {
        path = NavigationPath()
    }
}

struct SettingPathItem: PathItem { }
struct TerminalPathItem: PathItem { }
struct HistoryPathItem: PathItem { }
