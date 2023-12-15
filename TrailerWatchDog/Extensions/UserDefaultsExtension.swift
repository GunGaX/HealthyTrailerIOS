//
//  UserDefaultsExtension.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 28.11.2023.
//

import Foundation

extension UserDefaults {
  func setObject<Object: Encodable>(_ object: Object, forKey: String) {
    let encoder = JSONEncoder()
     
    do {
      let data = try encoder.encode(object)
      set(data, forKey: forKey)
       
      print("[Success][UserDefaults] saved object")
    } catch {
      print("[Error][UserDefaults] setObject: \(error)")
    }
  }
   
  func getObject<Object: Decodable>(forKey: String, castTo type: Object.Type) -> Object? {
    guard let data = data(forKey: forKey) else { return nil }
     
    let decoder = JSONDecoder()
     
    do {
      let object = try decoder.decode(type, from: data)
      print("[Success][UserDefaults] got object")
      return object
    } catch {
      print("[Error][UserDefaults] get object: \(error)")
      return nil
    }
  }
   
  func remove(key: String) {
    self.removeObject(forKey: key)
  }
}
