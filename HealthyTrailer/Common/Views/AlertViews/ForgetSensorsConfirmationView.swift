//
//  ForgetSensorsConfirmationView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.01.2024.
//

import SwiftUI

struct ForgetSensorsConfirmationAlertView: ViewModifier {
    @Binding public var showAlert: Bool
    
    var onButtonTap: () -> Void
    
    func body(content: Content) -> some View { content
        .overlay(contentOverlay)
        .overlay(alert)
        .animation(.spring(), value: showAlert)
    }
    
    @ViewBuilder
    private var contentOverlay: some View {
        if showAlert {
            Color.black
                .opacity(0.5)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var alert: some View {
        if showAlert {
            ForgetSensorsConfirmationView(showAlert: $showAlert, onButtonTap: onButtonTap)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .transition(.opacity.combined(with: .scale(scale: 0.5)))
                .padding(.horizontal)
        }
    }
}

struct ForgetSensorsConfirmationView: View {
    @Binding var showAlert: Bool
    
    var onButtonTap: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            title
            confirmationText
            
            HStack(spacing: 20) {
                Spacer()
                cancelButton
                yesButton
            }
            .padding(.top, 20)
        }
        .padding()
    }
    
    private var title: some View {
        Text("Forget TPMS sensors")
            .font(.roboto500, size: 20)
            .foregroundStyle(Color.mainRed)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var confirmationText: some View {
        Text("Are you sure you want to forgot all TMPS sensors assigned to this trailer?")
            .font(.roboto500, size: 14)
            .foregroundStyle(Color.textDark)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var cancelButton: some View {
        Button {
            showAlert = false
        } label: {
            Text("Cancel")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.mainGrey)
        }
    }
    
    private var yesButton: some View {
        Button {
            showAlert = false
            onButtonTap()
        } label: {
            Text("Yes")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.mainRed)
        }
    }
}

#Preview {
    ForgetSensorsConfirmationView(showAlert: .constant(true), onButtonTap: {})
}
