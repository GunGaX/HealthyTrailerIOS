//
//  SettingsViewModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 26.02.2024.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    static let shared = SettingsViewModel()
    
    init() {
        fetchLastSelectedSound()
        fetchSelectedTemperatureType()
        fetchSelectedPreassureType()
        fetchMaxTWDSensorTemperature()
        fetchMaxDifferenceTWDSensorTemperature()
        fetchMaxTPMSSensorTemperature()
        fetchMaxDifferenceTPMSSensorTemperature()
        fetchPreassureMinValue()
        fetchPreassureMaxValue()
    }
    
    @Published var selectedSound: NotificationSound = .chime {
        didSet {
            saveSelectedSound()
        }
    }
    @Published var selectedTemperatureType: TemperatureType = .fahrenheit {
        didSet {
            saveSelectedTemperatureType()
        }
    }
    @Published var selectedPreassureType: PreasureType = .kpa {
        didSet {
            saveSelectedPreassureType()
        }
    }
    
    /// In Fahrenheit
    let maxTPMSSensorTemperatureLowerBound = 32.0
    let maxTPMSSensorTemperatureUpperBound = 220.0
    @Published var maxTPMSSensorTemperature = 170.0 {
        didSet {
            saveMaxTPMSSensorTemperature()
        }
    }
    
    /// In Fahrenheit
    let maxDifferenceTPMSSensorTemperatureLowerBound = 0.0
    let maxDifferenceTPMSSensorTemperatureUpperBound = 100.0
    @Published var maxDifferenceTPMSSensorTemperature = 30.0 {
        didSet {
            saveMaxDifferenceTPMSSensorTemperature()
        }
    }
    
    /// In Fahrenheit
    let maxTWDSensorTemperatureLowerBound = 32.0
    let maxTWDSensorTemperatureUpperBound = 220.0
    @Published var maxTWDSensorTemperature = 150.0 {
        didSet {
            saveMaxTWDSensorTemperature()
        }
    }
    
    /// In Fahrenheit
    let maxDifferenceTWDSensorTemperatureLowerBound = 0.0
    let maxDifferenceTWDSensorTemperatureUpperBound = 100.0
    @Published var maxDifferenceTWDSensorTemperature = 30.0 {
        didSet {
            saveMaxDifferenceTWDSensorTemperature()
        }
    }
    
    /// In Kpa
    let preassureMinBound = 0.0
    let preassureMaxBound = 1206.0
    @Published var preassureMinValue = 0.0 {
        didSet {
            savePreassureMinValue()
        }
    }
    @Published var preassureMaxValue = 400.0 {
        didSet {
            savePreassureMaxValue()
        }
    }
    
    private func saveSelectedSound() {
        UserDefaults.standard.setObject(selectedSound, forKey: "selectedSound")
    }
    
    private func fetchLastSelectedSound() {
        if let lastSound = UserDefaults.standard.getObject(forKey: "selectedSound", castTo: NotificationSound.self) {
            selectedSound = lastSound
        }
    }
    
    private func saveSelectedTemperatureType() {
        UserDefaults.standard.setObject(selectedTemperatureType, forKey: "selectedTemperatureType")
    }
    
    public func fetchSelectedTemperatureType() {
        if let lastTemp = UserDefaults.standard.getObject(forKey: "selectedTemperatureType", castTo: TemperatureType.self) {
            selectedTemperatureType = lastTemp
        }
    }
    
    private func saveSelectedPreassureType() {
        UserDefaults.standard.setObject(selectedPreassureType, forKey: "selectedPreassureType")
    }
    
    public func fetchSelectedPreassureType() {
        if let lastPres = UserDefaults.standard.getObject(forKey: "selectedPreassureType", castTo: PreasureType.self) {
            selectedPreassureType = lastPres
        }
    }
    
    private func saveMaxTPMSSensorTemperature() {
        UserDefaults.standard.set(maxTPMSSensorTemperature, forKey: "maxTPMSSensorTemperature")
    }
    
    private func fetchMaxTPMSSensorTemperature() {
        let value = UserDefaults.standard.double(forKey: "maxTPMSSensorTemperature")
        guard value != 0 else { return }
        
        maxTPMSSensorTemperature = value
    }
    
    private func saveMaxDifferenceTPMSSensorTemperature() {
        UserDefaults.standard.set(maxDifferenceTPMSSensorTemperature, forKey: "maxDifferenceTPMSSensorTemperature")
    }
    
    private func fetchMaxDifferenceTPMSSensorTemperature() {
        let value = UserDefaults.standard.double(forKey: "maxDifferenceTPMSSensorTemperature")
        guard value != 0 else { return }
        
        maxDifferenceTPMSSensorTemperature = value
    }
    
    private func saveMaxTWDSensorTemperature() {
        UserDefaults.standard.set(maxTWDSensorTemperature, forKey: "maxTWDSensorTemperature")
    }
    
    private func fetchMaxTWDSensorTemperature() {
        let value = UserDefaults.standard.double(forKey: "maxTWDSensorTemperature")
        guard value != 0 else { return }
        
        maxTWDSensorTemperature = value
    }
    
    private func saveMaxDifferenceTWDSensorTemperature() {
        UserDefaults.standard.set(maxDifferenceTWDSensorTemperature, forKey: "maxDifferenceTWDSensorTemperature")
    }
    
    private func fetchMaxDifferenceTWDSensorTemperature() {
        let value = UserDefaults.standard.double(forKey: "maxDifferenceTWDSensorTemperature")
        guard value != 0 else { return }
        
        maxDifferenceTWDSensorTemperature = value
    }
    
    private func savePreassureMinValue() {
        UserDefaults.standard.set(preassureMinValue, forKey: "preassureMinValue")
    }
    
    private func fetchPreassureMinValue() {
        let value = UserDefaults.standard.double(forKey: "preassureMinValue")
        guard value != 0 else { return }
        
        preassureMinValue = value
    }
    
    private func savePreassureMaxValue() {
        UserDefaults.standard.set(preassureMaxValue, forKey: "preassureMaxValue")
    }
    
    private func fetchPreassureMaxValue() {
        let value = UserDefaults.standard.double(forKey: "preassureMaxValue")
        guard value != 0 else { return }
        
        preassureMaxValue = value
    }
}
