//
//  RealmManager.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 27.11.2023.
//

import Foundation
import RealmSwift

final class RealmManager {
    static let realmQueue = DispatchQueue(label: "RealmQueue", qos: .userInitiated)
    
    static func getAxisData(completion: @escaping ([AxiesData]) -> ()) {
        getData { result in
            
            let result = result
                .sorted(by: { $0.axisNumber < $1.axisNumber })
            
            let dtos = result.toDTOs()
            
            DispatchQueue.main.async {
                completion(dtos)
            }
        }
    }
    
    static func getData(completion: @escaping (Results<AxiesDataObject>) -> ()) {
        realmQueue.async {
            let realm = try! Realm()
            let result = realm.objects(AxiesDataObject.self)
            
            completion(result)
        }
    }
    
    static func saveData(_ data: AxiesData, onComplete: (() -> ())? = nil) {
        realmQueue.async {
            let realm = try! Realm()
            let dataObject = data.toObject()
            
            try! realm.write {
                realm.add(dataObject, update: .modified)
            }
            
            onComplete?()
        }
    }
}
