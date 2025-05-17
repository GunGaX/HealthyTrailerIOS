//
//  NavigationManager.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation
import SwiftUI

enum AppState {
    case launched, welcome, allowPermissions, app
}

protocol PathItem: Hashable, Codable { }

final class NavigationManager: ObservableObject {
    @Published var appState: AppState = .launched
    @Published var path: NavigationPath = NavigationPath()
    @Published var authPath: NavigationPath = NavigationPath()
    
    func append<T: PathItem>(_ pathItem: T) {
        switch appState {
        case .launched:
            authPath.append(pathItem)
        case .welcome, .allowPermissions, .app:
            path.append(pathItem)
        }
    }
    
    func removeLast(_ k: Int = 1) {
        switch appState {
        case .launched:
            authPath.removeLast(k)
        case .welcome, .allowPermissions, .app:
            path.removeLast(k)
        }
    }
    
    func resetCurrentPath() {
        switch appState {
        case .launched:
            authPath = NavigationPath()
        case .welcome, .allowPermissions, .app:
            path = NavigationPath()
        }
    }
    
    func setupNavigationStatus() {
        let user = try? AuthManager.shared.getLoggedUser()
        
        if LocationManager.shared.checkIfAccessIsGranted() && BluetoothManager.shared.checkBluetooth() && UserDefaults.standard.integer(forKey: "axiesCount") != 0 {
            if user != nil {
                self.appState = .app
            } else {
                self.appState = .launched
            }
        } else {
            if UserDefaults.standard.integer(forKey: "axiesCount") != 0 {
                self.appState = .allowPermissions
            } else {
                self.appState = .welcome
            }
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
struct AuthViewPathItem: PathItem {
    let authType: AuthType
}
struct ResetPasswordViewPathItem: PathItem {}
