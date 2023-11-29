//
//  AxiesDataModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 13.11.2023.
//

import Foundation

struct AxiesData: Identifiable, Hashable {
    static func == (lhs: AxiesData, rhs: AxiesData) -> Bool {
        lhs.id == rhs.id &&
        lhs.leftTire == rhs.leftTire &&
        lhs.rightTire == rhs.rightTire
    }
    
    var id: Int { axisNumber }
    
    var axisNumber: Int
    var leftTire: TireData
    var rightTire: TireData
    
    init(axisNumber: Int, leftTire: TireData, rightTire: TireData) {
        self.axisNumber = axisNumber
        self.leftTire = leftTire
        self.rightTire = rightTire
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
