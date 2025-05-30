//
//  ErrorManager.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 26.02.2024.
//

import SwiftUI
import Combine

final class ErrorManager: ObservableObject {        
    private var settingsViewModel = SettingsViewModel.shared
    private var tpmsManager = DataManager.shared
    
    private var cancellable: AnyCancellable?
    
    @Published var twdOverheatNotificationError = NotificationError()
    
    @Published var tpmsOverheatNotificationError = NotificationError()
    
    @Published var twdTemperatureDifferenceNotificationError = NotificationError()
    
    @Published var tpmsTemperatureDifferenceNotificationError = NotificationError()
    
    @Published var tpmsPressureNotificationError = NotificationError()
    
    @Published var backgroundColors: [(Color, Color)] = [(Color.mainDark, Color.mainDark), (Color.mainDark, Color.mainDark), (Color.mainDark, Color.mainDark), (Color.mainDark, Color.mainDark)]
    @Published var foregroundColors: [(Color, Color)] = [(Color.white, Color.white), (Color.white, Color.white), (Color.white, Color.white), (Color.white, Color.white)]
    
    var staleDataTimers: [(Timer?, Timer?)] = [(nil, nil), (nil, nil), (nil, nil), (nil, nil)]
    
    private var updatingTimer: Timer?
    
    init() {
        startCheckingForErrors()
    }
    
