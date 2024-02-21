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
    
    @State var previouslyConnectedDevices: [UUID] = []
    
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
            getConnectedDeviceIDs()
        }
    }
    
    private var deviceItems: some View {
        VStack(spacing: 8) {
            ForEach(twdManager.discoveredPeripherals, id: \.name) { peripheral in
                Button(action: {
                    twdManager.connectToDevice(peripheral: peripheral)
                    saveConnectedDeviceID(connectedDeviceId: peripheral.identifier)
                    connectTWDAction(device: peripheral)
                    navigationManager.removeLast()
                }) {
                    deviceItemView(peripheral: peripheral)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func deviceItemView(peripheral: CBPeripheral) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Device name:")
                    .font(.roboto500, size: 16)
                    .foregroundStyle(Color.black)
                Text(peripheral.name ?? "Unknown name")
                    .font(.roboto400, size: 16)
                    .foregroundStyle(Color.mainBlue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Device identifier:")
                    .font(.roboto500, size: 16)
                    .foregroundStyle(Color.black)
                Text(peripheral.identifier.uuidString.suffix(12))
                    .font(.roboto400, size: 16)
                    .foregroundStyle(Color.mainBlue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Previously connected to device:")
                    .font(.roboto500, size: 16)
                    .foregroundStyle(Color.black)
                Text(wasPreviouslyConnected(deviceId: peripheral.identifier) ? "Yes" : "No")
                    .font(.roboto400, size: 16)
                    .foregroundStyle(Color.mainBlue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.lightBlue)
        )
        .padding(.horizontal)
    }
    
    private func wasPreviouslyConnected(deviceId: UUID) -> Bool {
        previouslyConnectedDevices.contains(deviceId)
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
    
    private func saveConnectedDeviceID(connectedDeviceId: UUID) {
        guard !previouslyConnectedDevices.contains(connectedDeviceId) else { return }
        
        var newConnectedDevicesArray = previouslyConnectedDevices
        newConnectedDevicesArray.append(connectedDeviceId)
        
        UserDefaults.standard.setObject(newConnectedDevicesArray, forKey: "previouslyConnectedBluetoothDevices")
    }
    
    private func getConnectedDeviceIDs() {
        self.previouslyConnectedDevices = UserDefaults.standard.getObject(forKey: "previouslyConnectedBluetoothDevices", castTo: [UUID].self) ?? []
    }
}

#Preview {
    SelectDevicesView()
}
