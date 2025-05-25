//
//  AlertData.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 11.05.2025.
//

import Foundation

struct AlertData: Identifiable {
    var id = UUID()
    var title: String
    var message: String
}
