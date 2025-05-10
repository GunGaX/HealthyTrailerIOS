//
//  AuthViewModel.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 11.05.2025.
//

import Foundation
import FirebaseAuth

enum AuthType: String, CaseIterable, Identifiable, Equatable, Codable {
    var id: String { rawValue }
    
    case signUp, signIn
    
    var title: String {
        switch self {
        case .signUp: "Sign Up"
        case .signIn: "Log In"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .signUp: "Sign up"
        case .signIn: "Log in"
        }
    }
    
    var alternativeOptionTitle: String {
        switch self {
        case .signUp: "Already have an account?"
        case .signIn: "Don't have an account?"
        }
    }
    
    var alternativeOptionButtonTitle: String {
        switch self {
        case .signUp: "Log in"
        case .signIn: "Sign up"
        }
    }
    
    mutating func toggle() {
        switch self {
        case .signUp: self = .signIn
        case .signIn: self = .signUp
        }
    }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published public var authType = AuthType.signIn
    
    @Published public var email = ""
    @Published public var password = ""
    @Published public var confirmPassword = ""
    @Published var isAgree: Bool = false

    func isValidEmail() -> Bool {
        return Validator.isValidEmail(email)
    }
    
    func isValidPassword() -> Bool {
        return Validator.isValidPassword(password)
    }
    
    func isValidConfirmPassword() -> Bool {
        return password == confirmPassword
    }
    
    func isAuthButtonDisable() -> Bool {
        switch authType {
        case .signUp:
            return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
            && isValidEmail() && isValidPassword() && isValidConfirmPassword()
        case .signIn:
            return !email.isEmpty && !password.isEmpty
            && isValidEmail() && isValidPassword()
        }
    }
    
    func signUp(completion: @escaping (UserModel?, String?) -> ()) {
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        
        Task {
            do {
                let userModel = try await AuthManager.shared.signUp(email: email, password: password)
                completion(userModel, nil)
            } catch {
                completion(nil, error.localizedDescription)
                print("[AuthViewModel] Error signUP: \(error)")
            }
        }
    }
    
    func signIn(_ navigationManager: NavigationManager, completion: @escaping (UserModel?, String?) -> ()) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(nil, "Email and password cannot be empty.")
            return
        }
        
        Task {
            do {
                let userModel = try await AuthManager.shared.signIn(email: email, password: password)
                completion(userModel, nil)
            } catch {
                print("[AuthViewModel] Error signIn: \(error)")
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    func resetPassword(completion: @escaping (String?) -> ()) {
        guard !email.isEmpty else {
            return
        }
        
        Task {
            do {
                try await AuthManager.shared.resetPassword(email: email)
                completion(nil)
            } catch {
                print("[AuthViewModel] Error reset password: \(error)")
                completion(error.localizedDescription)
            }
        }
    }
    
    func signInGoogle(_ navigationManager: NavigationManager, completion: @escaping (UserModel?, String?) -> ()) {
        Task {
            do {
                let helper = SignInGoogleHelper()
                let tokens = try await helper.signIn()
                let userModel = try await AuthManager.shared.signInWithGoogle(tokens: tokens)
                completion(userModel.user, nil)
            } catch {
                print("[AuthViewModel] Error signInGoogle: \(error)")
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    func signInApple(_ navigationManager: NavigationManager, completion: @escaping (UserModel?, Error?) -> ()) {
        let appleAuthService = AppleAuthService()

        Task {
            do {
                let authResult = try await appleAuthService.login()
                let authModel = UserModel(userId: authResult.0.user.uid, firstName: "", lastName: "", emailAdress: authResult.0.user.email ?? "")
                try await AuthManager.shared.signInWithApple(authModel)
                completion(authModel, nil)
            } catch {
                completion(nil, error)
                print("[AuthViewModel] Error signInApple: \(error)")
            }
        }
    }
}
