//
//  FileRepository.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 16.11.2023.
//

import Foundation

class FileRepository {
    static let shared = FileRepository()
    
    private let fileManager = FileManager.default
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let logsTrailerDirectory = "LogsTrailer"
    
    private init() {
        createLogsTrailerDirectoryIfNeeded()
    }
    
    func writeToFile(file: HistoryFileModel, atFolder folderPath: String) {
        let folderURL = URL(fileURLWithPath: folderPath)

        let filePath = folderURL.appendingPathComponent(file.title)

        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(file)

            try jsonData.write(to: filePath)
            print("File saved successfully at: \(filePath.path)")
        } catch {
            print("Error saving file: \(error)")
        }
    }

    
    func readFromFile(filePath: String) -> HistoryFileModel? {
        let url = URL(fileURLWithPath: filePath)
        
        do {
            let jsonData = try Data(contentsOf: url)
            
            let jsonDecoder = JSONDecoder()
            let readingData = try jsonDecoder.decode(HistoryFileModel.self, from: jsonData)
            return readingData
        } catch {
            print("Error reading file: \(error)")
            return nil
        }
    }
    
    private func createLogsTrailerDirectoryIfNeeded() {
        let logsTrailerPath = documentsDirectory.appendingPathComponent(logsTrailerDirectory)
        
        if !fileManager.fileExists(atPath: logsTrailerPath.path) {
            do {
                try fileManager.createDirectory(at: logsTrailerPath, withIntermediateDirectories: true, attributes: nil)
                print("LogsTrailer directory created successfully.")
            } catch {
                print("Error creating LogsTrailer directory: \(error)")
            }
        }
    }
    
    func createSubdirectory(withName name: String) -> URL? {
        let directoryPath = documentsDirectory.appendingPathComponent(logsTrailerDirectory)
        let subdirectoryPath = directoryPath.appendingPathComponent(name)
        
        do {
            try fileManager.createDirectory(at: subdirectoryPath, withIntermediateDirectories: true, attributes: nil)
            print("Subdirectory \(name) created successfully.")
            return subdirectoryPath
        } catch {
            print("Error creating subdirectory \(name): \(error)")
            return nil
        }
    }
    
    func getSubdirectoriesPaths() -> [String]? {
        let directoryPath = documentsDirectory.appendingPathComponent(logsTrailerDirectory)
        
        do {
            let subdirectories = try fileManager.contentsOfDirectory(atPath: directoryPath.path)
            let fullPaths = subdirectories.map { directoryPath.appendingPathComponent($0).path }
            return fullPaths
        } catch {
            print("Error getting subdirectories: \(error)")
            return nil
        }
    }
    
    func getFilesPathsInDirectory(directoryPath: String) -> [String]? {
        guard let url = URL(string: directoryPath) else { return nil }
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: url.path)
            let fullPaths = files.map { url.appendingPathComponent($0).path }
            return fullPaths
        } catch {
            print("Error getting subdirectories: \(error)")
            return nil
        }
    }
    
    
    
}
