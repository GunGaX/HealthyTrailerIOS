//
//  MainScreenView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 08.11.2023.
//

import SwiftUI

struct MainScreenView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: MainViewModel
    
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var errorManager = ErrorManager()
    
    @State private var showConnectingTPMSAlert = false
    @State private var showAddConfirmationAlert = false
    @State private var showForgetSensorsConfirmationAlert = false
    
    @State private var tireToConnectText = "LEFT 1"
    @State private var connectedTPMSCount: Int = 0
    
    @State private var connectedTPMSDevices: [String] = []
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            VStack(spacing: 0) {
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
                    
                    trailer
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            .navigationDestinations()
            .confirmationAddNewSensorsAlert($showAddConfirmationAlert, onButtonTap: addNewTPMSSensorsAction)
            .forgetSensorsConfirmationAlert($showForgetSensorsConfirmationAlert, onButtonTap: forgetTPMSSensorsAction)
            .connectingTPMSAlertView($showConnectingTPMSAlert, discoveredTPMSDevices: dataManager.tpms_ids, tireToConnect: tireToConnectText, onButtonTap: startConnectingTPMS, onCancelTap: saveAndStartWorking)
            .attentionAlert($errorManager.showTWDOverheatAlert, messageText: errorManager.temperatureOverheatTWDMessage)
            .attentionAlert($errorManager.showTPMSOverheatAlert, messageText: errorManager.temperatureOverheatTPMSMessage)
            .attentionAlert($errorManager.showTWDTemperatureDifferenceAlert, messageText: errorManager.temperatureDifferenceTWDMessage)
        }
    }
    
    private var logOutButton: some View {
        Button {
            withAnimation {
                viewModel.stopUploadingData()
                dataManager.disconnectTWD()
                BluetoothTWDManager.shared.disconnectFromDevice()
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
            withAnimation {
                viewModel.displayingMode.toggle()
            }
        } label: {
            Image(viewModel.displayingMode ? "graphIcon" : "twoRectanglesIcon")
                .resizable()
                .frame(width: 32, height: 32)
        }
    }
    
    @ViewBuilder
    private var trailer: some View {
        if viewModel.isTWDConnected {
            if viewModel.displayingMode {
                fillTrailer
            } else {
                flatTrailer
            }
        } else {
            emptyTrailerPhoto
        }
    }
    
    private var emptyTrailerPhoto: some View {
        Image("emptyTrailerImage")
            .resizable()
            .scaledToFit()
    }
    
    private var fillTrailer: some View {
        VStack(spacing: -3) {
            Image("fillTrailerTop")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
            
            ForEach(dataManager.axies, id: \.id) { axis in
                AxisBarView(axis: axis)
                if axis.axisNumber != dataManager.axies.last?.axisNumber {
                    separatingAxisBar
                }
            }

            Image("fillTrailerBack")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
        }
    }
    
    private var separatingAxisBar: some View {
        Image("separatingAxisImage")
            .resizable()
            .scaledToFit()
            .frame(width: 220)
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
            VStack(alignment: .trailing) {
                connectedDeviceInfo
                connectTMPSButton
            }
            .frame(maxWidth: 150)
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
            navigationManager.path.append(SelectDevicePathItem())
        } label: {
            Text("Try to connect")
        }
        .buttonStyle(.mainBlueButton)
    }
    
    @ViewBuilder
    private var connectTMPSButton: some View {
        if dataManager.connectedTPMSIds.isEmpty {
            addNewTPMSButton
        } else {
            forgetTPMSButtons
        }
    }
    
    private var addNewTPMSButton: some View {
        Button {
            showAddConfirmationAlert = true
        } label: {
            Text("Add TPMS sensors to trailer")
                .multilineTextAlignment(.center)
                .padding(.vertical, -6)
        }
        .buttonStyle(.mainBlueButton)
    }
    
    private var forgetTPMSButtons: some View {
        Button {
            showForgetSensorsConfirmationAlert = true
        } label: {
            Text("Forget connected TPMS sensors")
                .multilineTextAlignment(.center)
                .padding(.vertical, -6)
        }
        .buttonStyle(.mainBlueButton)
    }
    
    private var flatTrailer: some View {
        VStack(spacing: 10) {
            ForEach(dataManager.axies, id: \.id) { axis in
                FlatAxisBarView(axis: axis)
            }
        }
    }
    
    private func startConnectingTPMS(text: String) {
        showConnectingTPMSAlert = false
        
        guard let connectedTWDId = dataManager.connectedTWDId, let axiesCount = dataManager.connectedTWDAxiesCount else { return }
        
        connectedTPMSCount += 1
        let connectedTPMSIndex = viewModel.orderedIndeces[connectedTPMSCount - 1]
        
        if tireToConnectText != viewModel.connectingTextArray.last {
            tireToConnectText = viewModel.connectingTextArray[connectedTPMSCount]
        }
        
        viewModel.connectedOrderedTPMSIds[connectedTPMSIndex - 1] = text
        dataManager.performLastConnectedTPMSAction(connectedDevices: viewModel.connectedOrderedTPMSIds)
        viewModel.updateTPMSConnectionStatus(id: text, isConnected: true)
        
        let newTPMS = TPMSModel(id: text, connectedToTWDWithId: connectedTWDId, tireData: TireData.emptyData)
        
        let axleIndex = Int((connectedTPMSIndex - 1) / 2)
        if connectedTPMSIndex % 2 == 1 {
            dataManager.axies[axleIndex].leftTire = newTPMS
        } else {
            dataManager.axies[axleIndex].rightTire = newTPMS
        }
        
        if connectedTPMSCount < (axiesCount * 2) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showConnectingTPMSAlert = true
            }
        } else {
            saveAndStartWorking()
        }
    }
    
    private func saveAndStartWorking() {
        tireToConnectText = "LEFT 1"
        connectedTPMSCount = 0
        
        dataManager.loadLastData()
        viewModel.startTimerAndUploadingData()
    }
    
    private func addNewTPMSSensorsAction() {
        guard  let axiesCount = dataManager.connectedTWDAxiesCount else { return }
        
        viewModel.stopUploadingData()
        dataManager.connectedTPMSIds = []
        dataManager.saveConnectedTPMStoTWD()
        
        for index in 0..<axiesCount {
            dataManager.axies[index].leftTire = TPMSModel.emptyState
            dataManager.axies[index].rightTire = TPMSModel.emptyState
        }
        
        viewModel.generateConnectingOrder(axiesCount)
        
        showConnectingTPMSAlert = true
    }
    
    private func forgetTPMSSensorsAction() {
        guard  let axiesCount = dataManager.connectedTWDAxiesCount else { return }
        
        viewModel.stopUploadingData()
        viewModel.unChainTPMSDevices()
        dataManager.deleteConnectedTPMStoTWD()
        dataManager.connectedTPMSIds = []
        
        for index in 0..<axiesCount {
            dataManager.axies[index].leftTire = TPMSModel.emptyState
            dataManager.axies[index].rightTire = TPMSModel.emptyState
        }
    }
}

