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
    
//    @Published var temperatureOverheatTPMSError = false
//    var temperatureOverheatTPMSMessage = ""
//    var temperatureOverheatTPMSMessageChanged = false
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = twdManager.$connectedTWD.sink { twd in
            print(twd?.leftAxle[0].last ?? "no info")
        }
    }
    
//    private func getMaxAllowedTemperatureTWD() -> Double {
//        return settingsViewModel.maxTWDSensorTemperature
//    }
    
//    private func checkOverheatTWD(data: )
}
