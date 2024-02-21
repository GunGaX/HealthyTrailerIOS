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
    
    private var centralManager: CBCentralManager!
    
    private var peripheral: CBPeripheral?
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
                fetchedTemperatureLine += stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if fetchedTemperatureLine.hasSuffix("</R>") {
                    let newTWD = parseData(dataString: fetchedTemperatureLine)
                    fetchedTemperatureLine = ""
                    
                    connectedTWD = newTWD
                }
            } else {
                print("Received empty or invalid value for characteristic \(characteristic.uuid)")
            }
        }
    }
    
    func parseData(dataString: String) -> TWDModel? {
        guard let peripheral else { return nil }
        
        let components = dataString.components(separatedBy: "</L>,<R>")
        guard components.count == 2 else { return nil }
        
        let leftAxleComponents = components[0].components(separatedBy: ",")
        let rightAxleComponents = components[1].components(separatedBy: ",")
        
        var newTWDModel = TWDModel(
            id: peripheral.identifier,
            name: peripheral.name ?? "no name",
            leftAxle: [nil, nil, nil, nil],
            rightAxle: [nil, nil, nil, nil]
        )
        
        func getTemperatureValue(from component: String) -> Double? {
            let components = component.components(separatedBy: ":")
                        
            guard components.count == 2, let temperature = Double(components[1].replacingOccurrences(of: " F>", with: "").replacingOccurrences(of: "F>", with: "").replacingOccurrences(of: "F></R>", with: "")) else { return nil }
            
            return temperature
        }
        
        for index in 1..<leftAxleComponents.count {
            if let temperature = getTemperatureValue(from: leftAxleComponents[index]), temperature > -100 {
                newTWDModel.leftAxle[index - 1] = temperature
            }
            
            if let temperature = getTemperatureValue(from: rightAxleComponents[index]), temperature > -100 {
                newTWDModel.rightAxle[index - 1] = temperature
            }
        }
        
        let leftCount = newTWDModel.leftAxle.filter({ $0 != nil }).count
        let rightCount = newTWDModel.rightAxle.filter({ $0 != nil }).count
        
        if leftCount == rightCount {
            newTWDModel.axiesCount = leftCount
        } else {
            print("[Error][BluetoothTWDManager] unequal axies count")
        }
                
        return newTWDModel
    }
}

