//
//  TrailerWatchDogApp.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 08.11.2023.
//

import SwiftUI

@main
struct TrailerWatchDogApp: App {
    @StateObject var navigationManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            MainScreenView()
                .environmentObject(navigationManager)
        }
    }
}
