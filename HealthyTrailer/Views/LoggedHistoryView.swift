//
//  LoggedHistoryView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct LoggedHistoryView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            SecondaryHeaderView(titleText: "Logged History")
            
            ScrollView {
                directories
                    .padding(.top, 30)
                    .padding(.horizontal)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden()
        .onAppear {
//            viewModel.createDirectory()
            viewModel.getLogDirectories()
        }
    }
    
    private var directories: some View {
        VStack(spacing: 14) {
            ForEach(viewModel.logFoldersPaths, id: \.self) { path in
                Button {
                    navigationManager.path.append(FolderDetailsPathItem(folderPath: path))
                } label: {
                    FolderView(folderPath: path)
                }
            }
        }
    }
}

fileprivate struct FolderView: View {
    let folderPath: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.lightBlue)
            
            HStack(spacing: 30) {
                Image("folderIcon")
                
                Text(getDirectoryName(fromPath: folderPath))
                    .font(.roboto700, size: 16)
                    .foregroundStyle(Color.mainBlue)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 64)
        }
    }
    
    private func getDirectoryName(fromPath path: String) -> String {
        return URL(fileURLWithPath: path).lastPathComponent
    }
}

#Preview {
    LoggedHistoryView()
        .environmentObject(NavigationManager())
        .environmentObject(MainViewModel())
}
