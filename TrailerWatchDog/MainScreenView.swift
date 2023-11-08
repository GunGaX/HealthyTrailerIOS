//
//  MainScreenView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 08.11.2023.
//

import SwiftUI

struct MainScreenView: View {
    var body: some View {
        VStack {
            trailerPhoto
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
    
    private var trailerPhoto: some View {
        Image("emptyTrailerImage")
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    MainScreenView()
}
