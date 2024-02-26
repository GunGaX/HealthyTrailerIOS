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
    
    @Published var maxTPMSSensorTemperature = 50.0
    @Published var maxDifferenceTPMSSensorTemperature = 50.0
    @Published var maxTWDSensorTemperature = 50.0
    @Published var maxDifferenceTWDSensorTemperature = 50.0
    @Published var preassureMinValue = 0.07522
    @Published var preassureMaxValue = 0.32604
    @Published var ixExpandedTemperature = false
    @Published var isExpnadedPreassure = false
}
