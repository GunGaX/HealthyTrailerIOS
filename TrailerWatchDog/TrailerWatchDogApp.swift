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
    @StateObject private var viewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
//            if bluetoothAccess {
//                rootView()
//            } else {
//                grandAccessView
//            }
            RootView()
                .environmentObject(navigationManager)
                .environmentObject(viewModel)
                .preferredColorScheme(.light)
                .onAppear {
                    if LocationManager.shared.checkIfAccessIsGranted() && BluetoothManager.shared.checkBluetooth() {
                        navigationManager.appState = .app
                    }
                }
        }
    }
}
