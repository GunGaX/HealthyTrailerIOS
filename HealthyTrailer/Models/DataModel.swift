//
//  DataModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 18.05.2025.
//

import Foundation

struct DataModel: Codable {
    let id: String
    let date: Date
    let temperature: Double
    let pressure: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case date = "date"
        case temperature = "temperature"
        case pressure = "pressure"
        
    }
    
    init(id: String, date: Date, temperature: Double, pressure: Double) {
        self.id = id
        self.date = date
        self.temperature = temperature
        self.pressure = pressure
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.date = try container.decode(Date.self, forKey: .date)
        self.temperature = try container.decode(Double.self, forKey: .temperature)
        self.pressure = try container.decode(Double.self, forKey: .pressure)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(pressure, forKey: .pressure)
    }
}

extension DataModel {
    static var mockModels: [DataModel] {
        [
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T00:00:00Z")!, temperature: 51.2, pressure: 1012.5),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T01:00:00Z")!, temperature: 53.8, pressure: 1011.2),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T02:00:00Z")!, temperature: 56.1, pressure: 1013.6),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T03:00:00Z")!, temperature: 58.5, pressure: 1009.9),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T04:00:00Z")!, temperature: 60.0, pressure: 1010.7),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T05:00:00Z")!, temperature: 62.4, pressure: 1012.0),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T06:00:00Z")!, temperature: 65.1, pressure: 1011.1),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T07:00:00Z")!, temperature: 67.3, pressure: 1008.5),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T08:00:00Z")!, temperature: 69.0, pressure: 1010.0),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T09:00:00Z")!, temperature: 70.5, pressure: 1011.8),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T10:00:00Z")!, temperature: 73.0, pressure: 1012.3),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T11:00:00Z")!, temperature: 75.6, pressure: 1013.2),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T12:00:00Z")!, temperature: 78.4, pressure: 1014.0),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T13:00:00Z")!, temperature: 81.0, pressure: 1015.2),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T14:00:00Z")!, temperature: 83.7, pressure: 1016.1),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T15:00:00Z")!, temperature: 86.9, pressure: 1017.5),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T16:00:00Z")!, temperature: 89.1, pressure: 1018.3),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T17:00:00Z")!, temperature: 91.4, pressure: 1015.9),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-17T18:00:00Z")!, temperature: 94.8, pressure: 1013.8),
            
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-16T00:00:00Z")!, temperature: 52.3, pressure: 1012.1),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-16T01:00:00Z")!, temperature: 54.8, pressure: 1011.0),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-16T02:00:00Z")!, temperature: 57.1, pressure: 1010.6),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-16T03:00:00Z")!, temperature: 60.4, pressure: 1009.4),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-16T04:00:00Z")!, temperature: 62.0, pressure: 1008.9),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-16T05:00:00Z")!, temperature: 65.5, pressure: 1007.6),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-16T06:00:00Z")!, temperature: 67.2, pressure: 1006.7),
            
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T00:00:00Z")!, temperature: 52.1, pressure: 1005.8),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T01:00:00Z")!, temperature: 55.6, pressure: 1004.3),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T02:00:00Z")!, temperature: 58.2, pressure: 1003.0),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T03:00:00Z")!, temperature: 61.4, pressure: 1002.1),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T04:00:00Z")!, temperature: 64.7, pressure: 1001.9),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T05:00:00Z")!, temperature: 68.3, pressure: 1001.0),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T06:00:00Z")!, temperature: 70.5, pressure: 1000.2),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T07:00:00Z")!, temperature: 73.8, pressure: 999.5),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T08:00:00Z")!, temperature: 76.1, pressure: 998.7),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T09:00:00Z")!, temperature: 78.9, pressure: 998.1),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T10:00:00Z")!, temperature: 81.2, pressure: 997.8),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T11:00:00Z")!, temperature: 83.6, pressure: 997.1),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-14T12:00:00Z")!, temperature: 86.4, pressure: 996.3),
            
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-13T00:00:00Z")!, temperature: 51.7, pressure: 995.9),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-13T01:00:00Z")!, temperature: 54.2, pressure: 995.2),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-13T02:00:00Z")!, temperature: 56.8, pressure: 994.6),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-13T03:00:00Z")!, temperature: 59.4, pressure: 994.0),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-13T04:00:00Z")!, temperature: 62.0, pressure: 993.3),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-13T05:00:00Z")!, temperature: 64.5, pressure: 993.0),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-13T06:00:00Z")!, temperature: 67.1, pressure: 992.5),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-13T07:00:00Z")!, temperature: 69.6, pressure: 992.0),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-13T08:00:00Z")!, temperature: 72.2, pressure: 991.7),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-13T09:00:00Z")!, temperature: 74.8, pressure: 991.3),
            DataModel(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-13T10:00:00Z")!, temperature: 77.3, pressure: 990.8),
        ]
    }
}
