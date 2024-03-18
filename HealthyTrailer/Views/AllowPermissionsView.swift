//
//  AllowPermissionsView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 14.11.2023.
//

import SwiftUI

struct AllowPermissionsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 30) {
            desriptionText
            openSettingsButton
        }
    }
    
    private var desriptionText: some View {
        Text("App needs to allow Location Permission to continue")
            .fontWeight(.regular)
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.textDark)
            .font(.roboto300, size: 18)
    }
    
    private var openSettingsButton: some View {
        Button {
            settingsOpener()
        } label: {
            Text("Open settings")
        }
        .buttonStyle(.mainGreenButton)
    }
    
    private func settingsOpener(){
        if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
            if UIApplication.shared.canOpenURL(appSettings) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(appSettings)
                }
            }
        }
    }
}

#Preview {
    AllowPermissionsView()
        .environmentObject(NavigationManager())
}
