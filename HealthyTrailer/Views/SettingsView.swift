//
//  SettingsView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject var viewModel = SettingsViewModel.shared
        
    var body: some View {
        VStack(spacing: 0) {
            SecondaryHeaderView(titleText: .init("Settings"))
            ScrollView {
                VStack(spacing: 30) {
                    measurementPickers
                        .zIndex(2.0)
                        .padding(.top, 30)
                    
                    axlesInfo
                        .padding(.vertical, -10)
                       
                    DefaultSignleSliderView(value: $viewModel.maxTPMSSensorTemperature, selectedTemperatureType: $viewModel.selectedTemperatureType, titleText: .init("Max allowed TPMS sensor temperature"), minValue: viewModel.maxTPMSSensorTemperatureLowerBound, maxValue: viewModel.maxTPMSSensorTemperatureUpperBound)
                    DefaultSignleSliderView(value: $viewModel.maxDifferenceTPMSSensorTemperature, selectedTemperatureType: $viewModel.selectedTemperatureType, titleText: .init("Max allowed difference in TPMS sensor temperature"), minValue: viewModel.maxDifferenceTPMSSensorTemperatureLowerBound, maxValue: viewModel.maxDifferenceTPMSSensorTemperatureUpperBound)
                    
                    DefaultDoubleSliderView(firstValue: $viewModel.preassureMinValue, secondValue: $viewModel.preassureMaxValue, selectedPreassureType: $viewModel.selectedPreassureType, titleText: .init("Expected pressure range:"), minValue: viewModel.preassureMinBound, maxValue: viewModel.preassureMaxBound)
                    
                    notificationSection
                        .padding(.bottom, 30)
                    
                    testButton
                    logOutButton
                        .padding(.bottom, 30)
                }
                .padding(.horizontal)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden()
    }
    
    private var axlesInfo: some View {
        HStack(spacing: 20) {
            Text(.init("Axles:"))
                .foregroundStyle(Color.textDark)
                .font(.roboto500, size: 18)
                .padding(.trailing, 20)
            
            Text(DataManager.shared.axies.count.description)
                .foregroundStyle(Color.mainGrey)
                .font(.roboto500, size: 26)
                .padding(30)
                .background(
                    Circle()
                        .foregroundStyle(Color.lightGrayBackground)
                )
            
            Text(.init("This parameter is determined automatically"))
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.mainGrey)
                .font(.roboto400, size: 14)
                
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var notificationSection: some View {
        VStack(spacing: 26) {
            Text(.init("Notification sound"))
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            NotificationSoundPickerView(selectedSound: $viewModel.selectedSound)
        }
    }
    
    private var measurementPickers: some View {
        HStack {
            PreassureTypePickerView(selectedPreassureType: $viewModel.selectedPreassureType)
            TemperatureTypePickerView(selectedPreassureType: $viewModel.selectedTemperatureType)
        }
    }
    
    private var logOutButton: some View {
        Button {
            UserDefaults.standard.removeObject(forKey: "axiesCount")
            try? AuthManager.shared.logOut()
            navigationManager.setupNavigationStatus()
        } label: {
            Text(.init("Log out"))
                .foregroundStyle(Color.red)
        }
    }
    
    @ViewBuilder
    private var testButton: some View {
//        Button {
//            DataManager.shared.uploadDataToFirestore()
//        } label: {
//            Text("TEST")
//        }
//        .padding(.bottom, 30)
    }
}

#Preview {
    SettingsView()
        .environmentObject(NavigationManager())
        .environmentObject(MainViewModel())
}
