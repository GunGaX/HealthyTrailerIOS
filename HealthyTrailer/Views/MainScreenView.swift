//
//  MainScreenView.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 08.11.2023.
//

import SwiftUI

struct MainScreenView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: MainViewModel
    @EnvironmentObject var errorManager: ErrorManager
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var dataManager = DataManager.shared
    
    @State private var showConnectingTPMSAlert = false
    @State private var showAddConfirmationAlert = false
    @State private var showForgetSensorsConfirmationAlert = false
    
    @State private var showDisconnectingError = false
    
    @State private var tireToConnectText = "LEFT 1"
    @State private var connectedTPMSCount: Int = 0
    
    @State private var connectedTPMSDevices: [String] = []
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            VStack(spacing: 0) {
                MainHeaderView()
                
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
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
                            }
                            .padding()
                            
                            trailer
                            
                            Spacer()
                            logOutButton
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            .navigationDestinations()
            .confirmationAddNewSensorsAlert($showAddConfirmationAlert, onButtonTap: addNewTPMSSensorsAction)
            .forgetSensorsConfirmationAlert($showForgetSensorsConfirmationAlert, onButtonTap: forgetTPMSSensorsAction)
            .connectingTPMSAlertView($showConnectingTPMSAlert, discoveredTPMSDevices: dataManager.tpms_ids, tireToConnect: tireToConnectText, onButtonTap: startConnectingTPMS, onCancelTap: saveAndStartWorking)
            .attentionAlert($errorManager.twdOverheatNotificationError.show, messageText: errorManager.twdOverheatNotificationError.message)
            .attentionAlert($errorManager.tpmsOverheatNotificationError.show, messageText: errorManager.tpmsOverheatNotificationError.message)
            .attentionAlert($errorManager.twdTemperatureDifferenceNotificationError.show, messageText: errorManager.twdTemperatureDifferenceNotificationError.message)
            .attentionAlert($errorManager.tpmsTemperatureDifferenceNotificationError.show, messageText: errorManager.tpmsTemperatureDifferenceNotificationError.message)
            .attentionAlert($errorManager.tpmsPressureNotificationError.show, messageText: errorManager.tpmsPressureNotificationError.message)
            .attentionAlert($viewModel.showStaleDataAlert, messageText: viewModel.staleDataMessage)
            .attentionAlert($showDisconnectingError, messageText: "Error with Axle modules, please check connections")
        }
    }
    
    private var logOutButton: some View {
        Button {
            exit(0)
        } label: {
            Text("Exit")
        }
        .buttonStyle(.mainRedButton)
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
        if viewModel.isConnected {
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
        VStack(spacing: 0) {
            Image("fillTrailerTop")
                .resizable()
                .scaledToFit()
                .frame(width: 248)
            
            ForEach(dataManager.axies.indices, id: \.self) { index in
                AxisBarView(axis: $dataManager.axies[index], index: index)
                if dataManager.axies[index].axisNumber != dataManager.axies.last?.axisNumber {
                    separatingAxisBar
                }
            }

            Image("fillTrailerBack")
                .resizable()
                .scaledToFit()
                .frame(width: 248)
        }
    }
    
    private var separatingAxisBar: some View {
        Image("separatingAxisImage")
            .resizable()
            .scaledToFit()
            .frame(width: 248)
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
    
    @ViewBuilder
    private var connectionSection: some View {
        if viewModel.isConnected {
            VStack(alignment: .trailing) {
                connectTMPSButton
            }
            .frame(maxWidth: 150)
        } else {
            tryToConnectButton
        }
    }
    
    private var tryToConnectButton: some View {
        Button {
            dataManager.setup(connectedAxiesCount: 2)
            viewModel.isConnected = true
        } label: {
            Text("Connect")
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
            ForEach(dataManager.axies.indices, id: \.self) { index in
                FlatAxisBarView(axis: $dataManager.axies[index], index: index)
            }
        }
    }
    
    private func startConnectingTPMS(text: String) {
        showConnectingTPMSAlert = false
        
        guard let axiesCount = dataManager.connectedAxiesCount else { return }
        
        connectedTPMSCount += 1
        let connectedTPMSIndex = viewModel.orderedIndeces[connectedTPMSCount - 1]
        
        if tireToConnectText != viewModel.connectingTextArray.last {
            tireToConnectText = viewModel.connectingTextArray[connectedTPMSCount]
        }
        
        viewModel.connectedOrderedTPMSIds[connectedTPMSIndex - 1] = text
        dataManager.performLastConnectedTPMSAction(connectedDevices: viewModel.connectedOrderedTPMSIds)
        viewModel.updateTPMSConnectionStatus(id: text, isConnected: true)
        
        let newTPMS = TPMSModel(id: text, tireData: TireData.emptyData)
        
        let axleIndex = Int((connectedTPMSIndex - 1) / 2)
        if connectedTPMSIndex % 2 == 1 {
            dataManager.axies[axleIndex].leftTire = newTPMS
            dataManager.axies[axleIndex].isLeftSaved = true
            dataManager.axies[axleIndex].isLeftCleanTPMS = false
        } else {
            dataManager.axies[axleIndex].rightTire = newTPMS
            dataManager.axies[axleIndex].isRightSaved = true
            dataManager.axies[axleIndex].isRightCleanTPMS = false
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
        guard let axiesCount = dataManager.connectedAxiesCount else { return }
        
        viewModel.stopUploadingData()
        dataManager.connectedTPMSIds = []
        dataManager.saveConnectedTPMS()
        
        for index in 0..<axiesCount {
            dataManager.axies[index].leftTire = TPMSModel.emptyState
            dataManager.axies[index].rightTire = TPMSModel.emptyState
        }
        
        viewModel.generateConnectingOrder(axiesCount)
        
        showConnectingTPMSAlert = true
    }
    
    private func forgetTPMSSensorsAction() {
        guard let axiesCount = dataManager.connectedAxiesCount else { return }
        
        viewModel.stopUploadingData()
        viewModel.unChainTPMSDevices()
        dataManager.deleteConnectedTPMS()
        dataManager.connectedTPMSIds = []
        
        for index in 0..<axiesCount {
            dataManager.axies[index].leftTire = TPMSModel.emptyState
            dataManager.axies[index].rightTire = TPMSModel.emptyState
            dataManager.axies[index].isLeftCleanTPMS = true
            dataManager.axies[index].isRightCleanTPMS = true
            dataManager.axies[index].isLeftSaved = false
            dataManager.axies[index].isRightSaved = false
        }
    }
}

fileprivate struct AxisBarView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @EnvironmentObject var errorManager: ErrorManager
    
    @Binding var axis: AxiesData
    let index: Int
    
    var body: some View {
        HStack(spacing: -20) {
            valueBar(isRight: false, axle: axis, index: index)
            
            ZStack {
                Image("fillAxisImage")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 80)
                    .frame(maxWidth: 240)
                
                HStack {
                    VStack(spacing: 2) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("L")
                            Text("\(axis.axisNumber)")
                                .font(.roboto500, size: 10)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.getTemperature(isRight: false)
                                .applyTemperatureSystem(selectedSystem: viewModel.selectedTemperatureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedTemperatureType.measureMark)
                                .font(.roboto500, size: 10)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.getPressure(isRight: false)
                                .applyPreassureSystem(selectedSystem: viewModel.selectedPreassureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedPreassureType.measureMark)
                                .font(.roboto500, size: 10)
                                .padding(.bottom, 1)
                                .opacity(0.8)
                        }
                    }
                    .font(.roboto400, size: 14)
                    .foregroundStyle(Color.white)
                    .frame(width: 52)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("R")
                            Text("\(axis.axisNumber)")
                                .font(.roboto500, size: 10)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.getTemperature(isRight: true)
                                .applyTemperatureSystem(selectedSystem: viewModel.selectedTemperatureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedTemperatureType.measureMark)
                                .font(.roboto500, size: 10)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.getPressure(isRight: true)
                                .applyPreassureSystem(selectedSystem: viewModel.selectedPreassureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedPreassureType.measureMark)
                                .font(.roboto500, size: 10)
                                .opacity(0.8)
                                .padding(.bottom, 1)
                        }
                    }
                    .font(.roboto400, size: 14)
                    .foregroundStyle(Color.white)
                    .frame(width: 52)
                }
            }
            .zIndex(2.0)
            
            valueBar(isRight: true, axle: axis, index: index)
        }
        .frame(height: 80)
        .padding(.vertical, -1)
    }
    
    private func valueBar(isRight: Bool, axle: AxiesData, index: Int) -> some View {
        let backgroundColor = isRight ? errorManager.backgroundColors[index].1 : errorManager.backgroundColors[index].0
        let foregroundColor = isRight ? errorManager.foregroundColors[index].1 : errorManager.foregroundColors[index].0
        
        return ZStack {
            Rectangle()
                .foregroundStyle(backgroundColor)
                .frame(height: 80)
            
            VStack {
                Text("Axle Temp")
                    .font(.roboto400, size: 8)
                HStack(alignment: .bottom, spacing: 5) {
                    Text("0.0")
                        .font(.roboto700, size: 18)
                    
                    Text(viewModel.selectedTemperatureType.measureMark)
                        .font(.roboto700, size: 10)
                        .padding(.bottom, 3)
                }
                TireTemperaturePlotView(
                    data: [0.0, 0.0, 0.0],
                    foregroundColor: foregroundColor
                )
                .padding(.horizontal)
                .frame(height: 24)
            }
            .foregroundStyle(foregroundColor)
            .padding(isRight ? .leading : .trailing, 14)
            .padding(isRight ? .trailing : .leading, -10)
        }
    }
}

