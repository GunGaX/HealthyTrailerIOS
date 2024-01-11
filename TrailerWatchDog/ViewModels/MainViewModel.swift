//
//  MainViewModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation

final class MainViewModel: ObservableObject {
    var dataManager = DataManager.shared
    @Published var isTWDConnected = false
    @Published var connectedTWD: TWDModel?
    
    @Published var displayingMode = true
    
    @Published var selectedSound: NotificationSound = .chime
    @Published var selectedTemperatureType: TemperatureType = .fahrenheit
    @Published var selectedPreassureType: PreasureType = .bar
    
    @Published var terminalLogs: [TerminalLog] = TerminalLog.mockLogs
    
    @Published var logFoldersPaths: [String] = []
    @Published var logFiles: [String: HistoryFileModel] = [:]
    
    var connectingTextArray: [String] = []
    var orderedIndeces: [Int] = []
    var connectedOrderedTPMSIds: [String] = []
    
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
    
    public func updateLastValuesData() {
        let dataManager = DataManager.shared
                
        for index in 0..<dataManager.axies.count {
            if !dataManager.axies[index].leftTire.id.isEmpty {
                UserDefaults.standard.setObject(dataManager.axies[index].leftTire, forKey: "lastLog_TPMS\(dataManager.axies[index].leftTire.id)")
            }
            if !dataManager.axies[index].rightTire.id.isEmpty {
                UserDefaults.standard.setObject(dataManager.axies[index].rightTire, forKey: "lastLog_TPMS\(dataManager.axies[index].rightTire.id)")
            }
        }
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
