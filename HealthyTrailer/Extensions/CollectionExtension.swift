//
//  CollectionExtension.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 11.05.2025.
//

import Foundation

extension Collection where Element: Equatable {
    func next(_ element: Element) -> Element? {
        guard let index = firstIndex(of: element) else {
            return nil
        }
        
        return self[safe: self.index(index, offsetBy: 1)]
    }
    
    func previous(_ element: Element) -> Element? {
        guard let index = firstIndex(of: element) else {
            return nil
        }
        
        return self[safe: self.index(index, offsetBy: -1)]
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
