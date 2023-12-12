//
//  TPMSModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 11.12.2023.
//

import Foundation

struct TPMSModel: Codable, Equatable {
    let id: String
    let connectedToTWDWithId: String
    let tireData: TireData
}
