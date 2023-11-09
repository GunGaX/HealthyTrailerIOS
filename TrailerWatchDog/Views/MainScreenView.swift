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
            MainHeaderView()
                
            ScrollView {
                HStack {
                    statusIndicator
                        .padding(.leading, -12)
                    Spacer()
                    connectionSection
                        .padding(.trailing)
                }
                .padding(.top, 30)
                HStack {
                    graphButton
                    Spacer()
                    logOutButton
                }
                .padding()
                
                emptyTrailerPhoto
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    private var logOutButton: some View {
        Button {
            withAnimation {
                viewModel.isTWDConnected = false
            }
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
    
    private var statusIndicator: some View {
        HStack(spacing: 14) {
            Image(systemName: viewModel.isTWDConnected ? "checkmark" : "xmark")
                .foregroundStyle(Color.white)
                .frame(width: 15, height: 15)
                .bold()
                .padding()
                .padding(.leading, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(viewModel.isTWDConnected ? Color.mainGreen : Color.mainRed)
                )
            
            Text("Status")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.textDark)
        }
    }
    
    @ViewBuilder
    private var connectionSection: some View {
        if viewModel.isTWDConnected {
            connectedDeviceInfo
        } else {
            tryToConnectButton
        }
    }
    
    private var connectedDeviceInfo: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("Connected:")
                .foregroundStyle(Color.textDark)
            
            // MOCK DEVICE NAME
            Text("TWD-1400-AX3WX3W")
                .foregroundStyle(Color.mainBlue)
        }
        .font(.roboto500, size: 16)
    }
    
    private var tryToConnectButton: some View {
        Button {
            withAnimation {
                viewModel.isTWDConnected = true
            }
        } label: {
            Text("Try to connect")
        }
        .buttonStyle(.mainBlueButton)
    }
}

#Preview {
    MainScreenView()
}