fileprivate struct FlatAxisBarView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @EnvironmentObject var errorManager: ErrorManager
    
    @Binding var axis: AxiesData
    let index: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Axis \(axis.axisNumber)")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            HStack(spacing: 0) {
                flatValueBar(isRight: false, axle: axis, index: index)
                ZStack {
                    tireImage
                    VStack(spacing: 2) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("L")
                            Text("\(axis.axisNumber)")
                                .font(.roboto500, size: 12)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.getTemperature(isRight: false)
                                .applyTemperatureSystem(selectedSystem: viewModel.selectedTemperatureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedTemperatureType.measureMark)
                                .font(.roboto500, size: 12)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.getPressure(isRight: false)
                                .applyPreassureSystem(selectedSystem: viewModel.selectedPreassureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedPreassureType.measureMark)
                                .font(.roboto500, size: 12)
                                .opacity(0.8)
                                .padding(.bottom, 1)
                        }
                    }
                    .font(.roboto400, size: 16)
                    .foregroundStyle(Color.white)
                    .frame(width: 56)
                }
                .zIndex(2.0)
                .padding(.trailing, 12)
                ZStack {
                    tireImage
                    VStack(spacing: 2) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("R")
                            Text("\(axis.axisNumber)")
                                .font(.roboto500, size: 12)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.getTemperature(isRight: true)
                                .applyTemperatureSystem(selectedSystem: viewModel.selectedTemperatureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedTemperatureType.measureMark)
                                .font(.roboto500, size: 12)
                                .opacity(0.8)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(axis.getPressure(isRight: true)
                                .applyPreassureSystem(selectedSystem: viewModel.selectedPreassureType)
                                .formattedToOneDecimalPlace())
                            Text(viewModel.selectedPreassureType.measureMark)
                                .font(.roboto500, size: 12)
                                .opacity(0.8)
                                .padding(.bottom, 1)
                        }
                    }
                    .font(.roboto400, size: 16)
                    .foregroundStyle(Color.white)
                    .frame(width: 56)
                }
                .zIndex(2.0)
                flatValueBar(isRight: true, axle: axis, index: index)
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
        .frame(height: 86)
    }
    
    private func flatValueBar(isRight: Bool, axle: AxiesData, index: Int) -> some View {
        let backgroundColor = isRight ? errorManager.backgroundColors[index].1 : errorManager.backgroundColors[index].0
        let foregroundColor = isRight ? errorManager.foregroundColors[index].1 : errorManager.foregroundColors[index].0
        
        return ZStack {
            Rectangle()
                .foregroundStyle(backgroundColor)
            
            VStack(spacing: 2) {
                Text("Axle Temp")
                    .font(.roboto400, size: 10)
                
                HStack(alignment: .bottom, spacing: 5) {
                    Text("0.0")
                        .font(.roboto700, size: 18)
                    
                    Text(viewModel.selectedTemperatureType.measureMark)
                        .font(.roboto700, size: 10)
                        .padding(.bottom, 3)
                }
                
                TireTemperaturePlotView(
                    data: [0.0, 0.0, 0.0],
                    foregroundColor: foregroundColor
                )
                .padding(.horizontal)
                .padding(isRight ? .leading : .trailing, 10)
                .frame(height: 34)
            }
            .foregroundStyle(foregroundColor)
            .padding(.vertical, 6)
        }
        .padding(isRight ? .leading : .trailing, -10)
        .frame(height: 86)
    }
}

#Preview {
    MainScreenView()
        .environmentObject(NavigationManager())
        .environmentObject(MainViewModel())
}
