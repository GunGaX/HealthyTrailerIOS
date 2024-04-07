//
//  AxiesDataModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 13.11.2023.
//

import Foundation

struct AxiesData: Identifiable, Hashable {
    var id: Int { axisNumber }
    
    var axisNumber: Int
    var leftTire: TPMSModel
    var rightTire: TPMSModel
    
    var isLeftSaved: Bool = false
    var isRightSaved: Bool = false
    var isLeftCleanTPMS: Bool = true
    var isRightCleanTPMS: Bool = true
    var isLeftCleanTWD: Bool = true
    var isRightCleanTWD: Bool = true
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

extension AxiesData {
    func isFresh(isRight: Bool) -> Bool {
        let date = isRight ? self.rightTire.tireData.updateDate : self.leftTire.tireData.updateDate
        
        return date.isFresh()
    }
    
    func getTemperature(isRight: Bool) -> Double {
        let tire = isRight ? self.rightTire : self.leftTire
        
        return tire.tireData.temperature
    }
    
    func getPressure(isRight: Bool) -> Double {
        let tire = isRight ? self.rightTire : self.leftTire
        
        return tire.tireData.preassure
    }
}
