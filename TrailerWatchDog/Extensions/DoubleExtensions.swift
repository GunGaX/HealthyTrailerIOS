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
    
    func fromCelciusToFarenheit() -> Double {
        return ((self * 1.8) + 32)
    }
    
    func fromPsiToKpa() -> Double {
        return Double(self * 6.89476000045014)
    }
    
    func fromPsiToBar() -> Double {
        return Double(self * 0.0689476000045014)
    }
    
    func fromKpaToBar() -> Double {
        return Double(self * 0.01)
    }
    
    func fromKpaToPsi() -> Double {
        return Double(self * 0.145037738)
    }
    
    func applyTemperatureSystem(selectedSystem: TemperatureType) -> Double {
        switch selectedSystem {
        case .celsius: return self.fromFahrenheitToCelsius()
        case .fahrenheit: return self
        }
    }
    
    func applyPreassureSystem(selectedSystem: PreasureType) -> Double {
        switch selectedSystem {
        case .kpa: return self.fromPsiToKpa()
        case .bar: return self.fromPsiToBar()
        case .psi: return self
        }
    }
}
