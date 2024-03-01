//
//  ErrorManager.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 26.02.2024.
//

import SwiftUI
import Combine

final class ErrorManager: ObservableObject {        
    private var settingsViewModel = SettingsViewModel.shared
    private var twdManager = BluetoothTWDManager.shared
    private var tpmsManager = DataManager.shared
    
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
    
    @Published var showTPMSPressureAlert = false
    var pressureTPMSError = false
    var pressureTPMSMessage = ""
    var pressureTPMSMessageChanged = false
    
    @Published var backgroundColors: [(Color, Color)] = [(Color.mainDark, Color.mainDark), (Color.mainDark, Color.mainDark), (Color.mainDark, Color.mainDark), (Color.mainDark, Color.mainDark)]
    @Published var foregroundColors: [(Color, Color)] = [(Color.white, Color.white), (Color.white, Color.white), (Color.white, Color.white), (Color.white, Color.white)]
    
    var staleDataTimers: [(Timer?, Timer?)] = [(nil, nil), (nil, nil), (nil, nil), (nil, nil)]
    
    init() {        
        let twdPublisher = twdManager.$connectedTWD
            .removeDuplicates()
        
        let tpmsPublisher = tpmsManager.$axies
            .removeDuplicates()
        
        cancellable = Publishers.CombineLatest(twdPublisher, tpmsPublisher)
            .sink { twd, tpms in
                self.twdDataChanged(twd: twd)
                self.tpmsDataChanged(axies: tpms)
                self.updateColors()
            }
    }
    
    private func twdDataChanged(twd: TWDModel?) {
        guard twdManager.canShowNotifications else { return }
        guard let twd else { return }
        
        self.clearFlagsTWD()
        let hasBigDiff = self.checkMinMaxTempTWD(twd: twd)
        let hasOverheat = self.checkOverheatTWD(twd: twd)
        self.setMaxDifferenceTWD(hasMaxDiff: hasBigDiff)
        self.setTemperatureOverheatTWD(isOverheat: hasOverheat)
    }
    