fileprivate struct AxisBarView: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    var axis: AxiesData
    
    var body: some View {
        HStack(spacing: -20) {
            valueBar(isRight: false)
            
            ZStack {
                Image("fillAxisImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                
                HStack {
                    VStack(spacing: 0) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("L")
                            Text("\(axis.axisNumber)")
                                .font(.roboto500, size: 10)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.leftTire.tireData.temperature
                                .applyTemperatureSystem(selectedSystem: viewModel.selectedTemperatureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedTemperatureType.measureMark)
                                .font(.roboto500, size: 10)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.leftTire.tireData.preassure
                                .applyPreassureSystem(selectedSystem: viewModel.selectedPreassureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedPreassureType.measureMark)
                                .font(.roboto500, size: 10)
                                .padding(.bottom, 1)
                        }
                    }
                    .fixedSize()
                    .font(.roboto500, size: 12)
                    .foregroundStyle(Color.white)
                    .frame(width: 44)
                    Spacer()
                    VStack {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("R")
                            Text("\(axis.axisNumber)")
                                .font(.roboto500, size: 10)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.rightTire.tireData.temperature
                                .applyTemperatureSystem(selectedSystem: viewModel.selectedTemperatureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedTemperatureType.measureMark)
                                .font(.roboto500, size: 10)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.rightTire.tireData.preassure
                                .applyPreassureSystem(selectedSystem: viewModel.selectedPreassureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedPreassureType.measureMark)
                                .font(.roboto500, size: 10)
                                .padding(.bottom, 1)
                        }
                    }
                    .fixedSize()
                    .font(.roboto500, size: 12)
                    .foregroundStyle(Color.white)
                    .frame(width: 44)
                }
            }
            .zIndex(2.0)
            
            valueBar(isRight: true)
        }
    }
    
    private func valueBar(isRight: Bool) -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.lightGreen)
                .padding(.top, 2)
                .padding(.bottom, 1)
            
            VStack {
                Text("Axle Temp")
                    .font(.roboto500, size: 8)
                HStack(alignment: .bottom, spacing: 5) {
                    Text(viewModel.getLastTemperatureForAxle(isRight: isRight, index: axis.axisNumber - 1))
                        .font(.roboto700, size: 18)
                    
                    Text(viewModel.selectedTemperatureType.measureMark)
                        .font(.roboto700, size: 10)
                        .padding(.bottom, 3)
                }
                TireTemperaturePlotView(data: viewModel.getTemperatureArrayForAxle(isRight: isRight, index: axis.axisNumber - 1))
                    .padding(.horizontal)
                    .padding(isRight ? .leading : .trailing, 10)
                    .frame(height: 24)
            }
            .foregroundStyle(Color.mainGreen)
            .padding(isRight ? .trailing : .leading, -10)
        }
    }
}

