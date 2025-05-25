//
//  DataHistoryModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 17.05.2025.
//

import Foundation

struct DataHistoryModel: Codable {
    let id: String
    let userId: String
    let sensorId: String
    var data: [DataModel]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "user_id"
        case sensorId = "sensor_id"
        case data = "data"
        
    }
    
    init(id: String, userId: String, sensorId: String, data: [DataModel]) {
        self.id = id
        self.userId = userId
        self.sensorId = sensorId
        self.data = data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.sensorId = try container.decode(String.self, forKey: .sensorId)
        self.data = try container.decode([DataModel].self, forKey: .data)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(sensorId, forKey: .sensorId)
        try container.encode(data, forKey: .data)
    }
}

extension DataHistoryModel {
    static var mockDataHistories: [DataHistoryModel] {
        [
            DataHistoryModel(
                id: UUID().uuidString,
                userId: (try? AuthManager.shared.getLoggedUser().userId) ?? "",
                sensorId: UUID().uuidString,
                data: DataModel.mockModels
            ),
            DataHistoryModel(
                id: UUID().uuidString,
                userId: (try? AuthManager.shared.getLoggedUser().userId) ?? "",
                sensorId: UUID().uuidString,
                data: DataModel.mockModels
            ),
            DataHistoryModel(
                id: UUID().uuidString,
                userId: (try? AuthManager.shared.getLoggedUser().userId) ?? "",
                sensorId: UUID().uuidString,
                data: DataModel.mockModels
            ),
            DataHistoryModel(
                id: UUID().uuidString,
                userId: (try? AuthManager.shared.getLoggedUser().userId) ?? "",
                sensorId: UUID().uuidString,
                data: DataModel.mockModels
            )
        ]
    }
    
    static var mockDataHistoriesDictionary: [String: DataHistoryModel] {
        let firstModelId = UUID().uuidString
        let secondModelId = UUID().uuidString
        let thirdModelId = UUID().uuidString
        let fourthModelId = UUID().uuidString
        
        return [
            firstModelId: DataHistoryModel(
                id: UUID().uuidString,
                userId: (try? AuthManager.shared.getLoggedUser().userId) ?? "",
                sensorId: firstModelId,
                data: DataModel.mockModels
            ),
            secondModelId: DataHistoryModel(
                id: UUID().uuidString,
                userId: (try? AuthManager.shared.getLoggedUser().userId) ?? "",
                sensorId: secondModelId,
                data: DataModel.mockModels
            ),
            thirdModelId: DataHistoryModel(
                id: UUID().uuidString,
                userId: (try? AuthManager.shared.getLoggedUser().userId) ?? "",
                sensorId: thirdModelId,
                data: DataModel.mockModels
            ),
            fourthModelId: DataHistoryModel(
                id: UUID().uuidString,
                userId: (try? AuthManager.shared.getLoggedUser().userId) ?? "",
                sensorId: fourthModelId,
                data: DataModel.mockModels
            )
        ]
    }
}