    private func tpmsDataChanged(axies: [AxiesData]) {
        guard tpmsManager.canShowNotifications else { return }
        
        self.clearFlagsTPMS()
        let hasBigDiff = self.checkMinMaxTempTPMS(axies: axies)
        let hasOverheat = self.checkOverheatTPMS(axies: axies)
        let hasOutOfBounds = self.checkPressureTPMS(axies: axies)
        self.setMaxDifferenceTPMS(hasMaxDiff: hasBigDiff)
        self.setTemperatureOverheatTPMS(isOverheat: hasOverheat)
        self.setPressureErrorTPMS(isOutOfBounds: hasOutOfBounds)
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
    
    private func getMinPressureTPMS() -> Double {
        return settingsViewModel.preassureMinValue
    }
    
    private func getMaxPressureTPMS() -> Double {
        return settingsViewModel.preassureMaxValue
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
                tpmsManager.axies[index].isRightCriticalTWD = true
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
            if axies[index].isLeftCleanTPMS && axies[index].leftTire.tireData.updateDate.isFresh() {
                if axies[index].leftTire.tireData.temperature > maxAllowedTemperature {
                    messageBuilder += "Left wheel \(index + 1) is over temperature threshold\n"
                    tpmsManager.axies[index].isLeftCriticalTPMS = true
                    hasOverheat = true
                }
            }
            
            if axies[index].isRightCleanTPMS && axies[index].rightTire.tireData.updateDate.isFresh() {
                if axies[index].rightTire.tireData.temperature > maxAllowedTemperature {
                    messageBuilder += "Right wheel \(index + 1) is over temperature threshold\n"
                    tpmsManager.axies[index].isRightCriticalTPMS = true
                    hasOverheat = true
                }
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
            if !row.isLeftCleanTPMS {
                if row.leftTire.tireData.temperature > maxTemp {
                    maxTemp = row.leftTire.tireData.temperature
                }
                if row.leftTire.tireData.temperature < minTemp {
                    minTemp = row.leftTire.tireData.temperature
                }
            }
            
            if !row.isRightCleanTPMS {
                if row.rightTire.tireData.temperature > maxTemp {
                    maxTemp = row.rightTire.tireData.temperature
                }
                if row.rightTire.tireData.temperature < minTemp {
                    minTemp = row.rightTire.tireData.temperature
                }
            }
        }
        
        let maxDiff = self.getMaxAllowedDifferenceTPMS()
        var hasBigDiff = false
        if maxTemp - minTemp < maxDiff {
            return false
        }
        
        for index in axies.indices {
            if !axies[index].isLeftCleanTPMS && axies[index].leftTire.tireData.updateDate.isFresh() {
                if axies[index].leftTire.tireData.temperature + maxDiff < maxTemp || axies[index].leftTire.tireData.temperature - maxDiff > minTemp {
                    tpmsManager.axies[index].isLeftCriticalTPMS = true
                    hasBigDiff = true
                    messageBuilder += "Left wheel \(index + 1) is over max temperature difference\n"
                }
            }
            
            if !axies[index].isRightCleanTPMS && axies[index].rightTire.tireData.updateDate.isFresh() {
                if axies[index].rightTire.tireData.temperature + maxDiff < maxTemp || axies[index].rightTire.tireData.temperature - maxDiff > minTemp {
                    tpmsManager.axies[index].isRightCriticalTPMS = true
                    hasBigDiff = true
                    messageBuilder += "Right wheel \(index + 1) is over max temperature difference\n"
                }
            }
        }
        
        temperatureDifferenceTPMSMessageChanged = self.temperatureDifferenceTPMSMessage != messageBuilder
        temperatureDifferenceTPMSMessage = messageBuilder
        return hasBigDiff
    }
    
    private func checkPressureTPMS(axies: [AxiesData]) -> Bool {
        let minPressure = self.getMinPressureTPMS()
        let maxPressure = self.getMaxPressureTPMS()
        var isOutOfBound = false
        var messageBuilder = ""
        
        for index in axies.indices {
            if !axies[index].isLeftCleanTPMS && axies[index].leftTire.tireData.updateDate.isFresh() {
                if axies[index].leftTire.tireData.preassure < minPressure {
                    tpmsManager.axies[index].isLeftCriticalTPMS = true
                    isOutOfBound = true
                    
                    if axies[index].leftTire.tireData.preassure == 0.0 {
                        messageBuilder += "Left wheel \(index + 1) has flat tire or sensor is unscrewed\n"
                    } else {
                        messageBuilder += "Left wheel \(index + 1) has to low pressure\n"
                    }
                    
                    if axies[index].leftTire.tireData.preassure > maxPressure {
                        tpmsManager.axies[index].isLeftCriticalTPMS = true
                        isOutOfBound = true
                        
                        messageBuilder += "Left wheel \(index + 1) has to high pressure\n"
                    }
                }
            }
            
            if !axies[index].isRightCleanTPMS && axies[index].rightTire.tireData.updateDate.isFresh() {
                if axies[index].rightTire.tireData.preassure < minPressure {
                    tpmsManager.axies[index].isRightCriticalTPMS = true
                    isOutOfBound = true
                    
                    if axies[index].rightTire.tireData.preassure == 0.0 {
                        messageBuilder += "Right wheel \(index + 1) has flat tire or sensor is unscrewed\n"
                    } else {
                        messageBuilder += "Right wheel \(index + 1) has to low pressure\n"
                    }
                    
                    if axies[index].rightTire.tireData.preassure > maxPressure {
                        tpmsManager.axies[index].isRightCriticalTPMS = true
                        isOutOfBound = true
                        
                        messageBuilder += "Right wheel \(index + 1) has to high pressure\n"
                    }
                }
            }
        }
        
        pressureTPMSMessageChanged = self.pressureTPMSMessage != messageBuilder
        pressureTPMSMessage = messageBuilder
        return isOutOfBound
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
            if temperatureDifferenceTPMSError {
                showTPMSTemperatureDifferenceAlert = true
            }
        }
    }
    
