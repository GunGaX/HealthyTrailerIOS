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
}

final class FirestoreManager {
    static let shared = FirestoreManager()
    private init() {}
        
    //MARK: - Users flow
    private let usersCollection = Firestore.firestore().collection(FirestoreCollections.users.rawValue)
    
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
}
