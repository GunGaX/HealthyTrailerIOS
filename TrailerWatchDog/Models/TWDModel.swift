//
//  TWDModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 06.12.2023.
//

import Foundation

struct TWDModel: Codable {
    let id: UUID
    let name: String
    var axiesCount: Int?
    var leftAxle: [[Double]]
    var rightAxle: [[Double]]
    
    init(id: UUID, name: String, axiesCount: Int? = nil, leftAxle: [[Double]], rightAxle: [[Double]]) {
        self.id = id
        self.name = name
        self.axiesCount = axiesCount
        self.leftAxle = leftAxle
        self.rightAxle = rightAxle
    }
    
    mutating func addNewTemperature(isRight: Bool, newTemperature: Double, index: Int) {
        if isRight {
            if rightAxle[index].count >= 10 {
                rightAxle[index].removeFirst()
                rightAxle[index].append(newTemperature)
            } else {
                rightAxle[index].append(newTemperature)
            }
        } else {
            if leftAxle[index].count >= 10 {
                leftAxle[index].removeFirst()
                leftAxle[index].append(newTemperature)
            } else {
                leftAxle[index].append(newTemperature)
            }
        }
    }
}
