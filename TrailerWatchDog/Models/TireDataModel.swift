//
//  TireDataModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 27.11.2023.
//

import Foundation

struct TireData: Equatable {
    var temperature: Double
    var preassure: Double
    var screenTime: Double
    var lastTemperatures: [Double]?
    
    init(temperature: Double, preassure: Double, screenTime: Double, lastTemperatures: [Double]? = nil) {
        self.temperature = temperature
        self.preassure = preassure
        self.screenTime = screenTime
        self.lastTemperatures = lastTemperatures
    }
    
    init(object: TireDataObject) {
        self.temperature = object.temperature
        self.preassure = object.preassure
        self.screenTime = object.screenTime
    }
    
    mutating func appendNewTemperature(temperature: Double) {
        if lastTemperatures?.count ?? 0 > 20 {
            lastTemperatures?.removeFirst()
        }
        
        self.lastTemperatures?.append(temperature)
    }
}

extension TireData {
    func toObject() -> TireDataObject {
        TireDataObject(dto: self)
    }
}
