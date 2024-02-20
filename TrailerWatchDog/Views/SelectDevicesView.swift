//
//  SelectDevicesView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 20.02.2024.
//

import SwiftUI
import CoreBluetooth

struct SelectDevicesView: View {
    @StateObject var twdManager = BluetoothTWDManager.shared
    
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
        }
    }
    
    private var deviceItems: some View {
        VStack(spacing: 8) {
            ForEach(twdManager.discoveredPeripherals, id: \.name) { peripheral in
                Button(action: {
                    twdManager.connectToDevice(peripheral: peripheral)
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
                Text("Yes")
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
}

#Preview {
    SelectDevicesView()
}
