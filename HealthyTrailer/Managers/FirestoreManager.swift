//
//  FirestoreManager.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 04.05.2025.
//

import Foundation
import FirebaseFirestore

enum FirestoreCollections: String {
    case users = "users"
    case data = "data"
    case settings = "settings"
}

final class FirestoreManager {
    static let shared = FirestoreManager()
    private init() {}
    
    private let usersCollection = Firestore.firestore().collection(FirestoreCollections.users.rawValue)
    private let dataCollection = Firestore.firestore().collection(FirestoreCollections.data.rawValue)
    private let settingsCollection = Firestore.firestore().collection(FirestoreCollections.settings.rawValue)
    
    private func userDocument(userID: String) -> DocumentReference {
        usersCollection.document(userID)
    }
    
    private func settingsDocument(id: String) -> DocumentReference {
        settingsCollection.document(id)
    }
    
    private func dataDocument(id: String) -> DocumentReference {
        dataCollection.document(id)
    }
    
    func createUser(user: UserModel) async throws {
        try userDocument(userID: user.userId)
            .setData(from: user, merge: true)
    }
    
    func getUser(userID: String) async throws -> UserModel {
        try await userDocument(userID: userID)
            .getDocument(as: UserModel.self)
    }
    
    func updateUser(userID: String, fields: [String: Any]) async throws {
        try await userDocument(userID: userID)
            .updateData(fields)
    }
    
    func addOrUpdateDataHistory(_ newData: DataHistoryModel) async throws {
        let querySnapshot = try await dataCollection
            .whereField("id", isEqualTo: newData.id)
            .whereField("user_id", isEqualTo: newData.userId)
            .whereField("sensor_id", isEqualTo: newData.sensorId)
            .getDocuments()
        
        if let document = querySnapshot.documents.first {
            var existing = try document.data(as: DataHistoryModel.self)
            existing.data += newData.data
            
            try dataDocument(id: existing.id).setData(from: existing, merge: true)
        } else {
            try dataDocument(id: newData.id).setData(from: newData)
        }
    }
    
    func deleteDataHistory(id: String) async throws {
        try await dataDocument(id: id).delete()
    }
    
    func getDataHistory(userId: String, sensorId: String) async throws -> DataHistoryModel? {
        let querySnapshot = try await dataCollection
            .whereField("user_id", isEqualTo: userId)
            .whereField("sensor_id", isEqualTo: sensorId)
            .getDocuments()
        
        if let document = querySnapshot.documents.first {
            let data = try document.data(as: DataHistoryModel.self)
            return data
        } else {
            return nil
        }
    }
    
    func updateSettings(userID: String, fields: [String: Any]) async throws {
        let querySnapshot = try await settingsCollection
            .whereField("user_id", isEqualTo: userID)
            .getDocuments()
        
        if let document = querySnapshot.documents.first {
            try await settingsDocument(id: document.documentID).updateData(fields)
        }
    }
    
    func getSettings(userId: String) async throws -> SettingsModel? {
        let querySnapshot = try await settingsCollection
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        
        if let document = querySnapshot.documents.first {
            let data = try document.data(as: SettingsModel.self)
            return data
        } else {
            return nil
        }
    }
    
    func deleteSettings(id: String) async throws {
        try await settingsDocument(id: id).delete()
    }
}
