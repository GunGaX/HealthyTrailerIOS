//
//  NavigationManager.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation
import SwiftUI

enum AppState {
    case auth, welcome, allowPermissions, app
}

protocol PathItem: Hashable, Codable { }

final class NavigationManager: ObservableObject {
    @Published var appState: AppState = .auth
    @Published var path: NavigationPath = NavigationPath()
    @Published var authPath: NavigationPath = NavigationPath()
    
    func append<T: PathItem>(_ pathItem: T) {
        switch appState {
        case .auth:
            authPath.append(pathItem)
        case .welcome, .allowPermissions, .app:
            path.append(pathItem)
        }
    }
    
    func removeLast(_ k: Int = 1) {
        switch appState {
        case .auth:
            authPath.removeLast(k)
        case .welcome, .allowPermissions, .app:
            path.removeLast(k)
        }
    }
    
    func resetCurrentPath() {
        switch appState {
        case .auth:
            authPath = NavigationPath()
        case .welcome, .allowPermissions, .app:
            path = NavigationPath()
        }
    }
}

struct SettingPathItem: PathItem { }
struct TerminalPathItem: PathItem { }
struct HistoryPathItem: PathItem { }
struct FolderDetailsPathItem: PathItem { 
    let folderPath: String
}
struct LogFileDetailsPathItem: PathItem {    
    let file: HistoryFileModel
}
