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
    
    init(temperature: Double, preassure: Double, updateDate: Date) {
        self.temperature = temperature
        self.preassure = preassure
        self.updateDate = updateDate
    }
    
    static var emptyData: TireData {
        TireData(temperature: 0, preassure: 0, updateDate: Date.now)
    }
}
