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
                .frame(maxWidth: .infinity, alignment: .leading)
            loggedHistoryIcon
            terminalIcon
            settingsIcon
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .padding(.top, ScreenUtils.statusBarHeight)
        .background(
            Rectangle()
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        )
    }
    
    private var title: some View {
        Text("Trailers WatchDog")
            .foregroundStyle(Color.textDark)
            .font(.roboto700, size: 20)
    }
    
    private var loggedHistoryIcon: some View {
        Button {
            navigationManager.append(HistoryPathItem())
        } label: {
            Image("folderIcon")
                .resizable()
                .frame(width: 30, height: 30)
        }
    }
    
    private var terminalIcon: some View {
        Button {
            navigationManager.append(TerminalPathItem())
        } label: {
            Image("terminalIcon")
                .resizable()
                .frame(width: 30, height: 30)
        }
    }
    
    private var settingsIcon: some View {
        Button {
            navigationManager.append(SettingPathItem())
        } label: {
            Image("settingsIcon")
                .resizable()
                .frame(width: 30, height: 30)
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
