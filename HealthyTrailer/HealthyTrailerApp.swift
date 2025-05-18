//
//  HealthyTrailerApp.swift
//  HealthyTrailerApp
//
//  Created by Dmytro Savka on 08.11.2023.
//

import SwiftUI
import FirebaseCore
import BackgroundTasks

@main
struct HealthyTrailerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var navigationManager = NavigationManager()
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var errorManager = ErrorManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(navigationManager)
                .environmentObject(viewModel)
                .environmentObject(errorManager)
                .preferredColorScheme(.light)
                .onAppear {
                    disableDisplaySleep()
//                    checkPermissions()
                }
        }
    }
    
    private func disableDisplaySleep() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
//    private func checkPermissions() {
//        if LocationManager.shared.checkIfAccessIsGranted() && BluetoothManager.shared.checkBluetooth() {
//            navigationManager.appState = .app
//        }
//    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.GunGaX.HealthyTrailer.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        scheduleAppRefresh()
        return true
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.GunGaX.HealthyTrailer.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 30) // 1 minutes
        try? BGTaskScheduler.shared.submit(request)
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        DataManager.shared.refreshData()
        task.setTaskCompleted(success: true)
    }
}
