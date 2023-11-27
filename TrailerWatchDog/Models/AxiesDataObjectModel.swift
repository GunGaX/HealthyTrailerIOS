//
//  AxiesDataObjectModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 27.11.2023.
//

import Foundation
import RealmSwift

class AxiesDataObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var axisNumber: Int
    @Persisted var leftTire: TireDataObject
    @Persisted var rightTire: TireDataObject
    
    convenience init(dto: AxiesData) {
        self.init()
        self.id = dto.id
        self.axisNumber = dto.axisNumber
        self.leftTire = dto.leftTire.toObject()
        self.rightTire = dto.rightTire.toObject()
    }
}

extension AxiesDataObject {
    func toDTO() -> AxiesData {
        AxiesData(object: self)
    }
}

extension Array where Element == AxiesDataObject {
    func toDTOs() -> [AxiesData] {
        map { $0.toDTO() }
    }
}
