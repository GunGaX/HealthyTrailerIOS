//
//  Validator.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 11.05.2025.
//

import Foundation

final class Validator {
    static func isValidEmail(_ email: String) -> Bool {
        if email.isEmpty { return false }
        let emailFormat = #"^\S+@\S+\.\S+$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        let passwordFormat = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&.,/-])[A-Za-z\\d@$!%*?&.,/-]+$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordFormat)
        return passwordPredicate.evaluate(with: password)
    }
    
    static func isValidName(_ name: String) -> Bool {
        if name.isEmpty { return false }
        let nameFormat = #"^[a-zA-Z0-9 ,.'-]{1,25}$"#
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameFormat)
        return namePredicate.evaluate(with: name)
    }
    
    static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        if phoneNumber.isEmpty { return false }
        let phoneFormat = #"^\d{1,10}$"#
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneFormat)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    static func containsSensitiveDigits(_ input: String) -> Bool {
        let digitsOnlyFormat = #"^\d{9,}$"#
        let digitsOnlyPredicate = NSPredicate(format: "SELF MATCHES %@", digitsOnlyFormat)
        return digitsOnlyPredicate.evaluate(with: input)
    }
}
