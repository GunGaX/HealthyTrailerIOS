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
    var onCancelTap: () -> Void
    
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
            ConnectTMPSDevicesView(showAlert: $showAlert, discoveredTMPSDevices: discoveredTMPSDevices, tireToConnect: tireToConnect, onButtonTap: onButtonTap, onCancelTap: onCancelTap)
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
    @State private var lastConnectedTPMSDevices: [String] = []
    
    @Binding var showAlert: Bool
    
    var discoveredTMPSDevices: [String]
    var enableTPMSDevices: [String] {
        let valuesNotInDiscoveredDevices = discoveredTMPSDevices
            .filter { !dataManager.connectedTPMSIds.contains($0) }
            .filter { !lastConnectedTPMSDevices.contains($0) }
            .filter { !$0.isEmpty }
        return valuesNotInDiscoveredDevices
    }
    var enableLastConnectedTPMSDevices: [String] {
        let valuesNotInDiscoveredDevices = lastConnectedTPMSDevices
            .filter { !dataManager.connectedTPMSIds.contains($0) }
        return valuesNotInDiscoveredDevices
    }
    
    var tireToConnect: String
    
    var onButtonTap: (String) -> Void
    var onCancelTap: () -> Void
    
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
            lastConnectedTPMSDevices = dataManager.getLastConnectedTPMSDevices()
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
            ForEach(enableLastConnectedTPMSDevices, id: \.self) { device in
                LastTMPSCardView(selectedDevice: $selectedDevice, wasConnected: true, device: device)
            }
            ForEach(enableTPMSDevices, id: \.self) { device in
                LastTMPSCardView(selectedDevice: $selectedDevice, wasConnected: false, device: device)
            }
        }
    }
    
    private var forgetKnownDevicesButton: some View {
        Button {
            dataManager.forgetLastConnectedTPMSDevices()
            lastConnectedTPMSDevices = []
        } label: {
            Text("Forget known sensors")
                .font(.roboto500, size: 14)
                .foregroundStyle(Color.textDark)
        }
    }
    
    private var cancelButton: some View {
        Button {
            onCancelTap()
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
            self.selectedDevice = nil
        } label: {
            Text("Yes")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.mainRed)
        }
    }
}

fileprivate struct LastTMPSCardView: View {
    @Binding var selectedDevice: String?
    
    let wasConnected: Bool
    var device: String
    
    var body: some View {
        Button {
            withAnimation {
                selectedDevice = device
            }
        } label: {
            Text(deviceNameFormatter(name: device))
                .font(.roboto500, size: 16)
                .foregroundStyle(wasConnected ? Color.textDark : Color.red)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundStyle(selectedDevice == device ? Color.mainBlue : Color.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 2)
                )
        }
    }
    
    private func deviceNameFormatter(name: String) -> String {
        if let underscoreRange = name.range(of: "_") {
            let substring = name.suffix(from: underscoreRange.upperBound)
            let formattedString = "#" + String(substring)
            
            return formattedString
        }
        
        return ""
    }
}

#Preview {
    ConnectTMPSDevicesView(showAlert: .constant(true), discoveredTMPSDevices: ["_131323", "_412343", "_941342"], tireToConnect: "RIGHT 1", onButtonTap: { _ in }, onCancelTap: {})
}
