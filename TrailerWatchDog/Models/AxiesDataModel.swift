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
    
    init(axisNumber: Int, leftTire: TPMSModel, rightTire: TPMSModel) {
        self.axisNumber = axisNumber
        self.leftTire = leftTire
        self.rightTire = rightTire
    }
    
    var id: Int { axisNumber }
    
    var axisNumber: Int
    var leftTire: TPMSModel
    var rightTire: TPMSModel
    
    var isLeftCleanTPMS: Bool = false
    var isRightCleanTPMS: Bool = false
    var isLeftCleanTWD: Bool = false
    var isRightCleanTWD: Bool = false
    var isLeftCriticalTPMS: Bool = false
    var isRightCriticalTPMS: Bool = false
    var isLeftCriticalTWD: Bool = false
    var isRightCriticalTWD: Bool = false
    var isLeftCritical: Bool {
        return isLeftCriticalTWD || isLeftCriticalTPMS
    }
    var isRightCritical: Bool {
        return isRightCriticalTWD || isRightCriticalTPMS
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
