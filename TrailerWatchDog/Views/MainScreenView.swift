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
        }
    }
    
    private var logOutButton: some View {
        Button {
            withAnimation {
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
            connectedDeviceInfo
        } else {
            tryToConnectButton
        }
    }
    
    private var connectedDeviceInfo: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("Connected:")
                .foregroundStyle(Color.textDark)
            
            Text("TWD-DEVICE-NAME")
                .foregroundStyle(Color.mainBlue)
        }
        .font(.roboto500, size: 16)
    }
    
    private var tryToConnectButton: some View {
        Button {
            dataManager.setup(tempSystem: viewModel.selectedTemperatureType, preassureSystem: viewModel.selectedPreassureType)
            withAnimation {
                viewModel.isTWDConnected = true
            }
            
            startTimerAndUploadingData()
        } label: {
            Text("Try to connect")
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
    
    private func startTimerAndUploadingData() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            viewModel.updateLastValuesData()
        }
    }
}

fileprivate struct AxisBarView: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    var axis: AxiesData
    
    var body: some View {
        HStack(spacing: -20) {
            valueBar(tireValue: axis.leftTire.temperature, isRight: false)
            
            ZStack {
                Image("fillAxisImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                
                HStack {
                    VStack {
                        Text("\(axis.axisNumber * 2 - 1)")
                        Text("Avg:")
                            .opacity(0.8)
                        HStack(alignment: .bottom, spacing: 5) {
                            Text(applyMeasureType(value: 0))
                            Text(viewModel.selectedTemperatureType.measureMark)
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
                        Text("\(axis.axisNumber * 2)")
                        Text("Avg:")
                            .opacity(0.8)
                        HStack(alignment: .bottom, spacing: 5) {
                            Text(applyMeasureType(value: 0))
                            Text(viewModel.selectedTemperatureType.measureMark)
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
            
            valueBar(tireValue: axis.rightTire.temperature, isRight: true)
        }
    }
    
    private func valueBar(tireValue: Double, isRight: Bool) -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.lightGreen)
                .padding(.top, 2)
                .padding(.bottom, 1)
            
            HStack(alignment: .bottom, spacing: 5) {
                Text(applyMeasureType(value: tireValue))
                    .font(.roboto700, size: 18)
                
                Text(viewModel.selectedTemperatureType.measureMark)
                    .font(.roboto700, size: 10)
                    .padding(.bottom, 3)
            }
            .foregroundStyle(Color.mainGreen)
            .padding(isRight ? .trailing : .leading, -10)
        }
    }
    
    private func applyMeasureType(value: Double) -> String {
        switch viewModel.selectedTemperatureType {
        case .celsius: return value.formattedToOneDecimalPlace()
        case .fahrenheit: return value.formattedToOneDecimalPlace()
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
                flatValueBar(tireValues: ChartData.tempArray, isRight: false)
                ZStack {
                    tireImage
                    VStack {
                        Text("\(axis.axisNumber * 2 - 1)")
                        Text("Avg:")
                            .opacity(0.8)
                        HStack(alignment: .bottom, spacing: 5) {
                            Text("0")
                            Text(viewModel.selectedTemperatureType.measureMark)
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
                        Text("\(axis.axisNumber * 2)")
                        Text("Avg:")
                            .opacity(0.8)
                        HStack(alignment: .bottom, spacing: 5) {
                            Text("0")
                            Text(viewModel.selectedTemperatureType.measureMark)
                                .font(.roboto500, size: 10)
                                .padding(.bottom, 1)
                        }
                    }
                    .font(.roboto500, size: 12)
                    .foregroundStyle(Color.white)
                    .frame(width: 44)
                }
                .zIndex(2.0)
                flatValueBar(tireValues: ChartData.tempArray, isRight: true)
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
    
    private func flatValueBar(tireValues: [Double], isRight: Bool) -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.lightGreen)
                .padding(.top, 2)
                .padding(.bottom, 1)
            
            VStack(spacing: 10) {
                HStack(alignment: .bottom, spacing: 5) {
                    Text((tireValues.last?.formattedToOneDecimalPlace() ?? "0.0"))
                        .font(.roboto700, size: 18)
                    
                    Text(viewModel.selectedTemperatureType.measureMark)
                        .font(.roboto700, size: 10)
                        .padding(.bottom, 3)
                }
                .foregroundStyle(Color.mainGreen)
                
                TireTemperaturePlotView(data: tireValues)
                    .padding(.horizontal)
                    .frame(height: 20)
            }
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
