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
}

final class FirestoreManager {
    static let shared = FirestoreManager()
    private init() {}
    
    //MARK: - Users flow
    private let usersCollection = Firestore.firestore().collection(FirestoreCollections.users.rawValue)
    private let dataCollection = Firestore.firestore().collection(FirestoreCollections.data.rawValue)
    
    private func userDocument(userID: String) -> DocumentReference {
        usersCollection.document(userID)
    }
    
    func createUser(user: UserModel) async throws {
        try userDocument(userID: user.userId)
            .setData(from: user, merge: true)
    }
    
    func getUser(userID: String) async throws -> UserModel {
        try await userDocument(userID: userID)
            .getDocument(as: UserModel.self)
    }
    
    private func dataDocument(id: String) -> DocumentReference {
        dataCollection.document(id)
    }
    
    func addOrUpdateDataHistory(_ newData: DataHistoryModel) async throws {
        let querySnapshot = try await dataCollection
            .whereField("id", isEqualTo: newData.id)
            .whereField("userId", isEqualTo: newData.userId)
            .whereField("sensorId", isEqualTo: newData.sensorId)
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
}
