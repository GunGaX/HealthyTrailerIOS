//
//  MainScreenView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 08.11.2023.
//

import SwiftUI

struct MainScreenView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        VStack {
            HStack {
                graphButton
                Spacer()
                logOutButton
            }
            .padding()
            
            emptyTrailerPhoto
        }
    }
    
    private var logOutButton: some View {
        Button {
            
        } label: {
             Image("logOutIcon")
                .resizable()
                .frame(width: 32, height: 32)
        }
    }
    
    private var graphButton: some View {
        Button {
            
        } label: {
            Image("graphIcon")
                .resizable()
                .frame(width: 32, height: 32)
        }
    }
    
    private var emptyTrailerPhoto: some View {
        Image("emptyTrailerImage")
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    MainScreenView()
}
