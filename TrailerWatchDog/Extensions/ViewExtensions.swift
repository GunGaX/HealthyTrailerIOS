//
//  ViewExtensions.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 09.11.2023.
//

import Foundation
import SwiftUI

extension View {
    func navigationDestinations() -> some View {
        modifier(NavigationDestinationsViewModifier())
    }
    
    func defaultAlert(_ alert: Binding<AlertType?>) -> some View {
        modifier(AlertView(alertStep: alert))
    }
    
    func connectingTPMSAlertView(_ show: Binding<Bool>, discoveredTPMSDevices: [String], tireToConnect: String, onButtonTap: @escaping (String) -> Void, onCancelTap: @escaping () -> Void) -> some View {
        modifier(
            ConnectTPMSAlertView(
                showAlert: show, 
                discoveredTMPSDevices: discoveredTPMSDevices,
                tireToConnect: tireToConnect,
                onButtonTap: onButtonTap,
                onCancelTap: onCancelTap
            )
        )
    }
}
