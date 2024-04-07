//
//  TireDataModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 27.11.2023.
//

import Foundation

//TPMS
struct TireData: Equatable, Codable {
    var temperature: Double
    var preassure: Double
    var updateDate: Date
    var temperatureHistory: [Double]
    
    init(temperature: Double, preassure: Double, updateDate: Date, temperatureHistory: [Double]) {
        self.temperature = temperature
        self.preassure = preassure
        self.updateDate = updateDate
        self.temperatureHistory = temperatureHistory
    }
    
    mutating func updateTemperatureHistory() {
        if temperatureHistory.count >= 10 {
            self.temperatureHistory.removeFirst()
        }
        self.temperatureHistory.append(self.temperature)
    }
    
    static var emptyData: TireData {
        TireData(temperature: 0, preassure: 0, updateDate: Date.now, temperatureHistory: [])
    }
}
