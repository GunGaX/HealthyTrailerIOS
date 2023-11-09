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
    
    @Published var axis = [1, 2, 3, 4]
}
