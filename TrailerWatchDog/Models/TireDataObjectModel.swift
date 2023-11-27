//
//  TireDataObjectModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 27.11.2023.
//

import Foundation
import RealmSwift

class TireDataObject: Object {
    @Persisted var temperature: Double
    @Persisted var preassure: Double
    @Persisted var screenTime: Double
    
    convenience init(dto: TireData) {
        self.init()
        self.temperature = dto.temperature
        self.preassure = dto.preassure
        self.screenTime = dto.screenTime
    }
}

extension TireDataObject {
    func toDTO() -> TireData {
        TireData(object: self)
    }
}

extension Array where Element == TireDataObject {
    func toDTO() -> [TireData] {
        map { $0.toDTO() }
    }
}
