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
    
    let axisNumber: Int
    let leftTire: TireData
    let rightTire: TireData
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TireData {
    var temperature: Double
    var avgTemperature: Double
}
