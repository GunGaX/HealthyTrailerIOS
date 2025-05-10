//
//  ResetPasswordView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 11.05.2025.
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusedField: Bool
    @State private var isValidEmail: Bool = true
    @State private var isEnableSendButton: Bool = false
    
    @State private var alert: AlertData? = nil
    
    var body: some View {
        VStack(spacing: 32) {
            header
            emailTextfield
            sendButton
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 27)
        .background(.white)
        .onAppear {
            isEnableSendButton = viewModel.isValidEmail()
        }
        .alert(item: $alert) { data in
            Alert(
                title: Text(data.title),
                message: Text(data.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 {
                        dismiss()
                    }
                }
        )
    }
    
    private var header: some View {
        VStack(spacing: 0) {
            Image("imageAppIcon")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text("Reset Password")
                .font(.roboto700, size: 28)
                .foregroundStyle(Color.green11)
                .padding(.top, 4)
        }
    }
    
    @ViewBuilder
    private var emailTextfield: some View {
        VStack {
            AuthTextField(
                text: $viewModel.email,
                placeholder: "Email",
                isSecure: false,
                isFocused: false
            )
            .focused($focusedField)
            .onChange(of: viewModel.email) { _ in
                if !viewModel.email.isEmpty {
                    withAnimation {
                        isValidEmail = viewModel.isValidEmail()
                        isEnableSendButton = viewModel.isValidEmail()
                    }
                }
            }
            if !isValidEmail {
                Text("*Please enter a valid email address")
                    .font(.roboto400, size: 12)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    @ViewBuilder
    private var sendButton: some View {
        VStack(spacing: 16) {
            Button {
                sendResetLinkAction()
            } label: {
                Text("Continue")
            }
            .buttonStyle(PrimaryWithBackgroundButtonStyle(disabled: !isEnableSendButton))
            .disabled(!isEnableSendButton)
        }
    }
    
    private func sendResetLinkAction() {
        viewModel.resetPassword { errorMessage in
            if errorMessage != nil {
                showToast(withError: errorMessage)
            } else {
                dismiss()
            }
        }
    }
    
    private func showToast(withError error: String?) {
        if let message = error {
            alert = AlertData(title: "Attention", message: message)
        }
    }
}
