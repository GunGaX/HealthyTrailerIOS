//
//  DateExtensions.swift
//  TrailerWatchDog
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
}
