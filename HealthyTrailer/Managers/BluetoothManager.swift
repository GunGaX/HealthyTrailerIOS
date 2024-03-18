//
//  BluetoothManager.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 14.11.2023.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    @Published var bluetoothEnabled = false
    static let shared = BluetoothManager()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            bluetoothEnabled = true
        case .poweredOff, .resetting, .unauthorized, .unknown, .unsupported:
            bluetoothEnabled = false
        @unknown default:
            break
        }
    }
    
    func checkBluetooth() -> Bool {
        if centralManager.state == .poweredOn {
            return true
        } else {
            return false
        }
    }
}
