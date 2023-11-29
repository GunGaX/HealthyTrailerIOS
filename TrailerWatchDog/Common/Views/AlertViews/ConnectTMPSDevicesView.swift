//
//  ConnectTMPSDevicesView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 29.11.2023.
//

import SwiftUI

struct ConnectTMPSDevicesView: View {
    // Temporary array of Strings, update with TPMS models later
    var discoveredTMPSDevices: [String]
    var tireToConnect: String
    
    @State private var selectedDevice: String?
    
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
                LastTMPSCardView(device: device, selectedDevice: .constant(nil))
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
            
        } label: {
            Text("Cancel")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.mainGrey)
        }
    }
    
    private var yesButton: some View {
        Button {
            
        } label: {
            Text("Yes")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.mainRed)
        }
    }
}

fileprivate struct LastTMPSCardView: View {
    var device: String
    @Binding var selectedDevice: String?
    
    var body: some View {
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
            .onTapGesture {
                selectedDevice = device
            }
    }
}

#Preview {
    ConnectTMPSDevicesView(discoveredTMPSDevices: ["#131323", "#412343", "#941342"], tireToConnect: "RIGHT 1")
}