fileprivate struct FlatAxisBarView: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    var axis: AxiesData
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Axis \(axis.axisNumber)")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            HStack(spacing: 0) {
                flatValueBar(isRight: false)
                ZStack {
                    tireImage
                    VStack(spacing: 0) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("L")
                            Text("\(axis.axisNumber)")
                                .font(.roboto500, size: 10)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.leftTire.tireData.temperature
                                .applyTemperatureSystem(selectedSystem: viewModel.selectedTemperatureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedTemperatureType.measureMark)
                                .font(.roboto500, size: 10)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.leftTire.tireData.preassure
                                .applyPreassureSystem(selectedSystem: viewModel.selectedPreassureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedPreassureType.measureMark)
                                .font(.roboto500, size: 10)
                                .padding(.bottom, 1)
                        }
                    }
                    .font(.roboto500, size: 12)
                    .foregroundStyle(Color.white)
                    .frame(width: 44)
                }
                .zIndex(2.0)
                .padding(.trailing, 12)
                ZStack {
                    tireImage
                    VStack {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("R")
                            Text("\(axis.axisNumber)")
                                .font(.roboto500, size: 10)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.rightTire.tireData.temperature
                                .applyTemperatureSystem(selectedSystem: viewModel.selectedTemperatureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedTemperatureType.measureMark)
                                .font(.roboto500, size: 10)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.rightTire.tireData.preassure
                                .applyPreassureSystem(selectedSystem: viewModel.selectedPreassureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedPreassureType.measureMark)
                                .font(.roboto500, size: 10)
                                .padding(.bottom, 1)
                        }
                    }
                    .font(.roboto500, size: 12)
                    .foregroundStyle(Color.white)
                    .frame(width: 44)
                }
                .zIndex(2.0)
                flatValueBar(isRight: true)
            }
        }
    }
    
    private var tireImage: some View {
        ZStack {
            Image("emptyTireImage")
                .resizable()
                .scaledToFit()
            Image("onTireMarksImage")
                .resizable()
                .scaledToFit()
        }
        .frame(height: 64)
    }
    
    private func flatValueBar(isRight: Bool) -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.lightGreen)
                .padding(.top, 2)
                .padding(.bottom, 1)
            
            VStack(spacing: 0) {
                Text("Axle Temp")
                    .font(.roboto500, size: 8)
                HStack(alignment: .bottom, spacing: 5) {
                    Text(viewModel.getLastTemperatureForAxle(isRight: isRight, index: axis.axisNumber - 1))
                        .font(.roboto700, size: 18)
                    
                    Text(viewModel.selectedTemperatureType.measureMark)
                        .font(.roboto700, size: 10)
                        .padding(.bottom, 3)
                }
                TireTemperaturePlotView(data: viewModel.getTemperatureArrayForAxle(isRight: isRight, index: axis.axisNumber - 1))
                    .padding(.horizontal)
                    .padding(isRight ? .leading : .trailing, 10)
                    .frame(height: 24)
            }
            .foregroundStyle(Color.mainGreen)
            .padding(.vertical, 6)
        }
        .padding(isRight ? .leading : .trailing, -10)
    }
}

#Preview {
    MainScreenView()
        .environmentObject(NavigationManager())
        .environmentObject(MainViewModel())
}
