//
//  SettingsViewModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 26.02.2024.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    static let shared = SettingsViewModel()
    
    @Published var selectedSound: NotificationSound = .chime
    @Published var selectedTemperatureType: TemperatureType = .fahrenheit
    @Published var selectedPreassureType: PreasureType = .kpa
    
    /// In Fahrenheit
    let maxTPMSSensorTemperatureLowerBound = 32.0
    let maxTPMSSensorTemperatureUpperBound = 220.0
    @Published var maxTPMSSensorTemperature = 170.0
    
    /// In Fahrenheit
    let maxDifferenceTPMSSensorTemperatureLowerBound = 0.0
    let maxDifferenceTPMSSensorTemperatureUpperBound = 100.0
    @Published var maxDifferenceTPMSSensorTemperature = 30.0
    
    /// In Fahrenheit
    let maxTWDSensorTemperatureLowerBound = 32.0
    let maxTWDSensorTemperatureUpperBound = 220.0
    @Published var maxTWDSensorTemperature = 150.0
    
    /// In Fahrenheit
    let maxDifferenceTWDSensorTemperatureLowerBound = 0.0
    let maxDifferenceTWDSensorTemperatureUpperBound = 100.0
    @Published var maxDifferenceTWDSensorTemperature = 30.0
    
    /// In Kpa
    let preassureMinBound = 0.0
    let preassureMaxBound = 1206.0
    @Published var preassureMinValue = 0.0
    @Published var preassureMaxValue = 400.0
}
