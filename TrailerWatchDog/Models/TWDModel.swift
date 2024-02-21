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
    var leftAxle: [Double?]
    var rightAxle: [Double?]
}
