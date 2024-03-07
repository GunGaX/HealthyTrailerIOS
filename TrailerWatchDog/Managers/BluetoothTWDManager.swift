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
    
    var canShowNotifications = false
    
    private let temperature_characteristic = CBUUID(string: "FFE1")
    
    private var centralManager: CBCentralManager!
    
    var peripheral: CBPeripheral?
    private var characteristicData: [CBCharacteristic] = []
    
    var fetchedTemperatureLine: String = ""
    
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedTWD: TWDModel?
    
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
            
            self.getLastTWDLog()
        }
    }
    
    func disconnectFromDevice() {
        if let peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        
        peripheral = nil
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
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
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
                fetchedTemperatureLine += stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if fetchedTemperatureLine.hasSuffix("</R>") {
                    parseData(dataString: fetchedTemperatureLine)
                    fetchedTemperatureLine = ""
                }
            } else {
                print("Received empty or invalid value for characteristic \(characteristic.uuid)")
            }
        }
    }
    
    private func parseData(dataString: String) {
        guard let peripheral else { return }
        
        let components = dataString.components(separatedBy: "</L>,<R>")
        guard components.count == 2 else { return }
        
        let leftAxleComponents = components[0].components(separatedBy: ",")
        let rightAxleComponents = components[1].components(separatedBy: ",")
        
        if connectedTWD == nil {
            connectedTWD = TWDModel(
                id: peripheral.identifier,
                name: peripheral.name ?? "no name",
                leftAxle: [[], [], [], []],
                rightAxle: [[], [], [], []]
            )
        }
        
        guard connectedTWD != nil else { return }
        
        for index in 1..<leftAxleComponents.count {
            if let temperature = getTemperatureValue(from: leftAxleComponents[index]), temperature > -100 {
                connectedTWD!.addNewTemperature(isRight: false, newTemperature: temperature, index: index - 1)
            }
            
            if let temperature = getTemperatureValue(from: rightAxleComponents[index]), temperature > -100 {
                connectedTWD!.addNewTemperature(isRight: true, newTemperature: temperature, index: index - 1)
            }
        }
        
        let leftCount = connectedTWD!.getLeftAxleCount()
        let rightCount = connectedTWD!.getRighttAxleCount()
        
        if leftCount == rightCount {
            connectedTWD!.axiesCount = leftCount
        } else {
            print("[Error][BluetoothTWDManager] unequal axies count")
        }
        
        canShowNotifications = true
    }
    
    public func updateLastTWDValuesData() {
        guard let connectedTWD else { return }
        
        UserDefaults.standard.setObject(connectedTWD, forKey: "lastLog_TWD\(connectedTWD.id.uuidString)")
    }
    
    public func getLastTWDLog() {
        guard let peripheral else { return }
        
        if let twd = UserDefaults.standard.getObject(forKey: "lastLog_TWD\(peripheral.identifier.uuidString)", castTo: TWDModel.self) {
            connectedTWD = twd
        }
    }
    
    func getTemperatureValue(from component: String) -> Double? {
        let components = component.components(separatedBy: ":")
                    
        guard components.count == 2, let temperature = Double(components[1].replacingOccurrences(of: " F>", with: "").replacingOccurrences(of: "F>", with: "").replacingOccurrences(of: "F></R>", with: "")) else { return nil }
        
        return temperature
    }
    
    public func resetDiscoveredPeripherals() {
        discoveredPeripherals = []
    }
}

