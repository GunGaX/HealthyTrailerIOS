//
//  DoubleExtensions.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 11.11.2023.
//

import Foundation

extension Double {
    func formattedToOneDecimalPlace() -> String {
        return String(format: "%.1f", self)
    }
    
    func fromFahrenheitToCelsius() -> Double {
        return (Double(self - 32) / 1.8)
    }
    
    func fromPsiToKpa() -> Double {
        return Double(self * 6.89476000045014)
    }
    
    func fromPsiToBar() -> Double {
        return Double(self * 0.0689476000045014)
    }
}
