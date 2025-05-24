//
//  SettingsModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 24.05.2025.
//

import Foundation

struct SettingsModel: Codable {
    let userId: String
    let axiesCount: Int
    let vehicleType: VehicleType
    let notificationSound: NotificationSound?
    let selectedTemperatureType: TemperatureType?
    let selectedPreassureType: PreasureType?
    let maxTPMSSensorTemperature: Double?
    let maxDifferenceTPMSSensorTemperature: Double?
    let preassureMinValue: Double?
    let preassureMaxValue: Double?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case axiesCount = "axies_count"
        case vehicleType = "vehicle_type"
        case notificationSound = "notification_sound"
        case selectedTemperatureType = "selected_temperature_type"
        case selectedPreassureType = "selected_preassure_type"
        case maxTPMSSensorTemperature = "max_tpms_sensor_temperature"
        case maxDifferenceTPMSSensorTemperature = "max_difference_tpms_sensor_temperature"
        case preassureMinValue = "preassure_min_value"
        case preassureMaxValue = "preassure_max_value"
    }
    
    init(userId: String, axiesCount: Int, vehicleType: VehicleType, notificationSound: NotificationSound, selectedTemperatureType: TemperatureType, selectedPreassureType: PreasureType, maxTPMSSensorTemperature: Double, maxDifferenceTPMSSensorTemperature: Double, preassureMinValue: Double, preassureMaxValue: Double) {
        self.userId = userId
        self.axiesCount = axiesCount
        self.vehicleType = vehicleType
        self.notificationSound = notificationSound
        self.selectedTemperatureType = selectedTemperatureType
        self.selectedPreassureType = selectedPreassureType
        self.maxTPMSSensorTemperature = maxTPMSSensorTemperature
        self.maxDifferenceTPMSSensorTemperature = maxDifferenceTPMSSensorTemperature
        self.preassureMinValue = preassureMinValue
        self.preassureMaxValue = preassureMaxValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.userId = try container.decode(String.self, forKey: .userId)
        self.axiesCount = try container.decode(Int.self, forKey: .axiesCount)
        self.vehicleType = try container.decode(VehicleType.self, forKey: .vehicleType)
        self.notificationSound = try? container.decode(NotificationSound.self, forKey: .notificationSound)
        self.selectedTemperatureType = try? container.decode(TemperatureType.self, forKey: .selectedTemperatureType)
        self.selectedPreassureType = try? container.decode(PreasureType.self, forKey: .selectedPreassureType)
        self.maxTPMSSensorTemperature = try? container.decode(Double.self, forKey: .maxTPMSSensorTemperature)
        self.maxDifferenceTPMSSensorTemperature = try? container.decode(Double.self, forKey: .maxDifferenceTPMSSensorTemperature)
        self.preassureMinValue = try? container.decode(Double.self, forKey: .preassureMinValue)
        self.preassureMaxValue = try? container.decode(Double.self, forKey: .preassureMaxValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(userId, forKey: .userId)
        try container.encode(axiesCount, forKey: .axiesCount)
        try container.encode(vehicleType, forKey: .vehicleType)
        try container.encode(notificationSound, forKey: .notificationSound)
        try container.encode(selectedTemperatureType, forKey: .selectedTemperatureType)
        try container.encode(selectedPreassureType, forKey: .selectedPreassureType)
        try container.encode(maxTPMSSensorTemperature, forKey: .maxTPMSSensorTemperature)
        try container.encode(maxDifferenceTPMSSensorTemperature, forKey: .maxDifferenceTPMSSensorTemperature)
        try container.encode(preassureMinValue, forKey: .preassureMinValue)
        try container.encode(preassureMaxValue, forKey: .preassureMaxValue)
    }
}
