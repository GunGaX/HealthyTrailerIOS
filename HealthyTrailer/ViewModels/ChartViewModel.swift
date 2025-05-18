//
//  ChartViewModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 18.05.2025.
//

import Foundation

class ChartViewModel: ObservableObject {
    @Published var selectedType: DataType = .temperature
    @Published var selectedDate: Date = Date()
    
    @Published var data: [DataModel] = []
    
    var filteredData: [DataModel] {
        let calendar = Calendar.current
        return data.filter {
            calendar.isDate($0.date, inSameDayAs: selectedDate)
        }.sorted(by: { $0.date < $1.date })
    }
    
    func getDataForSensor(sensorId: String) {
        Task { @MainActor in
            let user = try AuthManager.shared.getLoggedUser()
            
            print(user.userId)
            print(sensorId)
            
            let historyModel = try await FirestoreManager.shared.getDataHistory(userId: user.userId, sensorId: sensorId)
            data = historyModel?.data ?? []
            print(data)
        }
    }
}

enum DataType: String, CaseIterable, Identifiable {
    case temperature = "Temperature"
    case pressure = "Pressure"
    
    var id: String { self.rawValue }
}
