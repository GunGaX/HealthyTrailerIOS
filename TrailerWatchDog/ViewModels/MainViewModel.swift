//
//  MainViewModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation

final class MainViewModel: ObservableObject {
    @Published var isTWDConnected = false
    @Published var displayingMode = true
    
    @Published var selectedSound: NotificationSound = .chime
    @Published var selectedTemperatureType: TemperatureType = .celsius
    @Published var selectedPreassureType: PreasureType = .bar
    
    @Published var terminalLogs: [TerminalLog] = TerminalLog.mockLogs
    
    @Published var logFoldersPaths: [String] = []
    @Published var logFiles: [String: HistoryFileModel] = [:]
    
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
