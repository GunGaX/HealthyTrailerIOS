//
//  MainViewModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation
import Combine
import SwiftUI
import AVFAudio

final class MainViewModel: ObservableObject {
    var dataManager = DataManager.shared
    var twdManager = BluetoothTWDManager.shared
    
    var settingsViewModel = SettingsViewModel.shared
    
    var alertSoundPlayer: AVAudioPlayer?
    var dogBarkSoundPlayer: AVAudioPlayer?
    
    @Published var isTWDConnected = false
    @Published var connectedTWD: TWDModel?
    
    @Published var displayingMode = true
    
    @Published var selectedSound: NotificationSound = .chime
    @Published var selectedTemperatureType: TemperatureType = .fahrenheit
    @Published var selectedPreassureType: PreasureType = .kpa
    
    @Published var terminalLogs: [TerminalLog] = TerminalLog.mockLogs
    
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
    
    init() {
        twdManager.$connectedTWD
            .assign(to: &$connectedTWD)
        
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
            connectingTextArray.append("LEFT \(i)")
        }
        for i in 1...n {
            connectingTextArray.append("RIGHT \(i)")
        }
        
        for _ in 1...(n * 2) {
            connectedOrderedTPMSIds.append("")
        }
    }
    
    public func startTimerAndUploadingData() {
        uploadingTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            self.updateLastTPMSValuesData()
            self.twdManager.updateLastTWDValuesData()
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
    
    public func getLastTemperatureForAxle(isRight: Bool, index: Int) -> String {
        if isRight {
            return connectedTWD?.rightAxle[index].last?.applyTemperatureSystem(selectedSystem: selectedTemperatureType).formattedToOneDecimalPlace().description ?? ""
        } else {
            return connectedTWD?.leftAxle[index].last?.applyTemperatureSystem(selectedSystem: selectedTemperatureType).formattedToOneDecimalPlace().description ?? ""
        }
    }
    
    public func getTemperatureArrayForAxle(isRight: Bool, index: Int) -> [Double] {
        if isRight {
            return connectedTWD?.rightAxle[index] ?? []
        } else {
            return connectedTWD?.leftAxle[index] ?? []
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
        print("show 1")
        let axisList = dataManager.axies
        var tyresNames = ""
        var tyreCount = 0
        
        for index in axisList.indices {
            if !axisList[index].isFresh(isRight: false) {
                tyresNames += "Left sensor \(index) hasn't reported in over five minutes, please check sensor\n"
                tyreCount += 1
            }
            if !axisList[index].isFresh(isRight: true) {
                tyresNames += "Right sensor \(index) hasn't reported in over five minutes, please check sensor\n"
                tyreCount += 1
            }
        }
        
        if tyreCount != 0 {
            print("show 2")
            staleDataMessage = tyresNames
            showStaleDataAlert = true
        }
    }
    
    public func startCheckWarningTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 240) {
            self.staleWarningTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
                self.checkWarnings()
            }
        }
    }
    
    public func stopCheckWarningTimer() {
        staleWarningTimer?.invalidate()
        staleWarningTimer = nil
    }
    
//
//    public func createDirectory() {
//        FileRepository.shared.createSubdirectory(withName: "Folder 1")
//        FileRepository.shared.createSubdirectory(withName: "Folder 2")
//        FileRepository.shared.createSubdirectory(withName: "Folder 3")
//    }
//    
//    public func createFiles(path: String) {
//        var file = HistoryFileModel(title: "file for test", content: "content \n content \n content \n fajlskjdflkja iofjqiwhdf askdjf kajksdjf ajskd jfkasjldkf jioqwjdfioj akdsljfk lajsldf ", creationDate: Date.now)
//        FileRepository.shared.writeToFile(file: file, atFolder: path)
//        
//        file = HistoryFileModel(title: "file for test one ", content: "3fasdfkfjkaj skldf ajsdf ladf ", creationDate: Date.now)
//        FileRepository.shared.writeToFile(file: file, atFolder: path)
//        
//        file = HistoryFileModel(title: "some logs will be here", content: "content \n content \n content \n fajlskjdflkja iofjqiwhdf askdjf kajksdjf ajskd jfkasjldkf jioqwjdfioj akdsljfk lajsldf ", creationDate: Date.now)
//        FileRepository.shared.writeToFile(file: file, atFolder: path)
//        
//        file = HistoryFileModel(title: "ijijfi  fdf", content: "content \n content \n content \n fajlskjdflkja iofjqiwhdf askdjf kajksdjf ajskd jfkasjldkf jioqwjdfioj akdsljfk lajsldf ", creationDate: Date.now)
//        FileRepository.shared.writeToFile(file: file, atFolder: path)
//        
//        file = HistoryFileModel(title: "file for test 1 more", content: "content \n content \n content \n fajlskjdflkja iofjqiwhdf askdjf kajksdjf ajskd jfkasjldkf jioqwjdfioj akdsljfk lajsldf ", creationDate: Date.now)
//        FileRepository.shared.writeToFile(file: file, atFolder: path)
//    }
}
