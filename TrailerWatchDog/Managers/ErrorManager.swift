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
    
    @Published var showTWDTemperatureDifferenceAlert = false
    var temperatureDifferenceTWDError = false
    var temperatureDifferenceTWDMessage = ""
    var temperatureDifferenceTWDMessageChanged = false
    
    @Published var showTPMSTemperatureDifferenceAlert = false
    var temperatureDifferenceTPMSError = false
    var temperatureDifferenceTPMSMessage = ""
    var temperatureDifferenceTPMSMessageChanged = false
    
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
        guard let twd else { return }
        
        let hasBigDiff = self.checkMinMaxTempTWD(twd: twd)
        let hasOverheat = self.checkOverheatTWD(twd: twd)
        self.setMaxDifferenceTWD(hasMaxDiff: hasBigDiff)
        self.setTemperatureOverheatTWD(isOverheat: hasOverheat)
    }
    
    private func tpmsDataChanged(axies: [AxiesData]) {
        let hasBigDiff = self.checkMinMaxTempTPMS(axies: axies)
        let hasOverheat = self.checkOverheatTPMS(axies: axies)
        self.setMaxDifferenceTPMS(hasMaxDiff: hasBigDiff)
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
    
    private func getMaxAllowedDifferenceTPMS() -> Double {
        return settingsViewModel.maxDifferenceTPMSSensorTemperature
    }
    
    private func checkOverheatTWD(twd: TWDModel) -> Bool {
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
    
    private func checkMinMaxTempTWD(twd: TWDModel) -> Bool {
        var minTemp = Double.infinity
        var maxTemp = -Double.infinity
        var messageBuilder = ""
        
        for index in 0..<twd.leftAxle.count {
            if let newMaxTemp = twd.leftAxle[index].max(), newMaxTemp > maxTemp {
                maxTemp = newMaxTemp
            }
            if let newMinTemp = twd.leftAxle[index].min(), newMinTemp < minTemp {
                minTemp = newMinTemp
            }
            
            if let newMaxTemp = twd.rightAxle[index].max(), newMaxTemp > maxTemp {
                maxTemp = newMaxTemp
            }
            if let newMinTemp = twd.rightAxle[index].min(), newMinTemp < minTemp {
                minTemp = newMinTemp
            }
        }
        
        let maxDiff = self.getMaxAllowedDifferenceTWD()
        var hasBigDiff = false
        if maxTemp - minTemp < maxDiff {
            self.temperatureDifferenceTWDMessage = messageBuilder
            return false
        }
        
        var overMaxRowsIndeces: [Int] = []
        var overMinRowsIndeces: [Int] = []
        
        for index in twd.leftAxle.indices {
            if let currentTemperature = twd.leftAxle[index].last, currentTemperature + maxDiff < maxTemp {
                overMaxRowsIndeces.append(index)
            }
            if let currentTemperature = twd.leftAxle[index].last, currentTemperature - maxDiff > minTemp {
                overMinRowsIndeces.append(index)
            }
            
            if let currentTemperature = twd.rightAxle[index].last, currentTemperature + maxDiff < maxTemp {
                overMaxRowsIndeces.append(index)
            }
            if let currentTemperature = twd.rightAxle[index].last, currentTemperature - maxDiff > minTemp {
                overMinRowsIndeces.append(index)
            }
        }
        
        if overMinRowsIndeces.count < overMaxRowsIndeces.count {
            for index in twd.leftAxle.indices {
                if !overMinRowsIndeces.contains(index) {
                    continue
                }
                
                if let currentTemperature = twd.leftAxle[index].last, currentTemperature - maxDiff > minTemp {
                    tpmsManager.axies[index].isLeftCriticalTWD = true
                    hasBigDiff = true
                    messageBuilder += "Left TWD sensor \(index + 1) is over max temperature difference\n"
                }
                
                if let currentTemperature = twd.rightAxle[index].last, currentTemperature - maxDiff > minTemp {
                    tpmsManager.axies[index].isRightCriticalTWD = true
                    hasBigDiff = true
                    messageBuilder += "Right TWD sensor \(index + 1) is over max temperature difference\n"
                }
            }
        } else if overMinRowsIndeces.count > overMaxRowsIndeces.count {
            for index in twd.leftAxle.indices {
                if !overMaxRowsIndeces.contains(index) {
                    continue
                }
                
                if let currentTemperature = twd.leftAxle[index].last, currentTemperature + maxDiff < maxTemp {
                    tpmsManager.axies[index].isLeftCriticalTWD = true
                    hasBigDiff = true
                    messageBuilder += "Left TWD sensor \(index + 1) is over max temperature difference\n"
                }
                
                if let currentTemperature = twd.rightAxle[index].last, currentTemperature + maxDiff < maxTemp {
                    tpmsManager.axies[index].isRightCriticalTWD = true
                    hasBigDiff = true
                    messageBuilder += "Right TWD sensor \(index + 1) is over max temperature difference\n"
                }
            }
        } else {
            var criticalSensoursCount = 0
            
            for index in twd.leftAxle.indices {
                if let currentTemperature = twd.leftAxle[index].last, currentTemperature + maxDiff < maxTemp || currentTemperature - maxDiff > minTemp {
                    tpmsManager.axies[index].isLeftCriticalTWD = true
                    hasBigDiff = true
                    criticalSensoursCount += 1
                }
                
                if let currentTemperature = twd.rightAxle[index].last, currentTemperature + maxDiff < maxTemp || currentTemperature - maxDiff > minTemp {
                    tpmsManager.axies[index].isRightCriticalTWD = true
                    hasBigDiff = true
                    criticalSensoursCount += 1
                }
            }
            
            criticalSensoursCount /= 2
            messageBuilder += "\(criticalSensoursCount) or more sensors is over max temperature difference\n"
        }
        
        temperatureDifferenceTWDMessageChanged = self.temperatureDifferenceTWDMessage != messageBuilder
        temperatureDifferenceTWDMessage = messageBuilder
        return hasBigDiff
    }
    
    private func checkMinMaxTempTPMS(axies: [AxiesData]) -> Bool {
        var minTemp = Double.infinity
        var maxTemp = -Double.infinity
        var messageBuilder = ""
        
        for row in axies {
            if row.leftTire.tireData.temperature > maxTemp {
                maxTemp = row.leftTire.tireData.temperature
            }
            if row.leftTire.tireData.temperature < minTemp {
                minTemp = row.leftTire.tireData.temperature
            }
            
            if row.rightTire.tireData.temperature > maxTemp {
                maxTemp = row.rightTire.tireData.temperature
            }
            if row.rightTire.tireData.temperature < minTemp {
                minTemp = row.rightTire.tireData.temperature
            }
        }
        
        let maxDiff = self.getMaxAllowedDifferenceTPMS()
        var hasBigDiff = false
        if maxTemp - minTemp < maxDiff {
            return false
        }
        
        for index in axies.indices {
            if axies[index].leftTire.tireData.temperature + maxDiff < maxTemp || axies[index].leftTire.tireData.temperature - maxDiff > minTemp {
                tpmsManager.axies[index].isLeftCriticalTPMS = true
                hasBigDiff = true
                messageBuilder += "Left wheel \(index + 1) is over max temperature difference\n"
            }
            
            if axies[index].rightTire.tireData.temperature + maxDiff < maxTemp || axies[index].rightTire.tireData.temperature - maxDiff > minTemp {
                tpmsManager.axies[index].isRightCriticalTPMS = true
                hasBigDiff = true
                messageBuilder += "Right wheel \(index + 1) is over max temperature difference\n"
            }
        }
        
        temperatureDifferenceTPMSMessageChanged = self.temperatureDifferenceTPMSMessage != messageBuilder
        temperatureDifferenceTPMSMessage = messageBuilder
        return hasBigDiff
    }
    
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
    
    private func setMaxDifferenceTWD(hasMaxDiff: Bool) {
        if temperatureDifferenceTWDError != hasMaxDiff || temperatureDifferenceTWDMessageChanged {
            temperatureDifferenceTWDMessageChanged = false
            temperatureDifferenceTWDError = hasMaxDiff
            if temperatureDifferenceTWDError {
                showTWDTemperatureDifferenceAlert = true
            }
        }
    }
    
    private func setMaxDifferenceTPMS(hasMaxDiff: Bool) {
        if temperatureDifferenceTPMSError != hasMaxDiff || temperatureDifferenceTPMSMessageChanged {
            temperatureDifferenceTPMSMessageChanged = false
            temperatureDifferenceTPMSError = hasMaxDiff
            if temperatureDifferenceTPMSError && tpmsManager.canShowNotifications {
                showTPMSTemperatureDifferenceAlert = true
            }
        }
    }
}
