//
//  AttentionAlertView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 27.02.2024.
//

import SwiftUI

struct AttentionAlertView: ViewModifier {
    @Binding public var showAlert: Bool
    
    var messageText: String
    
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
            AttentionView(showAlert: $showAlert, messageText: messageText)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .transition(.opacity.combined(with: .scale(scale: 0.5)))
                .padding(.horizontal)
        }
    }
}

struct AttentionView: View {
    @Binding var showAlert: Bool
        
    var messageText: String
    
    var body: some View {
        VStack(spacing: 14) {
            title
            confirmationText
            okButton
            .padding(.top, 12)
        }
        .padding()
    }
    
    private var title: some View {
        Text("Attention!")
            .font(.roboto500, size: 20)
            .foregroundStyle(Color.mainRed)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var confirmationText: some View {
        Text(messageText)
            .font(.roboto500, size: 14)
            .foregroundStyle(Color.textDark)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var okButton: some View {
        Button {
            showAlert = false
        } label: {
            Text("OK")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.mainRed)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
