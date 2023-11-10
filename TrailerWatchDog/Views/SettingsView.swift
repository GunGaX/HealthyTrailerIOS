//
//  SettingsView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            SecondaryHeaderView(titleText: "Settings")
            
            ScrollView {
                
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    SettingsView()
        .environmentObject(NavigationManager())
}
