//
//  UserModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 04.05.2025.
//

import Foundation

struct UserModel: Codable {
    let userId: String
    let firstName: String
    let lastName: String
    let emailAdress: String
    let axiesCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case emailAdress = "email_adress"
        case axiesCount = "axies_count"
        
    }
    
    init(userId: String, firstName: String, lastName: String, emailAdress: String, axiesCount: Int?) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.emailAdress = emailAdress
        self.axiesCount = axiesCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.userId = try container.decode(String.self, forKey: .userId)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.emailAdress = try container.decode(String.self, forKey: .emailAdress)
        self.axiesCount = try? container.decode(Int?.self, forKey: .axiesCount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(userId, forKey: .userId)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(emailAdress, forKey: .emailAdress)
        try container.encode(axiesCount, forKey: .axiesCount)
    }
}
