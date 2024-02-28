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
    var tpmsManager = DataManager.shared
    
    private var cancellable: AnyCancellable?
    
    @Published var showTWDOverheatAlert = false
    var temperatureOverheatTWDError = false
    var temperatureOverheatTWDMessage = ""
    var temperatureOverheatTWDMessageChanged = false
    
    @Published var showTPMSOverheatAlert = false
    var temperatureOverheatTPMSError = false
    var temperatureOverheatTPMSMessage = ""
    var temperatureOverheatTPMSMessageChanged = false
    
    @Published var temperatureDifferenceTWDError = false
    var temperatureDifferenceTWDMessage = ""
    var temperatureDifferenceTWDMessageChanged = false
    
    init() {        
        let twdPublisher = twdManager.$connectedTWD
            .removeDuplicates()
        
        let tpmsPublisher = tpmsManager.$axies
            .removeDuplicates()
        
        cancellable = Publishers.CombineLatest(twdPublisher, tpmsPublisher)
            .sink { twd, tpms in
                self.twdDataChanged(twd: twd)
                self.tpmsDataChanged(axies: tpms)
            }
    }
    
    private func twdDataChanged(twd: TWDModel?) {
        let hasOverheat = self.checkOverheatTWD(twd: twd)
        self.setTemperatureOverheatTWD(isOverheat: hasOverheat)
    }
    
    private func tpmsDataChanged(axies: [AxiesData]) {
        let hasOverheat = self.checkOverheatTPMS(axies: axies)
        self.setTemperatureOverheatTPMS(isOverheat: hasOverheat)
    }
    
    private func getMaxAllowedTemperatureTWD() -> Double {
        return settingsViewModel.maxTWDSensorTemperature
    }
    
    private func getMaxAllowedTemperatureTPMS() -> Double {
        return settingsViewModel.maxTPMSSensorTemperature
    }
    
    private func getMaxAllowedDifferenceTWD() -> Double {
        return settingsViewModel.maxDifferenceTWDSensorTemperature
    }
    
    private func checkOverheatTWD(twd: TWDModel?) -> Bool {
        guard let twd else { return false }
        
        let maxAllowedTemperature = getMaxAllowedTemperatureTWD()
        var messageBuilder = ""
        var hasOverheat = false
        
        for index in 0..<twd.leftAxle.count {
            if twd.leftAxle[index].last ?? 0.0 > maxAllowedTemperature {
                messageBuilder += "Left TWD sensor \(index + 1) is over temperature threshold\n"
                tpmsManager.axies[index].isLeftCriticalTWD = true
                hasOverheat = true
            }
            
            if twd.rightAxle[index].last ?? 0.0 > maxAllowedTemperature {
                messageBuilder += "Right TWD sensor \(index + 1) is over temperature threshold\n"
                tpmsManager.axies[index].isRightCleanTWD = true
                hasOverheat = true
            }
        }
        
        temperatureOverheatTWDMessageChanged = self.temperatureOverheatTWDMessage != messageBuilder
        temperatureOverheatTWDMessage = messageBuilder
        
        return hasOverheat
    }
    
    private func checkOverheatTPMS(axies: [AxiesData]) -> Bool {
        let maxAllowedTemperature = getMaxAllowedTemperatureTPMS()
        var messageBuilder = ""
        var hasOverheat = false
        
        for index in 0..<axies.count {
            if axies[index].leftTire.tireData.temperature > maxAllowedTemperature {
                messageBuilder += "Left wheel \(index + 1) is over temperature threshold\n"
                tpmsManager.axies[index].isLeftCriticalTPMS = true
                hasOverheat = true
            }
            
            if axies[index].rightTire.tireData.temperature > maxAllowedTemperature {
                messageBuilder += "Right wheel \(index + 1) is over temperature threshold\n"
                tpmsManager.axies[index].isRightCriticalTPMS = true
                hasOverheat = true
            }
        }
        
        temperatureOverheatTPMSMessageChanged = self.temperatureOverheatTPMSMessage != messageBuilder
        temperatureOverheatTPMSMessage = messageBuilder
        
        return hasOverheat
    }
    
//    private func checkMinMaxTempTWD(twd: TWDModel?) -> Bool {
//        guard let twd else { return false }
//        
//        var minTemp = Double.infinity
//        var maxTemp = -Double.infinity
//        var messageBuilder = ""
//        
//        for index in 0..<twd.leftAxle.count {
//            if let newMaxTemp = twd.leftAxle[index].max(), newMaxTemp > maxTemp {
//                maxTemp = newMaxTemp
//            }
//            if let newMinTemp = twd.leftAxle[index].min(), newMinTemp < minTemp {
//                minTemp = newMinTemp
//            }
//            
//            if let newMaxTemp = twd.rightAxle[index].max(), newMaxTemp > maxTemp {
//                maxTemp = newMaxTemp
//            }
//            if let newMinTemp = twd.rightAxle[index].min(), newMinTemp < minTemp {
//                minTemp = newMinTemp
//            }
//        }
//        
//        let maxDiff = self.getMaxAllowedDifferenceTWD()
//        var hasBigDiff = false
//        if maxTemp - minTemp < maxDiff {
//            self.temperatureDifferenceTWDMessage = messageBuilder
//        }
//        
//        var overMaxRows = twd.leftAxle.
//    }
    
    private func setTemperatureOverheatTWD(isOverheat: Bool) {
        if temperatureOverheatTWDError != isOverheat || temperatureOverheatTWDMessageChanged {
            temperatureOverheatTWDMessageChanged = false
            temperatureOverheatTWDError = isOverheat
            if temperatureOverheatTWDError {
                showTWDOverheatAlert = true
            }
        }
    }
    
    private func setTemperatureOverheatTPMS(isOverheat: Bool) {
        if temperatureOverheatTPMSError != isOverheat || temperatureOverheatTPMSMessageChanged {
            temperatureOverheatTPMSMessageChanged = false
            temperatureOverheatTPMSError = isOverheat
            if temperatureOverheatTPMSError {
                showTPMSOverheatAlert = true
            }
        }
    }
}
