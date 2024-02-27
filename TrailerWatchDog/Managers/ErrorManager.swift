//
//  ErrorManager.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 26.02.2024.
//

import SwiftUI
import Combine

final class ErrorManager: ObservableObject {
    var settingsViewModel = SettingsViewModel.shared
    var twdManager = BluetoothTWDManager.shared
    
    @Published var temperatureOverheatTWDError = false
    var temperatureOverheatTWDMessage = ""
    var temperatureOverheatTWDMessageChanged = false
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = twdManager.$connectedTWD.sink { twd in
            var hasOverheat = self.checkOverheatTWD(twd: twd)
            self.setTemperatureOverheatTWD(isOverheat: hasOverheat)
        }
    }
    
    private func getMaxAllowedTemperatureTWD() -> Double {
        return settingsViewModel.maxTWDSensorTemperature
    }
    
    private func checkOverheatTWD(twd: TWDModel?) -> Bool {
        guard let twd else { return false }
        
        let maxAllowedTemperature = getMaxAllowedTemperatureTWD()
        var messageBuilder = ""
        var hasOverheat = false
        
        for index in 0..<twd.leftAxle.count {
            if twd.leftAxle[index].last ?? 0.0 > maxAllowedTemperature {
                messageBuilder += "Left TWD sensor \(index + 1) is over temperature threshold\n"
                hasOverheat = true
            }
            
            if twd.rightAxle[index].last ?? 0.0 > maxAllowedTemperature {
                messageBuilder += "Right TWD sensor \(index + 1) is over temperature threshold\n"
                hasOverheat = true
            }
        }
        
        temperatureOverheatTWDMessage = messageBuilder
        
        return hasOverheat
    }
    
    private func setTemperatureOverheatTWD(isOverheat: Bool) {
        if temperatureOverheatTWDError != isOverheat || temperatureOverheatTWDMessageChanged {
            temperatureOverheatTWDMessageChanged = false
            temperatureOverheatTWDError = isOverheat
            
            print(temperatureOverheatTWDMessage)
        }
    }
}
