//
//  MainViewModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation

final class MainViewModel: ObservableObject {
    @Published var isTWDConnected = false
    @Published var displayingMode = true
    
    @Published var selectedSound: NotificationSound = .chime
    @Published var selectedTemperatureType: TemperatureType = .celsius
    @Published var selectedPreassureType: PreasureType = .bar
    
    @Published var axis = [
        AxiesData(axisNumber: 1, leftTire: TireData(temperature: 34.2, avgTemperature: 43.6), rightTire: TireData(temperature: 32.9, avgTemperature: 41.3)),
        AxiesData(axisNumber: 2, leftTire: TireData(temperature: 34.2, avgTemperature: 43.6), rightTire: TireData(temperature: 32.9, avgTemperature: 41.3)),
        AxiesData(axisNumber: 3, leftTire: TireData(temperature: 34.2, avgTemperature: 43.6), rightTire: TireData(temperature: 32.9, avgTemperature: 41.3)),
        AxiesData(axisNumber: 4, leftTire: TireData(temperature: 34.2, avgTemperature: 43.6), rightTire: TireData(temperature: 32.9, avgTemperature: 41.3))
    ]
}