    private func setPressureErrorTPMS(isOutOfBounds: Bool) {
        if pressureTPMSError != isOutOfBounds || pressureTPMSMessageChanged {
            pressureTPMSMessageChanged = false
            pressureTPMSError = isOutOfBounds
            if pressureTPMSError {
                showTPMSPressureAlert = true
            }
        }
    }
    
    private func clearFlagsTPMS() {
        for index in tpmsManager.axies.indices {
            tpmsManager.axies[index].isLeftCriticalTPMS = false
            tpmsManager.axies[index].isRightCriticalTPMS = false
        }
    }
    
    private func clearFlagsTWD() {
        for index in tpmsManager.axies.indices {
            tpmsManager.axies[index].isLeftCriticalTWD = false
            tpmsManager.axies[index].isRightCriticalTWD = false
        }
    }
    
    private func updateColors() {
        for index in tpmsManager.axies.indices {
            updateColorsForAxle(axle: tpmsManager.axies[index], index: index)
        }
    }
    
    private func updateColorsForAxle(axle: AxiesData, index: Int) {
        if !axle.isRightSaved && !axle.isRightCriticalTWD {
            setColors(index, true, back: Color.mainDark, front: Color.white)
        } else if axle.isRightCleanTPMS && !axle.isRightCriticalTWD {
            setColors(index, true, back: Color.lightBlue, front: Color.mainBlue)
        } else if axle.rightTire.tireData.updateDate.isFresh() {
            if axle.isRightCritical || axle.isRightCriticalTWD {
                setColors(index, true, back: Color.lightRed, front: Color.mainRed)
            } else {
                setColors(index, true, back: Color.lightGreen, front: Color.mainGreen)
            }
        } else {
            setBlinkyColors(index, true, first: Color.lightRed, second: Color.lightYellow)
        }
        if !axle.isLeftSaved && !axle.isLeftCriticalTWD {
            setColors(index, false, back: Color.mainDark, front: Color.white)
        } else if axle.isLeftCleanTPMS && !axle.isLeftCriticalTWD {
            setColors(index, false, back: Color.lightBlue, front: Color.mainBlue)
        } else if axle.leftTire.tireData.updateDate.isFresh() {
            if axle.isLeftCritical || axle.isLeftCriticalTWD {
                setColors(index, false, back: Color.lightRed, front: Color.mainRed)
            } else {
                setColors(index, false, back: Color.lightGreen, front: Color.mainGreen)
            }
        } else {
            setBlinkyColors(index, false, first: Color.lightRed, second: Color.lightYellow)
        }
    }
    
    private func setColors(_ index: Int, _ isRight: Bool, back: Color, front: Color) {
        if isRight {
            staleDataTimers[index].1?.invalidate()
            staleDataTimers[index].1 = nil
            backgroundColors[index].1 = back
            foregroundColors[index].1 = front
        } else {
            staleDataTimers[index].0?.invalidate()
            staleDataTimers[index].0 = nil
            backgroundColors[index].0 = back
            foregroundColors[index].0 = front
        }
    }
    
    private func setStaleColors(_ index: Int, _ isRight: Bool, back: Color, front: Color) {
        if isRight {
            backgroundColors[index].1 = back
            foregroundColors[index].1 = front
        } else {
            backgroundColors[index].0 = back
            foregroundColors[index].0 = front
        }
    }
    
    private func setBlinkyColors(_ index: Int, _ isRight: Bool, first: Color, second: Color) {
        if isRight {
            guard staleDataTimers[index].1 == nil else { return }
                    
            staleDataTimers[index].1 = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
                self.setStaleColors(index, isRight, back: first, front: Color.mainRed)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.setStaleColors(index, isRight, back: second, front: Color.mainRed)
                }
            }
        } else {
            guard staleDataTimers[index].0 == nil else { return }
                    
            staleDataTimers[index].0 = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
                self.setStaleColors(index, isRight, back: first, front: Color.mainRed)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.setStaleColors(index, isRight, back: second, front: Color.mainRed)
                }
            }
        }
        
    }
}
