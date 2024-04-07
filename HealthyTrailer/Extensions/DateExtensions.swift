//
//  DateExtensions.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 16.11.2023.
//

import Foundation

extension Date {
    func formattedTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    func defaultDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func isFresh() -> Bool {
        let now = Date()
        let diff = abs(now.timeIntervalSince(self))
        let minutes = diff / 60
        
        return minutes <= 10
    }
}
