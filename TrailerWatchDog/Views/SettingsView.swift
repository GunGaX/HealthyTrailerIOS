//
//  SettingsView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: MainViewModel
    
    @State private var maxTPMSSensorTemperature = 0.7728
    @State private var maxDifferenceTPMSSensorTemperature = 0.3
    @State private var maxTWDSensorTemperature = 0.6818
    @State private var maxDifferenceTWDSensorTemperature = 0.3
    @State private var preassureMinValue = 0.07522
    @State private var preassureMaxValue = 0.32604
    @State private var ixExpandedTemperature = false
    @State private var isExpnadedPreassure = false
        
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
                       
                    DefaultSignleSliderView(value: $maxTPMSSensorTemperature, selectedTemperatureType: $viewModel.selectedTemperatureType, titleText: "Max allowed TPMS sensor temperature", minValue: 32, maxValue: 220)
                    DefaultSignleSliderView(value: $maxDifferenceTPMSSensorTemperature, selectedTemperatureType: $viewModel.selectedTemperatureType, titleText: "Max allowed difference in TPMS sensor temperature", minValue: 0, maxValue: 100)
                    
                    DefaultSignleSliderView(value: $maxTWDSensorTemperature, selectedTemperatureType: $viewModel.selectedTemperatureType, titleText: "Max allowed TWD sensor temperature", minValue: 32, maxValue: 220)
                    DefaultSignleSliderView(value: $maxDifferenceTWDSensorTemperature, selectedTemperatureType: $viewModel.selectedTemperatureType, titleText: "Max allowed difference in TWD sensor temperature", minValue: 0, maxValue: 100)
                    
                    DefaultDoubleSliderView(firstValue: $preassureMinValue, secondValue: $preassureMaxValue, selectedPreassureType: $viewModel.selectedPreassureType, titleText: "Expected pressure range:", minValue: 1.45, maxValue: 174.92)
                    
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
