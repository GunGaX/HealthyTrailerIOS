//
//  TerminalView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct TerminalView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            SecondaryHeaderView(titleText: "Terminal")
            
            ScrollView {
                
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    TerminalView()
        .environmentObject(NavigationManager())
}