    private func startCheckingForErrors() {
        guard updatingTimer == nil else { return }
        
        updatingTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            self.updateColors()
            self.tpmsDataChanged()
        }
    }
    
    private func tpmsDataChanged() {
        guard tpmsManager.canShowNotifications else { return }
        guard !tpmsManager.axies.isEmpty else { return }
        
        let axies = tpmsManager.axies
        
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
    
    private func checkOverheatTPMS(axies: [AxiesData]) -> Bool {
        let maxAllowedTemperature = getMaxAllowedTemperatureTPMS()
        var messageBuilder = ""
        var hasOverheat = false
        
        for index in 0..<axies.count {
            if axies[index].isLeftCleanTPMS && axies[index].isFresh(isRight: false) {
                if axies[index].getTemperature(isRight: false) > maxAllowedTemperature {
                    messageBuilder += .init("Left wheel \(index + 1) is over temperature threshold\n")
                    tpmsManager.axies[index].isLeftCriticalTPMS = true
                    hasOverheat = true
                }
            }
            
            if axies[index].isRightCleanTPMS && axies[index].isFresh(isRight: true) {
                if axies[index].getTemperature(isRight: true) > maxAllowedTemperature {
                    messageBuilder += .init("Right wheel \(index + 1) is over temperature threshold\n")
                    tpmsManager.axies[index].isRightCriticalTPMS = true
                    hasOverheat = true
                }
            }
        }
        
        tpmsOverheatNotificationError.changed = self.tpmsOverheatNotificationError.message != messageBuilder
        tpmsOverheatNotificationError.message = messageBuilder
        
        return hasOverheat
    }
    
    private func checkMinMaxTempTPMS(axies: [AxiesData]) -> Bool {
        var minTemp = Double.infinity
        var maxTemp = -Double.infinity
        var messageBuilder = ""
        
        for row in axies {
            if !row.isLeftCleanTPMS {
                if row.getTemperature(isRight: false) > maxTemp {
                    maxTemp = row.getTemperature(isRight: false)
                }
                if row.getTemperature(isRight: false) < minTemp {
                    minTemp = row.getTemperature(isRight: false)
                }
            }
            
            if !row.isRightCleanTPMS {
                if row.getTemperature(isRight: true) > maxTemp {
                    maxTemp = row.getTemperature(isRight: true)
                }
                if row.getTemperature(isRight: true) < minTemp {
                    minTemp = row.getTemperature(isRight: true)
                }
            }
        }
        
        let maxDiff = self.getMaxAllowedDifferenceTPMS()
        var hasBigDiff = false
        if maxTemp - minTemp < maxDiff {
            return false
        }
        
        for index in axies.indices {
            if !axies[index].isLeftCleanTPMS && axies[index].isFresh(isRight: false) {
                if axies[index].getTemperature(isRight: false) + maxDiff < maxTemp || axies[index].getTemperature(isRight: false) - maxDiff > minTemp {
                    tpmsManager.axies[index].isLeftCriticalTPMS = true
                    hasBigDiff = true
                    messageBuilder += .init(String(format: NSLocalizedString("LeftWheelOverTemp", comment: ""), "\(index + 1)"))
                }
            }
            
            if !axies[index].isRightCleanTPMS && axies[index].isFresh(isRight: true) {
                if axies[index].getTemperature(isRight: true) + maxDiff < maxTemp || axies[index].getTemperature(isRight: true) - maxDiff > minTemp {
                    tpmsManager.axies[index].isRightCriticalTPMS = true
                    hasBigDiff = true
                    messageBuilder += .init(String(format: NSLocalizedString("RightWheelOverTemp", comment: ""), "\(index + 1)"))
                }
            }
        }
        
        tpmsTemperatureDifferenceNotificationError.changed = self.tpmsTemperatureDifferenceNotificationError.message != messageBuilder
        tpmsTemperatureDifferenceNotificationError.message = messageBuilder
        return hasBigDiff
    }
    
    private func checkPressureTPMS(axies: [AxiesData]) -> Bool {
        let minPressure = self.getMinPressureTPMS()
        let maxPressure = self.getMaxPressureTPMS()
        var isOutOfBound = false
        var messageBuilder = ""
        
        for index in axies.indices {
            if !axies[index].isLeftCleanTPMS && axies[index].isFresh(isRight: false) {
                if axies[index].getPressure(isRight: false) < minPressure {
                    tpmsManager.axies[index].isLeftCriticalTPMS = true
                    isOutOfBound = true
                                        
                    if axies[index].getPressure(isRight: false) == 0.0 {
                        messageBuilder += .init(String(format: NSLocalizedString("LeftWheelFlatOrSensor", comment: ""), index + 1))
                    } else {
                        messageBuilder += .init(String(format: NSLocalizedString("LeftWheelLowPressure", comment: ""), index + 1))
                    }
                    
                    if axies[index].getPressure(isRight: false) > maxPressure {
                        tpmsManager.axies[index].isLeftCriticalTPMS = true
                        isOutOfBound = true
                        
                        messageBuilder += .init(String(format: NSLocalizedString("LeftWheelHighPressure", comment: ""), index + 1))
                    }
                }
            }
            
            if !axies[index].isRightCleanTPMS && axies[index].isFresh(isRight: true) {
                if axies[index].getPressure(isRight: true) < minPressure {
                    tpmsManager.axies[index].isRightCriticalTPMS = true
                    isOutOfBound = true
                                        
                    if axies[index].getPressure(isRight: true) == 0.0 {
                        messageBuilder += .init(String(format: NSLocalizedString("RightWheelFlatOrSensor", comment: ""), index + 1))
                    } else {
                        messageBuilder += .init(String(format: NSLocalizedString("RightWheelLowPressure", comment: ""), index + 1))
                    }
                    
                    if axies[index].getPressure(isRight: true) > maxPressure {
                        tpmsManager.axies[index].isRightCriticalTPMS = true
                        isOutOfBound = true
                        
                        messageBuilder += .init(String(format: NSLocalizedString("RightWheelHighPressure", comment: ""), index + 1))
                    }
                }
            }
        }
        
        tpmsPressureNotificationError.changed = self.tpmsPressureNotificationError.message != messageBuilder
        tpmsPressureNotificationError.message = messageBuilder
        return isOutOfBound
    }
    
    private func setTemperatureOverheatTPMS(isOverheat: Bool) {
        if tpmsOverheatNotificationError.error != isOverheat || tpmsOverheatNotificationError.changed {
            tpmsOverheatNotificationError.changed = false
            tpmsOverheatNotificationError.error = isOverheat
            if tpmsOverheatNotificationError.error {
                tpmsOverheatNotificationError.show = true
            }
        }
    }
    
    private func setMaxDifferenceTPMS(hasMaxDiff: Bool) {
        if tpmsTemperatureDifferenceNotificationError.error != hasMaxDiff || tpmsTemperatureDifferenceNotificationError.changed {
            tpmsTemperatureDifferenceNotificationError.changed = false
            tpmsTemperatureDifferenceNotificationError.error = hasMaxDiff
            if tpmsTemperatureDifferenceNotificationError.error {
                tpmsTemperatureDifferenceNotificationError.show = true
            }
        }
    }
    
    private func setPressureErrorTPMS(isOutOfBounds: Bool) {
        if tpmsPressureNotificationError.error != isOutOfBounds || tpmsPressureNotificationError.changed {
            tpmsPressureNotificationError.changed = false
            tpmsPressureNotificationError.error = isOutOfBounds
            if tpmsPressureNotificationError.error {
                tpmsPressureNotificationError.show = true
            }
        }
    }
    
    private func clearFlagsTPMS() {
        for index in tpmsManager.axies.indices {
            tpmsManager.axies[index].isLeftCriticalTPMS = false
            tpmsManager.axies[index].isRightCriticalTPMS = false
        }
    }
    
    private func updateColors() {
        guard tpmsManager.canShowNotifications else { return }
        
        for index in tpmsManager.axies.indices {
            updateColorsForAxle(axle: tpmsManager.axies[index], index: index)
        }
    }
    
    private func updateColorsForAxle(axle: AxiesData, index: Int) {
        if !axle.isRightSaved && !axle.isRightCriticalTWD {
            setColors(index, true, back: Color.mainDark, front: Color.white)
        } else if axle.isRightCleanTPMS && !axle.isRightCriticalTWD {
            setColors(index, true, back: Color.lightBlue, front: Color.mainBlue)
        } else if axle.isFresh(isRight: true) {
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
        } else if axle.isFresh(isRight: false) {
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
