//
//  HistoryFileModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 17.11.2023.
//

import Foundation

struct HistoryFileModel: Codable, Equatable, Hashable {
    let title: String
    let content: String
    let creationDate: Date
}
