//
//  NavigationDestinationModifier.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation
import SwiftUI

struct NavigationDestinationsViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: SettingPathItem.self) { pathItem in
                SettingsView()
            }
            .navigationDestination(for: TerminalPathItem.self) { pathItem in
                TerminalView()
            }
            .navigationDestination(for: HistoryPathItem.self) { pathItem in
                LoggedHistoryView()
            }
            .navigationDestination(for: FolderDetailsPathItem.self) { pathItem in
                FolderDetailsView(folderPath: pathItem.folderPath)
            }
            .navigationDestination(for: LogFileDetailsPathItem.self) { pathItem in
                LogFileDetailsView(file: pathItem.file)
            }
            .navigationDestination(for: AuthViewPathItem.self) { pathItem in
                AuthView(authType: pathItem.authType)
            }
            .navigationDestination(for: ResetPasswordViewPathItem.self) { pathItem in
                ResetPasswordView()
            }
    }
}
