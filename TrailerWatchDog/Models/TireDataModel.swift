//
//  TireDataModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 27.11.2023.
//

import Foundation

struct TireData: Equatable, Codable {
    var temperature: Double
    var preassure: Double
    var updateDate: Date
    
    init(temperature: Double, preassure: Double, updateDate: Date) {
        self.temperature = temperature
        self.preassure = preassure
        self.updateDate = updateDate
    }
}
