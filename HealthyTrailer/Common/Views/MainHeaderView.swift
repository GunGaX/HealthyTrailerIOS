//
//  MainHeaderView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 09.11.2023.
//

import SwiftUI

struct MainHeaderView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        HStack(spacing: 20) {
            title
            threeDotsIcon
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .padding(.top, ScreenUtils.statusBarHeight)
        .frame(height: 120)
        .headerShadowRectangle()
    }
    
    private var title: some View {
        Text("Healthy Trailer")
             .font(.title)
             .bold()
             .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var threeDotsIcon: some View {
        Menu {
            terminalButton
            settingsButton
        } label: {
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(90))
                .frame(width: 22, height: 22)
                .foregroundColor(.black)
                .padding(10)
                .contentShape(Rectangle())
        }
    }
    
    private var terminalButton: some View {
        Button {
            navigationManager.append(TerminalPathItem())
        } label: {
            Text("Terminal")
        }
    }
    
    private var settingsButton: some View {
        Button {
            navigationManager.append(SettingPathItem())
        } label: {
            Text("Settings")
        }
    }
}

#Preview {
    VStack {
        MainHeaderView()
            .environmentObject(NavigationManager())
        Spacer()
    }
    .ignoresSafeArea(.container, edges: .top)
}
