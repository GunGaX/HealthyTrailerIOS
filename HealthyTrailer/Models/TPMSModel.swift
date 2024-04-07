//
//  TPMSModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 11.12.2023.
//

import Foundation

struct TPMSModel: Codable, Equatable {
    let id: String
    var tireData: TireData
    
    static var emptyState: TPMSModel {
        TPMSModel(id: "", tireData: TireData.emptyData)
    }
}

