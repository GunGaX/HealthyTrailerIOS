//
//  UserTypeView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 04.05.2025.
//

import SwiftUI

struct UserTypeView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var isCentered = true
    
    var body: some View {
        NavigationStack(path: $navigationManager.authPath) {
            VStack {
                Spacer()
                VStack(spacing: 16) {
                    image
                    title
                }
                .scaleEffect(isCentered ? 1.0 : 0.75)
                .offset(y: isCentered ? 0 : -UIScreen.main.bounds.height / 4.5)
                .animation(.easeInOut(duration: 0.75), value: isCentered)
                Spacer()
                if !isCentered {
                    buttons
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        isCentered = false
                    }
                }
            }
            .navigationDestinations()
        }
    }
    
    private var image: some View {
        Image("imageAppIcon")
            .resizable()
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    @ViewBuilder
    private var title: some View {
        if !isCentered {
            Text(.init("Welcome to Healthy Trailer App"))
                .font(.roboto400, size: 22)
                .foregroundStyle(Color.mainBlue)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    private var buttons: some View {
        VStack(spacing: 16) {
            Button {
                navigationManager.append(AuthViewPathItem(authType: .signIn))
            } label: {
                Text("Login")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.mainBlueButton)
            Button {
                navigationManager.append(AuthViewPathItem(authType: .signUp))
            } label: {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.mainBlueButton)
        }
        .padding(.horizontal, 48)
        .padding(.bottom, 27)
    }
}
