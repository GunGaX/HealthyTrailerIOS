//
//  AppleAuthService.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 11.05.2025.
//

import Foundation
import CryptoKit
import SwiftUI
import AuthenticationServices
import FirebaseAuth

class AppleAuthService: NSObject {
    private var currentNonce: String?
    private var loginContinuation: CheckedContinuation<(AuthDataResult, String?), Error>?
    
    public func login() async throws -> (AuthDataResult, String?) {
        currentNonce = String.randomNonceString
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = currentNonce?.sha256

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        return try await withCheckedThrowingContinuation { continuation in
            if loginContinuation != nil {
                loginContinuation!.resume(throwing: RuntimeError("Unknown error"))
                loginContinuation = nil
            }
            
            loginContinuation = continuation
        }
    }
    
    private func onAuth(idTokenString: String, nonce: String) async throws -> AuthDataResult {
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
                
        print("onAuth toggled")
        let authResult = try await Auth.auth().signIn(with: credential)
        
        return authResult
    }
}

extension AppleAuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loginContinuation?.resume(throwing: error)
        
        loginContinuation = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let nonce = currentNonce,
                let identityToken = credential.identityToken,
                let idToken = String(data: identityToken, encoding: .utf8)
            else {
                loginContinuation?.resume(throwing: RuntimeError("unable To Authorize"))
                loginContinuation = nil
                return
            }
            
            do {
                let firstName = credential.fullName?.givenName
                let lastName = credential.fullName?.familyName
                let fullName = (firstName ?? "") + " " + (lastName ?? "")
                
                let result = try await onAuth(idTokenString: idToken, nonce: nonce)
                loginContinuation?.resume(returning: (result, fullName.isEmpty ? nil : fullName))
            } catch {
                loginContinuation?.resume(throwing: error)
            }
            
            loginContinuation = nil
        }
    }
}

extension AppleAuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
}


extension String {
    static var randomNonceString: String {
        let length = 32
        var randomBytes = [UInt8](repeating: 0, count: length)
        
        let errorCode = SecRandomCopyBytes(
            kSecRandomDefault,
            randomBytes.count,
            &randomBytes
        )
        
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    public var sha256: String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

struct RuntimeError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}
