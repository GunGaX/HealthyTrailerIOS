//
//  NotificationErrorModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 05.03.2024.
//

import Foundation

struct NotificationError: Equatable {
    var show: Bool
    var error: Bool
    var message: String
    var changed: Bool
    
    init() {
        self.show = false
        self.error = false
        self.message = ""
        self.changed = false
    }
}
