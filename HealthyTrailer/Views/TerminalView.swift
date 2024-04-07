//
//  TerminalView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct TerminalView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: MainViewModel
    
    @Namespace var bottomID
    
    var body: some View {
        VStack(spacing: 0) {
            SecondaryHeaderView(titleText: "Terminal")
            
            ScrollViewReader { proxy in
                ScrollView {
                    HStack {
                        statusIndicator
                            .padding(.leading, -12)
                        Spacer()
                    }
                    .padding(.top, 30)
                    
                    logs
                        .padding(.horizontal)
                        .padding(.top, 30)
                    
                    HStack { EmptyView() }
                        .id(bottomID)
                        .padding(.bottom, 50)
                }
                .onChange(of: viewModel.terminalLogs.last) { _ in
                    withAnimation(.spring(duration: 0.2)) {
                        proxy.scrollTo(bottomID)
                    }
                }
            }
        }
        .animation(.spring(duration: 0.2), value: viewModel.terminalLogs)
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden()
    }
    
    private var statusIndicator: some View {
        HStack(spacing: 14) {
            Image(systemName: viewModel.isConnected ? "checkmark" : "xmark")
                .foregroundStyle(Color.white)
                .frame(width: 15, height: 15)
                .bold()
                .padding()
                .padding(.leading, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(viewModel.isConnected ? Color.mainGreen : Color.mainRed)
                )
            
            Text("Status")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.textDark)
        }
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
                .font(.roboto400, size: 18)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TerminalView()
        .environmentObject(NavigationManager())
        .environmentObject(MainViewModel())
}
