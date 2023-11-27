//
//  NavigationManager.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation
import SwiftUI

enum AppState {
    case welcome, allowPermissions, app
}

protocol PathItem: Hashable, Codable { }

final class NavigationManager: ObservableObject {
    @Published var appState: AppState = .welcome
    @Published var path: NavigationPath = NavigationPath()
    
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
