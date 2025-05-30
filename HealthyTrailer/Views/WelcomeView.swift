//
//  WelcomeView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 14.11.2023.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: MainViewModel
    
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var bluetoothManager = BluetoothManager.shared
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer()
                title
                    .padding(.bottom, 14)
                descriptionText
                permissions
                conclusionText
                    .padding(.bottom, 14)
                
                vehicleText
                vehiclePicker
                Spacer()
                
                if viewModel.selectedVehicleState == .car {
                    axiesText
                    countPicker
                    Spacer()
                }
                
                gotItButton
            }
            .padding(.horizontal)
        }
    }
    
    private var title: some View {
        Text(.init("Welcome to Healthy Trailer App"))
            .font(.roboto400, size: 22)
            .foregroundStyle(Color.mainBlue)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var descriptionText: some View {
        Text(.init("This is a security and safety for your trailer in one click. To use this application, you must grant the following permissions:"))
            .fontWeight(.regular)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.textDark)
            .font(.roboto300, size: 18)
    }
    
    private var permissions: some View {
        Text(.init("• Access to your device's location \n• Bluetooth activation"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .fontWeight(.regular)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.textDark)
            .font(.roboto300, size: 18)
    }
    
    private var conclusionText: some View {
        Text(.init("These permissions are essential for the app to function effectively and provide you with its features."))
            .fontWeight(.regular)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.textDark)
            .font(.roboto300, size: 18)
    }
    
    private var countPicker: some View {
        AxiesCountPickerView(selectedCount: $viewModel.selectedAxiesCountState)
            .zIndex(2)
    }
    
    private var axiesText: some View {
        Text(.init("Please select how many axies do you want to track"))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.textDark)
            .font(.roboto300, size: 18)
            .zIndex(1)
    }
    
    private var vehiclePicker: some View {
        VehicleTypePickerView(selectedType: $viewModel.selectedVehicleState)
            .zIndex(2)
    }
    
    private var vehicleText: some View {
        Text(.init("Please select your vehicle type"))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.textDark)
            .font(.roboto300, size: 18)
    }
        
    private var gotItButton: some View {
        Button {
            Task { @MainActor in
                UserDefaults.standard.setValue(viewModel.selectedAxiesCountState, forKey: "axiesCount")
                UserDefaults.standard.setValue(viewModel.selectedVehicleState.rawValue, forKey: "vehicleType")
                
                let user = try AuthManager.shared.getLoggedUser()
                
                let axiesBarCount = viewModel.selectedVehicleState == .motorcycle ? 2 : viewModel.selectedAxiesCountState
                try await FirestoreManager.shared.updateSettings(userID: user.userId, fields: [
                    SettingsModel.CodingKeys.axiesCount.rawValue: axiesBarCount,
                    SettingsModel.CodingKeys.vehicleType.rawValue: viewModel.selectedVehicleState
                ])
                navigationManager.setupNavigationStatus()
            }
        } label: {
            Text(.init("Ok, got it"))
                .padding(.horizontal)
        }
        .buttonStyle(.mainBlueButton)
        .zIndex(1)
        .padding(.top, 20)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(NavigationManager())
}
