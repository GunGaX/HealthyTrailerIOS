//
//  MainViewModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation
import Combine
import SwiftUI
import AVFAudio

final class MainViewModel: ObservableObject {
    var dataManager = DataManager.shared
    
    var settingsViewModel = SettingsViewModel.shared
    
    var alertSoundPlayer: AVAudioPlayer?
    var dogBarkSoundPlayer: AVAudioPlayer?
    
    @Published var selectedAxiesCountState: Int = 2
    
    @Published var isConnected = false
    
    @Published var displayingMode = true
    
    @Published var selectedSound: NotificationSound = .chime
    @Published var selectedTemperatureType: TemperatureType = .fahrenheit
    @Published var selectedPreassureType: PreasureType = .kpa
    
    @Published var terminalLogs: [TerminalLog] = []
    
    @Published var logFoldersPaths: [String] = []
    @Published var logFiles: [String: HistoryFileModel] = [:]
    
    @Published var uploadingTimer: Timer?
    
    @Published var previouslyConnectedDevices: [UUID] = []
    
    @Published var showStaleDataAlert = false
    var staleDataMessage = ""
    
    var connectingTextArray: [String] = []
    var orderedIndeces: [Int] = []
    var connectedOrderedTPMSIds: [String] = []
    
    var staleWarningTimer: Timer?
    var updatingHistoryTimer: Timer?
    var updatingTerminalTimer: Timer?
    
    init() {
        var count = UserDefaults.standard.integer(forKey: "axiesCount")
        guard count != 0 else {
            count = 2
            return
        }
        self.selectedAxiesCountState = count
        
        settingsViewModel.$selectedSound
            .assign(to: &$selectedSound)
        settingsViewModel.$selectedTemperatureType
            .assign(to: &$selectedTemperatureType)
        settingsViewModel.$selectedPreassureType
            .assign(to: &$selectedPreassureType)
        
        setupAudioPlayers()
    }
    
    public func generateConnectingOrder(_ n: Int) {
        orderedIndeces = []
        connectingTextArray = []
        connectedOrderedTPMSIds = []
        
        for i in 1...(n * 2) where i % 2 != 0 {
            orderedIndeces.append(i)
        }
        for i in 1...(n * 2) where i % 2 == 0 {
            orderedIndeces.append(i)
        }
        
        for i in 1...n {
            connectingTextArray.append(.init("LEFT \(i)"))
        }
        for i in 1...n {
            connectingTextArray.append(.init("RIGHT \(i)"))
        }
        
        for _ in 1...(n * 2) {
            connectedOrderedTPMSIds.append("")
        }
    }
    
