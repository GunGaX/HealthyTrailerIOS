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
            .environmentObject(viewModel)
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
            
            ForEach(viewModel.axis, id: \.self) { axis in
                axisBar(leftTireValue: 27.2, rightTireValue: 34.2, leftTireAvg: 34, rightTireAvg: 34, axisNumber: axis)
                if axis != viewModel.axis.last {
                    separatingAxisBar
                }
            }

            Image("fillTrailerBack")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
        }
    }
    
    private func axisBar(leftTireValue: Double, rightTireValue: Double, leftTireAvg: Int, rightTireAvg: Int, axisNumber: Int) -> some View {
        HStack(spacing: -20) {
            valueBar(tireValue: leftTireValue, isRight: false)
            
            ZStack {
                Image("fillAxisImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                    
                
                HStack {
                    VStack {
                        Text("\(axisNumber * 2 - 1)")
                        Text("Avg:")
                            .opacity(0.8)
                        HStack(alignment: .bottom, spacing: 5) {
                            Text(leftTireAvg.description)
                            Text("°C")
                                .font(.roboto500, size: 10)
                                .padding(.bottom, 1)
                        }
                    }
                    .font(.roboto500, size: 14)
                    .foregroundStyle(Color.white)
                    .frame(width: 44)
                    Spacer()
                    VStack {
                        Text("\(axisNumber * 2)")
                        Text("Avg:")
                            .opacity(0.8)
                        HStack(alignment: .bottom, spacing: 5) {
                            Text(rightTireAvg.description)
                            Text("°C")
                                .font(.roboto500, size: 10)
                                .padding(.bottom, 1)
                        }
                    }
                    .font(.roboto500, size: 14)
                    .foregroundStyle(Color.white)
                    .frame(width: 44)
                }
            }
            .zIndex(2.0)
            
            valueBar(tireValue: rightTireValue, isRight: true)
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
            withAnimation {
                viewModel.isTWDConnected = true
            }
        } label: {
            Text("Try to connect")
        }
        .buttonStyle(.mainBlueButton)
    }
    
    private var flatTrailer: some View {
        VStack(spacing: 10) {
            
            ForEach(viewModel.axis, id: \.self) { axis in
                flatAxisBar(leftTireValue: 27.2, rightTireValue: 34.2, leftTireAvg: 34, rightTireAvg: 34, axisNumber: axis)
            }
        }
    }
    
    private func flatAxisBar(leftTireValue: Double, rightTireValue: Double, leftTireAvg: Int, rightTireAvg: Int, axisNumber: Int) -> some View {
        VStack(spacing: 8) {
            Text("Axis \(axisNumber)")
                .font(.roboto500, size: 16)
                .foregroundStyle(Color.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            HStack(spacing: 0) {
                flatValueBar(tireValues: ChartData.mockArray, isRight: false)
                ZStack {
                    tireImage
                    VStack {
                        Text("\(axisNumber * 2 - 1)")
                        Text("Avg:")
                            .opacity(0.8)
                        HStack(alignment: .bottom, spacing: 5) {
                            Text(leftTireAvg.description)
                            Text("°C")
                                .font(.roboto500, size: 10)
                                .padding(.bottom, 1)
                        }
                    }
                    .font(.roboto500, size: 14)
                    .foregroundStyle(Color.white)
                    .frame(width: 44)
                }
                .zIndex(2.0)
                .padding(.trailing, 12)
                ZStack {
                    tireImage
                    VStack {
                        Text("\(axisNumber * 2)")
                        Text("Avg:")
                            .opacity(0.8)
                        HStack(alignment: .bottom, spacing: 5) {
                            Text(rightTireAvg.description)
                            Text("°C")
                                .font(.roboto500, size: 10)
                                .padding(.bottom, 1)
                        }
                    }
                    .font(.roboto500, size: 14)
                    .foregroundStyle(Color.white)
                    .frame(width: 44)
                }
                .zIndex(2.0)
                flatValueBar(tireValues: ChartData.mockArray, isRight: true)
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
    
    private func valueBar(tireValue: Double, isRight: Bool) -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.lightGreen)
                .padding(.top, 2)
                .padding(.bottom, 1)
            
            HStack(alignment: .bottom, spacing: 5) {
                Text(tireValue.description)
                    .font(.roboto700, size: 18)
                
                Text("°C")
                    .font(.roboto700, size: 10)
                    .padding(.bottom, 3)
            }
            .foregroundStyle(Color.mainGreen)
            .padding(isRight ? .trailing : .leading, -10)
        }
    }
    
    private func flatValueBar(tireValues: [ChartData], isRight: Bool) -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.lightGreen)
                .padding(.top, 2)
                .padding(.bottom, 1)
            
            VStack(spacing: 10) {
                HStack(alignment: .bottom, spacing: 5) {
                    Text(tireValues.last?.value.description ?? "0.0")
                        .font(.roboto700, size: 18)
                    
                    Text("°C")
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
