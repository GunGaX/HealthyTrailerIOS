//
//  ConnectTWDAlertView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 16.02.2024.
//

import SwiftUI

struct ConnectTWDAlertView: ViewModifier {
    @Binding public var showAlert: Bool
    
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
            ConnectTWDView(showAlert: $showAlert)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .transition(.opacity.combined(with: .scale(scale: 0.5)))
                .padding(.horizontal)
        }
    }
}

struct ConnectTWDView: View {
    @StateObject var twdManager = BluetoothTWDManager()

    @Binding var showAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            title
            listeningText
            deviceItems
            
            HStack(spacing: 20) {
                Spacer()
                cancelButton
                okButton
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .onAppear {
            twdManager.setupBluetooth()
        }
    }
    
    private var title: some View {
        Text("Connect TWD device")
            .font(.roboto500, size: 20)
            .foregroundStyle(Color.mainRed)
    }
    
    private var listeningText: some View {
        Text("Listening for new devices...")
            .font(.roboto400, size: 16)
            .foregroundStyle(Color.mainGrey)
    }
    
    private var deviceItems: some View {
        VStack {
            ForEach(twdManager.discoveredPeripherals, id: \.name) { peripheral in
                Button(action: {
                    twdManager.connectToDevice(peripheral: peripheral)
                }) {
                    Text(peripheral.name ?? "Unknown")
                }
                .padding(.vertical, 10)
            }
        }
        .frame(maxWidth: .infinity)
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
    
    private var okButton: some View {
        Button {
            showAlert = false
        } label: {
            Text("Ok")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.mainRed)
        }
    }
}