    public func startTimerAndUploadingData() {
        uploadingTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            self.updateLastTPMSValuesData()
        }
    }
    
    public func stopUploadingData() {
        uploadingTimer?.invalidate()
        uploadingTimer = nil
    }
    
    private func updateLastTPMSValuesData() {
        for index in 0..<dataManager.axies.count {
            if !dataManager.axies[index].leftTire.id.isEmpty {
                UserDefaults.standard.setObject(dataManager.axies[index].leftTire, forKey: "lastLog_TPMS\(dataManager.axies[index].leftTire.id)")
            }
            if !dataManager.axies[index].rightTire.id.isEmpty {
                UserDefaults.standard.setObject(dataManager.axies[index].rightTire, forKey: "lastLog_TPMS\(dataManager.axies[index].rightTire.id)")
            }
        }
    }
    
    public func wasPreviouslyConnected(deviceId: UUID) -> Bool {
        previouslyConnectedDevices.contains(deviceId)
    }
    
    public func saveConnectedDeviceID(connectedDeviceId: UUID) {
        guard !previouslyConnectedDevices.contains(connectedDeviceId) else { return }
        
        var newConnectedDevicesArray = previouslyConnectedDevices
        newConnectedDevicesArray.append(connectedDeviceId)
        
        UserDefaults.standard.setObject(newConnectedDevicesArray, forKey: "previouslyConnectedBluetoothDevices")
    }
    
    public func getConnectedDeviceIDs() {
        self.previouslyConnectedDevices = UserDefaults.standard.getObject(forKey: "previouslyConnectedBluetoothDevices", castTo: [UUID].self) ?? []
    }
    
    public func updateTPMSConnectionStatus(id: String, isConnected: Bool) {
        UserDefaults.standard.setValue(isConnected, forKey: "TPMSConnectionWithId:\(id)")
    }
    
    public func unChainTPMSDevices() {
        guard !dataManager.connectedTPMSIds.isEmpty else { return }
        
        for tpmsId in dataManager.connectedTPMSIds {
            updateTPMSConnectionStatus(id: tpmsId, isConnected: false)
        }
    }
    
    public func getLogDirectories() {
        if let folderPaths = FileRepository.shared.getSubdirectoriesPaths() {
            logFoldersPaths = folderPaths
        }
    }
    
    public func getFilesIdDirecory(path: String) {
        logFiles = [:]
        if let filesPaths = FileRepository.shared.getFilesPathsInDirectory(directoryPath: path) {
            for path in filesPaths {
                if let file = FileRepository.shared.readFromFile(filePath: path) {
                    logFiles[path] = file
                }
            }
        }
    }
    
    public func playAlertSound() {
        if settingsViewModel.selectedSound == .chime {
            alertSoundPlayer?.play()
        } else {
            dogBarkSoundPlayer?.play()
        }
    }
    
    private func setupAudioPlayers() {
        if let soundURL1 = Bundle.main.url(forResource: "alert_sound", withExtension: "mp3") {
            do {
                alertSoundPlayer = try AVAudioPlayer(contentsOf: soundURL1)
            } catch {
                print("Error loading sound file: \(error.localizedDescription)")
            }
        }
        
        if let soundURL2 = Bundle.main.url(forResource: "dogbark_alert", withExtension: "wav") {
            do {
                dogBarkSoundPlayer = try AVAudioPlayer(contentsOf: soundURL2)
            } catch {
                print("Error loading sound file: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkWarnings() {
        let axisList = dataManager.axies
        var tyresNames = ""
        var tyreCount = 0
        
        for index in axisList.indices {
            if !axisList[index].isFresh(isRight: false) {
                tyresNames += .init("Left sensor \(index + 1) hasn't reported in over five minutes, please check sensor\n")
                tyreCount += 1
            }
            if !axisList[index].isFresh(isRight: true) {
                tyresNames += .init("Right sensor \(index + 1) hasn't reported in over five minutes, please check sensor\n")
                tyreCount += 1
            }
        }
        
        if tyreCount != 0 {
            staleDataMessage = tyresNames
            showStaleDataAlert = true
        }
    }
    
    public func startCheckWarningTimer() {
        guard staleWarningTimer == nil else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 240) {
            self.staleWarningTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
                self.checkWarnings()
            }
        }
    }
    
    public func startUpdatingHisoryTimer() {
        self.updatingHistoryTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            for index in self.dataManager.axies.indices {
                self.dataManager.axies[index].leftTire.tireData.updateTemperatureHistory()
                self.dataManager.axies[index].rightTire.tireData.updateTemperatureHistory()
            }
        }
    }
    
    public func stopCheckWarningTimer() {
        staleWarningTimer?.invalidate()
        staleWarningTimer = nil
    }
    
    public func disconnectFromTWD() {
        stopUploadingData()
        stopCheckWarningTimer()
        dataManager.disconnect()
        isConnected = false
    }
    
    public func startUploadingTerminalLogs() {
        self.updatingHistoryTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            self.uploadTerminalLog()
        }
    }
    
    private func uploadTerminalLog() {
        var currentLog: String = "<L>"
        for index in self.dataManager.axies.indices {
            currentLog += "<LT\(index + 1):\(self.dataManager.axies[index].leftTire.tireData.temperature.formattedToOneDecimalPlace())F>"
            if index + 1 != self.dataManager.axies.count {
                currentLog += ","
            }
        }
        currentLog += "</L>,<R>"
        for index in self.dataManager.axies.indices {
            currentLog += "<RT\(index + 1):\(self.dataManager.axies[index].rightTire.tireData.temperature.formattedToOneDecimalPlace())F>"
            if index + 1 != self.dataManager.axies.count {
                currentLog += ","
            }
        }
        currentLog += "</R>"
        
        if terminalLogs.count >= 100 {
            terminalLogs.removeFirst()
        }
        terminalLogs.append(TerminalLog(time: Date.now, text: currentLog))
    }
}
