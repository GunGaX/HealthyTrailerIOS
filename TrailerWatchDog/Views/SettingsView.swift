//
//  SettingsView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject var viewModel = SettingsViewModel.shared
        
    var body: some View {
        VStack(spacing: 0) {
            SecondaryHeaderView(titleText: "Settings")
            ScrollView {
                VStack(spacing: 30) {
                    measurementPickers
                        .zIndex(2.0)
                        .padding(.top, 30)
                    
                    axlesInfo
                        .padding(.vertical, -10)
                       
                    DefaultSignleSliderView(value: $viewModel.maxTPMSSensorTemperature, selectedTemperatureType: $viewModel.selectedTemperatureType, titleText: "Max allowed TPMS sensor temperature", minValue: viewModel.maxTPMSSensorTemperatureLowerBound, maxValue: viewModel.maxTPMSSensorTemperatureUpperBound)
                    DefaultSignleSliderView(value: $viewModel.maxDifferenceTPMSSensorTemperature, selectedTemperatureType: $viewModel.selectedTemperatureType, titleText: "Max allowed difference in TPMS sensor temperature", minValue: viewModel.maxDifferenceTPMSSensorTemperatureLowerBound, maxValue: viewModel.maxDifferenceTPMSSensorTemperatureUpperBound)
                    
                    DefaultSignleSliderView(value: $viewModel.maxTWDSensorTemperature, selectedTemperatureType: $viewModel.selectedTemperatureType, titleText: "Max allowed TWD sensor temperature", minValue: viewModel.maxTWDSensorTemperatureLowerBound, maxValue: viewModel.maxTWDSensorTemperatureUpperBound)
                    DefaultSignleSliderView(value: $viewModel.maxDifferenceTWDSensorTemperature, selectedTemperatureType: $viewModel.selectedTemperatureType, titleText: "Max allowed difference in TWD sensor temperature", minValue: viewModel.maxDifferenceTWDSensorTemperatureLowerBound, maxValue: viewModel.maxDifferenceTWDSensorTemperatureUpperBound)
                    
                    DefaultDoubleSliderView(firstValue: $viewModel.preassureMinValue, secondValue: $viewModel.preassureMaxValue, selectedPreassureType: $viewModel.selectedPreassureType, titleText: "Expected pressure range:", minValue: viewModel.preassureMinBound, maxValue: viewModel.preassureMaxBound)
                    
                    notificationSection
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
            Text("Axles:")
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
            
            Text("This parameter is determined automatically")
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.mainGrey)
                .font(.roboto400, size: 14)
                
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var notificationSection: some View {
        VStack(spacing: 26) {
            Text("Notification sound")
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
}

#Preview {
    SettingsView()
        .environmentObject(NavigationManager())
        .environmentObject(MainViewModel())
}
