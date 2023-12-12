//
//  ConnectTMPSDevicesView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 29.11.2023.
//

import SwiftUI

struct ConnectTPMSAlertView: ViewModifier {
    @Binding public var showAlert: Bool
    
    var discoveredTMPSDevices: [String]
    var tireToConnect: String
    
    var onButtonTap: (String) -> Void
    
    func body(content: Content) -> some View { content
        .overlay(contentOverlay)
        .overlay(alert)
        .animation(.spring(), value: showAlert)
    }
    
    @ViewBuilder
    private var contentOverlay: some View {
        if showAlert {
            Color.black
                .opacity(0.5)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var alert: some View {
        if showAlert {
            ConnectTMPSDevicesView(showAlert: $showAlert, discoveredTMPSDevices: discoveredTMPSDevices, tireToConnect: tireToConnect, onButtonTap: onButtonTap)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .transition(.opacity.combined(with: .scale(scale: 0.5)))
                .padding(.horizontal)
        }
    }
}

struct ConnectTMPSDevicesView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedDevice: String?
    
    @Binding var showAlert: Bool
    
    var discoveredTMPSDevices: [String]
    var tireToConnect: String
    
    var onButtonTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            title
            listeningText
            installText
            tireToConnectText
            previousDevicesText
            deviceItems
            
            HStack(spacing: 20) {
                forgetKnownDevicesButton
                Spacer()
                cancelButton
                yesButton
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .onAppear {
            selectedDevice = nil
        }
    }
    
    private var title: some View {
        Text("Add new TPMS sensors")
            .font(.roboto500, size: 20)
            .foregroundStyle(Color.mainRed)
    }
    
    private var listeningText: some View {
        Text("Listening for new sensors")
            .font(.roboto400, size: 16)
            .foregroundStyle(Color.mainGrey)
    }
    
    private var installText: some View {
        Text("Please install the TMPS sensor for tire:")
            .font(.roboto500, size: 14)
            .foregroundStyle(Color.textDark)
            .frame(maxWidth: .infinity)
    }
    
    private var tireToConnectText: some View {
        Text(tireToConnect)
            .font(.roboto400, size: 18)
            .foregroundStyle(Color.mainGrey)
            .frame(maxWidth: .infinity)
    }
    
    private var previousDevicesText: some View {
        Text("Previously known sensors:")
            .font(.roboto500, size: 14)
            .foregroundStyle(Color.textDark)
    }
    
    private var deviceItems: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(discoveredTMPSDevices, id: \.self) { device in
                LastTMPSCardView(selectedDevice: $selectedDevice, device: device)
            }
        }
    }
    
    private var forgetKnownDevicesButton: some View {
        Button {
            
        } label: {
            Text("Forget known sensors")
                .font(.roboto500, size: 14)
                .foregroundStyle(Color.textDark)
        }
    }
    
    private var cancelButton: some View {
        Button {
            showAlert = false
        } label: {
            Text("Cancel")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.mainGrey)
        }
    }
    
    private var yesButton: some View {
        Button {
            guard let selectedDevice else { return }
            onButtonTap(selectedDevice)
        } label: {
            Text("Yes")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.mainRed)
        }
    }
}

fileprivate struct LastTMPSCardView: View {
    @Binding var selectedDevice: String?
    
    var device: String
    
    var body: some View {
        Button {
            withAnimation {
                selectedDevice = device
            }
        } label: {
            Text(device)
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.textDark)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundStyle(selectedDevice == device ? Color.mainBlue : Color.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 2)
                )
        }
    }
}

#Preview {
    ConnectTMPSDevicesView(showAlert: .constant(true), discoveredTMPSDevices: ["#131323", "#412343", "#941342"], tireToConnect: "RIGHT 1", onButtonTap: { _ in })
}
