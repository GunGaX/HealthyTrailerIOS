//
//  TerminalView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct TerminalView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            SecondaryHeaderView(titleText: "Terminal")
            
            ScrollView {
                HStack {
                    statusIndicator
                        .padding(.leading, -12)
                    Spacer()
                    connectionSection
                        .padding(.trailing)
                }
                .padding(.top, 30)
                
                logs
                    .padding(.horizontal)
                    .padding(.top, 30)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden()
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
            
            Text(viewModel.connectedTWD?.name ?? "No name")
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
    
    private var logs: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.terminalLogs, id: \.self) { log in
                Group {
                    Text(log.time.formattedTime() + ":")
                        .foregroundColor(Color.mainBlue)
                    +
                    Text(log.text)
                        .foregroundColor(Color.textDark)
                }
                .font(.roboto400, size: 14)
            }
        }
    }
}

#Preview {
    TerminalView()
        .environmentObject(NavigationManager())
        .environmentObject(MainViewModel())
}
