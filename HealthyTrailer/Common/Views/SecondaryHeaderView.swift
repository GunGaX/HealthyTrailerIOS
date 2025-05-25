//
//  SecondaryHeaderView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct SecondaryHeaderView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    let titleText: String
 
    var body: some View {
        HStack(spacing: 42) {
            arrowBackButton
            title
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .padding(.top, ScreenUtils.statusBarHeight)
        .frame(height: 120)
        .headerShadowRectangle()
    }
    
    private var title: some View {
        Text(.init(titleText))
            .foregroundStyle(Color.black)
            .font(.roboto700, size: 18)
    }
    
    private var arrowBackButton: some View {
        Button {
            navigationManager.removeLast()
        } label: {
            Image(systemName: "arrow.left")
                .resizable()
                .scaledToFit()
                .frame(width: 20)
                .bold()
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    VStack {
        SecondaryHeaderView(titleText: "Settings")
            .environmentObject(NavigationManager())
        Spacer()
    }
    .ignoresSafeArea(.container, edges: .top)
}
