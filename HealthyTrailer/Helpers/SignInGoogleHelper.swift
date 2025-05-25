//
//  SignInGoogleHelper.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 04.05.2025.
//

import Foundation
import GoogleSignIn

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let imageUrlString: String?
}

@MainActor
final class SignInGoogleHelper {
    func signIn() async throws -> GoogleSignInResultModel {
        guard let topVC = UIApplication.shared.topViewController() else {
            throw URLError(.badServerResponse)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        let firstName = gidSignInResult.user.profile?.givenName
        let lastName = gidSignInResult.user.profile?.familyName
        let email = gidSignInResult.user.profile?.email
//        let photoUrl = gidSignInResult.user.profile?.imageURL(withDimension: 400)?.absoluteString
        
        let tokens = GoogleSignInResultModel(
            idToken: idToken,
            accessToken: accessToken,
            firstName: firstName,
            lastName: lastName,
            email: email,
            imageUrlString: nil
        )
        return tokens
    }
}
