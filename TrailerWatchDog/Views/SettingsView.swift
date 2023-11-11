//
//  SettingsView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var maxTPMSSensorTemperature = 0.7728
    @State private var maxDifferenceTPMSSensorTemperature = 0.3
    @State private var maxTWDSensorTemperature = 0.7728
    @State private var maxDifferenceTWDSensorTemperature = 0.3
    
    let axlesCount: Int = 3
    
    var body: some View {
        VStack(spacing: 0) {
            SecondaryHeaderView(titleText: "Settings")
            ScrollView {
                VStack(spacing: 40) {
                    axlesInfo
                        .padding(.top, 20)
                    
                    DefaultSignleSliderView(value: $maxTPMSSensorTemperature, titleText: "Max allowed TPMS sensor temperature (default 170)", minValue: 32, maxValue: 220)
                    DefaultSignleSliderView(value: $maxDifferenceTPMSSensorTemperature, titleText: "Max allowed difference in TPMS sensor temperature (default 30)", minValue: 0, maxValue: 100)
                    
                    DefaultSignleSliderView(value: $maxTWDSensorTemperature, titleText: "Max allowed TWD sensor temperature (default 170)", minValue: 32, maxValue: 220)
                    DefaultSignleSliderView(value: $maxDifferenceTWDSensorTemperature, titleText: "Max allowed difference in TWD sensor temperature (default 30)", minValue: 0, maxValue: 100)
                    
                    
                }
                .padding(.horizontal)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden()
    }
    
    private var axlesInfo: some View {
        HStack(spacing: 20) {
            Text("Axles:")
                .foregroundStyle(Color.textDark)
                .font(.roboto500, size: 18)
                .padding(.trailing, 20)
            
            Text(axlesCount.description)
                .foregroundStyle(Color.mainGrey)
                .font(.roboto500, size: 26)
                .padding(30)
                .background(
                    Circle()
                        .foregroundStyle(Color.lightGrayBackground)
                )
            
            Text("This parameter is determined automatically")
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.mainGrey)
                .font(.roboto400, size: 14)
                
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SettingsView()
        .environmentObject(NavigationManager())
}
