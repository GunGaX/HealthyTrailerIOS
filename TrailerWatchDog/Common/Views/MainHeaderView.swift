//
//  MainHeaderView.swift
//  TrailerWatchDog
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
        Text("Trailers WatchDog")
            .foregroundStyle(Color.textDark)
            .font(.roboto700, size: 20)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var threeDotsIcon: some View {
        Menu {
            loggedHistoryButton
            terminalButton
            settingsButton
        } label: {
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(90))
                .frame(width: 22, height: 22)
                .foregroundColor(.black)
        }
    }
    
    private var loggedHistoryButton: some View {
        Button {
            navigationManager.append(HistoryPathItem())
        } label: {
            Text("Directory")
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
