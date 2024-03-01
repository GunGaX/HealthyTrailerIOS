//
//  SelectDevicesView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 20.02.2024.
//

import SwiftUI
import CoreBluetooth

struct SelectDevicesView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: MainViewModel
    
    @StateObject var twdManager = BluetoothTWDManager.shared
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            SecondaryHeaderView(titleText: "Select devices")
            
            ScrollView {
                deviceItems
            }
            .padding(.top, 16)
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden()
        .onAppear {
            twdManager.setupBluetooth()
            viewModel.getConnectedDeviceIDs()
        }
    }
    
    private var deviceItems: some View {
        VStack(spacing: 8) {
            ForEach(twdManager.discoveredPeripherals, id: \.name) { peripheral in
                Button(action: {
                    twdManager.connectToDevice(peripheral: peripheral)
                    viewModel.saveConnectedDeviceID(connectedDeviceId: peripheral.identifier)
                    connectTWDAction(device: peripheral)
                    viewModel.startCheckWarningTimer()
                    print("tapped")
                    navigationManager.removeLast()
                }) {
                    BluetoothItemView(peripheral: peripheral)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func connectTWDAction(device: CBPeripheral) {
        if let axiesCount = twdManager.connectedTWD?.axiesCount {
            dataManager.setup(connectedTWDId: device.identifier.uuidString, connectedTWDAxiesCount: axiesCount)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                connectTWDAction(device: device)
            }
            return
        }
        
        viewModel.isTWDConnected = true
        
        if !dataManager.connectedTPMSIds.isEmpty {
            viewModel.startTimerAndUploadingData()
        }
    }
}

fileprivate struct BluetoothItemView: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    let peripheral: CBPeripheral
    
    var body: some View {
        VStack(spacing: 8) {
            deviceNameSection
            identifierSection
            wasPreviouslyConnectedSection
        }
        .padding()
        .background(
            lightBackgroung
        )
        .padding(.horizontal)
    }
    
    private var deviceNameSection: some View {
        HStack {
            Text("Device name:")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.black)
            Text(peripheral.name ?? "Unknown name")
                .font(.roboto400, size: 16)
                .foregroundStyle(Color.mainBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var identifierSection: some View {
        HStack {
            Text("Device identifier:")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.black)
            Text(peripheral.identifier.uuidString.suffix(12))
                .font(.roboto400, size: 16)
                .foregroundStyle(Color.mainBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var wasPreviouslyConnectedSection: some View {
        HStack {
            Text("Previously connected to device:")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.black)
            Text(viewModel.wasPreviouslyConnected(deviceId: peripheral.identifier) ? "Yes" : "No")
                .font(.roboto400, size: 16)
                .foregroundStyle(Color.mainBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var lightBackgroung: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(Color.lightBlue)
    }
}

#Preview {
    SelectDevicesView()
}
