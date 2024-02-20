//
//  BluetoothTWDManager.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 14.02.2024.
//

import SwiftUI
import CoreBluetooth

class BluetoothTWDManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BluetoothTWDManager()
    
    private let temperature_characteristic = CBUUID(string: "FFE1")
    
    private var characteristicData: [CBCharacteristic] = []
    
    private var peripheral: CBPeripheral?

    private var centralManager: CBCentralManager!
    
    @Published var discoveredPeripherals: [CBPeripheral] = []
    
    override init() {
        super.init()
    }
    
    func setupBluetooth() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connectToDevice(peripheral: CBPeripheral?) {
        if let peripheral {
            centralManager.connect(peripheral, options: nil)
            
            self.peripheral = peripheral
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil, !discoveredPeripherals.map({ $0.identifier }).contains(peripheral.identifier) else { return }
                
        discoveredPeripherals.append(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        peripheral.delegate = self
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for charac in service.characteristics!{
            
            characteristicData.append(charac)
            if charac.uuid == temperature_characteristic {
                peripheral.setNotifyValue(true, for: charac)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error reading characteristic value: \(error.localizedDescription)")
            return
        }
        
        guard let value = characteristic.value else {
            print("Received empty characteristic value")
            return
        }
        
        if characteristic.uuid == temperature_characteristic {
            if let value = characteristic.value, let stringValue = String(data: value, encoding: .utf8) {
                print(stringValue)
            } else {
                print("Received empty or invalid value for characteristic \(characteristic.uuid)")
            }
        }
    }
}
