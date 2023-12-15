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
    var tireData: TireData
    
    static var emptyState: TPMSModel {
        TPMSModel(id: "", connectedToTWDWithId: "", tireData: TireData.emptyData)
    }
}
