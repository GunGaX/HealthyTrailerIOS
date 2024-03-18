//
//  ChartDataModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import Foundation

struct ChartData: Identifiable, Equatable {
    let time: Int
    let value: Double
    
    var id: Int { time }
    static var mockArray: [ChartData] {
        [ChartData(time: 0, value: 56.1),
         ChartData(time: 1, value: 72.5),
         ChartData(time: 2, value: 74.5),
         ChartData(time: 3, value: 24.2),
         ChartData(time: 4, value: 26.1),
         ChartData(time: 5, value: 34.1),
         ChartData(time: 6, value: 36.5)
        ]
    }
    
    static var tempArray: [Double] {
        [56.1, 72.5, 74.5, 24.2, 26.1, 34.1, 36.5]
    }
}
