//
//  AxiesDataModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 13.11.2023.
//

import Foundation

struct AxiesData: Identifiable, Hashable {
    static func == (lhs: AxiesData, rhs: AxiesData) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: Int { axisNumber }
    
    var axisNumber: Int
    var leftTire: TireData
    var rightTire: TireData
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TireData {
    var temperature: String
    var preassure: String
    var screenTime: String
}
