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
        VStack(spacing: 20) {
            Spacer()
            title
                .padding(.bottom, 14)
            descriptionText
            permissions
            conclusionText
                .padding(.bottom, 14)
            axiesText
            countPicker
            Spacer()
            gotItButton
        }
        .padding(.horizontal)
    }
    
    private var title: some View {
        Text("Welcome to Healthy Trailer App")
            .font(.roboto400, size: 22)
            .foregroundStyle(Color.mainBlue)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var descriptionText: some View {
        Text("This is a security and safety for your trailer in one click. To use this application, you must grant the following permissions:")
            .fontWeight(.regular)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.textDark)
            .font(.roboto300, size: 18)
    }
    
    private var permissions: some View {
        Text("• Access to your device's location \n• Bluetooth activation")
            .frame(maxWidth: .infinity, alignment: .leading)
            .fontWeight(.regular)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.textDark)
            .font(.roboto300, size: 18)
    }
    
    private var conclusionText: some View {
        Text("These permissions are essential for the app to function effectively and provide you with its features.")
            .fontWeight(.regular)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.textDark)
            .font(.roboto300, size: 18)
    }
    
    private var countPicker: some View {
        AxiesCountPickerView(selectedCount: $viewModel.selectedAxiesCountState)
    }
    
    private var axiesText: some View {
        Text("Please select how many axies do you want to track")
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.textDark)
            .font(.roboto300, size: 18)
    }
    
    private var gotItButton: some View {
        Button {
            UserDefaults.standard.setValue(viewModel.selectedAxiesCountState, forKey: "axiesCount")
            if locationManager.checkIfAccessIsGranted() && bluetoothManager.checkBluetooth() {
                navigationManager.appState = .app
            } else {
                navigationManager.appState = .allowPermissions
            }
        } label: {
            Text("Ok, got it")
                .padding(.horizontal)
        }
        .buttonStyle(.mainBlueButton)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(NavigationManager())
}
