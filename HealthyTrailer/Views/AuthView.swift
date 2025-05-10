//
//  AuthView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 11.05.2025.
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    enum FocusableField: Int, CaseIterable, Hashable {
        case email, password, confirmPassword
    }
    
    let authType: AuthType
    @Environment(\.openURL) var openURL
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusedField: FocusableField?
    @State private var isValidEmail: Bool = true
    @State private var isValidPass: Bool = true
    @State private var isValidConfirmPass: Bool = true
    @State private var isAuthButtonEnable: Bool = false
    
    @State private var alert: AlertData? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                header
                Spacer()
                VStack(spacing: 24) {
                    email
                    password
                    confirmPassword
                }
                .onSubmit(nextTextfield)
                Spacer()
                VStack(spacing: 16) {
                    authButton
                    orTitle
                    googleAuthButton
                    appleAuthButton
                }
                Spacer()
                footer
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 27)
        .background(.white)
        .alert(item: $alert) { data in
            Alert(
                title: Text(data.title),
                message: Text(data.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.authType = authType
        }
    }
    
    private var header: some View {
        VStack(spacing: 0) {
            Image("imageAppIcon")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text("Welcome")
                .font(.roboto400, size: 18)
                .foregroundStyle(Color.grayBA)
                .padding(.top, 16)
            Text(viewModel.authType.title)
                .font(.roboto700, size: 28)
                .foregroundStyle(Color.green11)
                .padding(.top, 4)
        }
    }
    
    @ViewBuilder
    private var email: some View {
        VStack {
            AuthTextField(
                text: $viewModel.email,
                placeholder: "Email",
                isSecure: false,
                isFocused: focusedField == .email
            )
            .focused($focusedField, equals: .email)
            .onChange(of: viewModel.email) { newValue in
                if !viewModel.email.isEmpty {
                    withAnimation {
                        isValidEmail = viewModel.isValidEmail()
                        isAuthButtonEnable = viewModel.isAuthButtonDisable()
                    }
                } else {
                    isValidEmail = true
                    isAuthButtonEnable = viewModel.isAuthButtonDisable()
                }
            }
            if !isValidEmail {
                validationErrorMessage(message: "*Please enter a valid email address")
            }
        }
    }
    
    @ViewBuilder
    private var password: some View {
        VStack(spacing: 0) {
            if viewModel.authType == .signUp {
                Text("Password")
                    .font(.roboto400, size: 12)
                    .foregroundStyle(Color.grayBA)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
            }
            AuthTextField(
                text: $viewModel.password,
                placeholder: "Password",
                isSecure: true,
                isFocused: focusedField == .password
            )
            .focused($focusedField, equals: .password)
            .onChange(of: viewModel.password) { newValue in
                if !viewModel.password.isEmpty {
                    withAnimation {
                        isValidPass = viewModel.isValidPassword()
                        isAuthButtonEnable = viewModel.isAuthButtonDisable()
                    }
                } else {
                    isValidPass = true
                    isAuthButtonEnable = viewModel.isAuthButtonDisable()
                }
            }
            if !isValidPass {
                validationErrorMessage(message: "*Must be at least 8 characters long, include a lowercase letter, an uppercase letter, a number, and a special character")
            }
            if viewModel.authType == .signIn {
                forgotPassword
            }
        }
    }
    
    @ViewBuilder
    private var confirmPassword: some View {
        if viewModel.authType == .signUp {
            VStack(spacing: 0) {
                Text("Confirm Password")
                    .font(.roboto400, size: 12)
                    .foregroundStyle(Color.grayBA)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                AuthTextField(
                    text: $viewModel.confirmPassword,
                    placeholder: "Confirm password",
                    isSecure: true,
                    isFocused: focusedField == .confirmPassword
                )
                .focused($focusedField, equals: .confirmPassword)
                .onChange(of: viewModel.confirmPassword) { newValue in
                    if !viewModel.confirmPassword.isEmpty {
                        withAnimation {
                            isValidConfirmPass = viewModel.isValidConfirmPassword()
                            isAuthButtonEnable = viewModel.isAuthButtonDisable()
                        }
                    } else {
                        isValidConfirmPass = true
                        isAuthButtonEnable = viewModel.isAuthButtonDisable()
                    }
                }
                if !isValidConfirmPass {
                    validationErrorMessage(message: "*Passwords must match.")
                }
            }
        }
    }
    
    @ViewBuilder
    private var forgotPassword: some View {
        if viewModel.authType == .signIn {
            Button {
                navigationManager.append(ResetPasswordViewPathItem())
            } label: {
                Text("Forgot password?")
                    .font(.roboto500, size: 18)
                    .foregroundStyle(Color.green11)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
    }

    private var authButton: some View {
        Button {
            authAction()
        } label: {
            Text(viewModel.authType.buttonTitle)
        }
        .buttonStyle(PrimaryWithBackgroundButtonStyle(disabled: !isAuthButtonEnable))
        .disabled(!isAuthButtonEnable)
    }
    
    private var googleAuthButton: some View {
        Button {
            signInGoogleAction()
        } label: {
            HStack(spacing: 6) {
                Image("google")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("Log in with Google")
            }
        }
        .buttonStyle(.socialLogin)
        .padding(1)
    }
    
    private var orTitle: some View {
        Text("or")
            .font(.roboto500, size: 18)
            .foregroundStyle(.black)
    }
    
    private var appleAuthButton: some View {
        Button {
            signInAppleAction()
        } label: {
            HStack(spacing: 6) {
                Image("apple")
                    .resizable()
                    .frame(width: 18, height: 22)
                Text("Log in with Apple")
            }
        }
        .buttonStyle(.socialLogin)
        .padding(1)
    }
    
    private var footer: some View {
        HStack(spacing: 4) {
            Text(viewModel.authType.alternativeOptionTitle)
                .font(.roboto400, size: 18)
                .foregroundStyle(Color.gray41)
            Button {
                withAnimation {
                    viewModel.authType.toggle()
                    isAuthButtonEnable = viewModel.isAuthButtonDisable()
                }
            } label: {
                Text(viewModel.authType.alternativeOptionButtonTitle)
                    .font(.roboto500, size: 18)
                    .foregroundStyle(Color.green11)
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func validationErrorMessage(message: String) -> some View {
        Text(message)
            .font(.roboto400, size: 12)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func nextTextfield() {
        guard let focusedField else { return }
        self.focusedField = FocusableField.allCases.next(focusedField)
    }
    
    private func authAction() {
        if viewModel.authType == .signUp {
            viewModel.signUp { user, errorMessage in
                if user != nil {
                    DispatchQueue.main.async {
                        navigationManager.resetCurrentPath()
                        navigationManager.appState = .app
                    }
                } else {
                    showToast(withError: errorMessage)
                }
            }
        } else {
            viewModel.signIn(navigationManager) { user, errorMessage in
                if user != nil {
                    DispatchQueue.main.async {
                        navigationManager.resetCurrentPath()
                        navigationManager.appState = .app
                    }
                } else {
                    showToast(withError: errorMessage)
                }
            }
        }
    }
    
    private func signInGoogleAction() {
        viewModel.signInGoogle(navigationManager) { userModel, errorMessage in
            if userModel != nil {
                DispatchQueue.main.async {
                    navigationManager.resetCurrentPath()
                    navigationManager.appState = .app
                }
            } else {
                showToast(withError: errorMessage)
            }
        }
    }
    
    private func signInAppleAction() {
        viewModel.signInApple(navigationManager) { userModel, error in
            guard error == nil else {
                if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                    showToast(withError: "The user cancelled the sign-in flow.")
                } else {
                    showToast(withError: error?.localizedDescription ?? "An unknown error occurred.")
                }
                
                return
            }
            
            guard userModel != nil else {
                return
            }
            
            DispatchQueue.main.async {
                navigationManager.resetCurrentPath()
                navigationManager.appState = .app
            }
        }
    }
    
    private func showToast(withError error: String?) {
        if let message = error {
            alert = AlertData(title: "Attention", message: message)
        }
    }
}
