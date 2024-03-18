//
//  LogFileDetailsView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 17.11.2023.
//

import SwiftUI

struct LogFileDetailsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    let file: HistoryFileModel
    
    var body: some View {
        VStack(spacing: 0) {
            SecondaryHeaderView(titleText: file.title)
            
            ScrollView {
                Text(file.content)
                    .multilineTextAlignment(.leading)
                    .font(.roboto400, size: 14)
                    .foregroundStyle(Color.textDark)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 30)
                
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden()
    }
}

