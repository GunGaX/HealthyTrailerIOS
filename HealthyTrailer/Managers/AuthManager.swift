//
//  AuthManager.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 04.05.2025.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    func signUp(email: String, password: String) async throws -> UserModel? {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        if let user = authDataResult.user.getModel() {
            try await FirestoreManager.shared.createUser(user: user)
        }
        return authDataResult.user.getModel()
    }
    
    func signIn(email: String, password: String) async throws -> UserModel? {
        try await Auth.auth().signIn(withEmail: email, password: password)
        return Auth.auth().currentUser?.getModel()
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> (user: UserModel?, isNew: Bool) {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)

        let authDataResult = try await Auth.auth().signIn(with: credential)
        if let _ = try? await FirestoreManager.shared.getUser(userID: authDataResult.user.uid) {
            return try await (loginWithGoogle(authDataResult), false)
        } else {
            return try await (signUpWithGoogle(authDataResult: authDataResult), true)
        }
    }

    func loginWithGoogle(_ authDataResult: AuthDataResult) async throws -> UserModel? {
        return authDataResult.user.getModel()
    }

    func signUpWithGoogle(authDataResult: AuthDataResult) async throws -> UserModel? {
        guard let userModel = authDataResult.user.getModel() else { return nil }
        
        try await FirestoreManager.shared.createUser(user: userModel)

        return userModel
    }
    
    func signInWithApple(_ user: UserModel) async throws -> (user: UserModel?, isNew: Bool) {
        if let _ = try? await FirestoreManager.shared.getUser(userID: user.userId) {
            return try await (loginWithApple(user), false)
        } else {
            return try await (signUpWithApple(user), true)
        }
    }
    
    func loginWithApple(_ user: UserModel) async throws -> UserModel? {
        return user
    }
    
    func signUpWithApple(_ user: UserModel) async throws -> UserModel? {
        try await FirestoreManager.shared.createUser(user: user)

        return user
    }
    
    func reloadUser() async throws {
        try await Auth.auth().currentUser?.reload()
    }
    
    func getLoggedUser() throws -> UserModel {
        guard let user = Auth.auth().currentUser, let userModel = user.getModel() else {
            throw URLError(.badServerResponse)
        }
        return userModel
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func logOut() throws {
        try Auth.auth().signOut()
    }
}

extension User {
    func getModel() -> UserModel? {
        guard let email = self.email else { return nil }
        
        let names = self.getFirstAndLastName()
        
        return UserModel(
            userId: self.uid,
            firstName: names.fistName ?? "",
            lastName: names.lastName ?? "",
            emailAdress: email,
            axiesCount: nil
        )
    }
    
    func getModel(withFullName name: String?) -> UserModel? {
        guard let email = self.email else { return nil }
        
        let names = self.getFirstAndLastName(from: name)
        
        return UserModel(
            userId: self.uid,
            firstName: names.fistName ?? "",
            lastName: names.lastName ?? "",
            emailAdress: email,
            axiesCount: nil
        )
    }
    
    func getFirstAndLastName() -> (fistName: String?, lastName: String?) {
        var firstName: String?
        var lastName: String?
        
        if let displayName = self.displayName {
            let components = displayName.split(separator: " ")
            if components.count == 2 {
                firstName = components.first?.description
                lastName = components.last?.description
            } else {
                firstName = displayName
                lastName = nil
            }
        } else {
            firstName = nil
            lastName = nil
        }
        
        return (firstName, lastName)
    }
    
    func getFirstAndLastName(from fullName: String?) -> (fistName: String?, lastName: String?) {
        var firstName: String?
        var lastName: String?
        
        if let displayName = fullName {
            let components = displayName.split(separator: " ")
            if components.count == 2 {
                firstName = components.first?.description
                lastName = components.last?.description
            } else {
                firstName = displayName
                lastName = nil
            }
        } else {
            firstName = nil
            lastName = nil
        }
        
        return (firstName, lastName)
    }
}
