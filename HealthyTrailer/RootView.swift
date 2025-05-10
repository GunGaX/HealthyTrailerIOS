//
//  RootView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 14.11.2023.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject var locationManager = LocationManager.shared
    @StateObject var bluetoothManager = BluetoothManager.shared
    
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                switch navigationManager.appState {
                case .launched: UserTypeView()
                case .welcome: WelcomeView()
                case .allowPermissions: AllowPermissionsView()
                case .app: MainScreenView()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if locationManager.checkIfAccessIsGranted() && bluetoothManager.checkBluetooth() {
//                    navigationManager.appState = .app
                    isLoading = false
                } else {
                    isLoading = false
                }
            }
        }
        .onChange(of: bluetoothManager.bluetoothEnabled) { _ in
            if bluetoothManager.checkBluetooth() {
                locationPermissionSetup()
            }
        }
    }
    
    private func locationPermissionSetup() {
        if locationManager.checkIfAccessIsGranted() {
            return
        } else {
            locationManager.requestAuthorisation()
        }
    }
}

#Preview {
    RootView()
}
