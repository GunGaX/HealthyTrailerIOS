//
//  FolderDetailsView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 17.11.2023.
//

import SwiftUI

struct FolderDetailsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: MainViewModel
    
    let folderPath: String
    
    var body: some View {
        VStack(spacing: 0) {
            SecondaryHeaderView(titleText: getDirectoryName(fromPath: folderPath))
            
            ScrollView {
                files
                    .padding(.top, 30)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.getFilesIdDirecory(path: folderPath)
        }
    }
    
    private var files: some View {
        VStack(spacing: 14) {
            ForEach(Array(viewModel.logFiles), id: \.key) { (path, file) in
                Button {
                    navigationManager.path.append(LogFileDetailsPathItem(file: file))
                } label: {
                    FileView(filePath: path, file: file)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func getDirectoryName(fromPath path: String) -> String {
        return URL(fileURLWithPath: path).lastPathComponent
    }
}

fileprivate struct FileView: View {
    let filePath: String
    let file: HistoryFileModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.lightBlue)
            
            HStack(spacing: 30) {
                Image("fileIcon")
                
                VStack(alignment: .leading, spacing: 14) {
                    Text(file.title)
                        .font(.roboto700, size: 16)
                       
                    Text("\(file.content.utf8.count) B | " + file.creationDate.defaultDateFormat())
                        .font(.roboto400, size: 14)
                }
                .foregroundStyle(Color.mainBlue)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 64)
        }
    }
}

#Preview {
    FolderDetailsView(folderPath: "fkdjfkldf")
        .environmentObject(NavigationManager())
        .environmentObject(MainViewModel())
}
