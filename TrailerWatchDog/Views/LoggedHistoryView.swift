//
//  LoggedHistoryView.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 10.11.2023.
//

import SwiftUI

struct LoggedHistoryView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            SecondaryHeaderView(titleText: "Logged History")
            
            ScrollView {
                
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    LoggedHistoryView()
        .environmentObject(NavigationManager())
}
