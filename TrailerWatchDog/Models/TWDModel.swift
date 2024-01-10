//
//  TWDModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 06.12.2023.
//

import Foundation

struct TWDModel: Codable {
    let id: String
    let name: String
    let axisCount: Int
    let temperature: [Double]
    
    static var mockTWD: TWDModel {
        TWDModel(id: "fkj4oirh48i", name: "HC-04", axisCount: 2, temperature: [23.1, 45.1, 23.4, 23.6, 17.3, 29.1])
    }
}
