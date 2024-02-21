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
//                    print(fetchedTemperatureLine)
                    fetchedTemperatureLine = ""
                    
                    print(newTWD ?? "no data")
                }
            } else {
                print("Received empty or invalid value for characteristic \(characteristic.uuid)")
            }
        }
    }
    
    func parseData(dataString: String) -> NewTWDModel? {
        guard let peripheral else { return nil }
        
        let components = dataString.components(separatedBy: "</L>,<R>")
        guard components.count == 2 else { return nil }
        
        let leftAxleComponents = components[0].components(separatedBy: ",")
        let rightAxleComponents = components[1].components(separatedBy: ",")
        
        var newTWDModel = NewTWDModel(id: peripheral.identifier , leftAxle: Axle(), rightAxle: Axle())
        
        func getTemperatureValue(from component: String) -> Double? {
            let components = component.components(separatedBy: ":")
                        
            guard components.count == 2, let temperature = Double(components[1].replacingOccurrences(of: " F>", with: "").replacingOccurrences(of: "F></R>", with: "")) else { return nil }
            
            return temperature
        }
                
        newTWDModel.leftAxle.firstTire = getTemperatureValue(from: leftAxleComponents[1])
        newTWDModel.leftAxle.secondTire = getTemperatureValue(from: leftAxleComponents[2])
        newTWDModel.leftAxle.thirdTire = getTemperatureValue(from: leftAxleComponents[3])
        newTWDModel.leftAxle.fourthTire = getTemperatureValue(from: leftAxleComponents[4])
        
        newTWDModel.rightAxle.firstTire = getTemperatureValue(from: rightAxleComponents[1])
        newTWDModel.rightAxle.secondTire = getTemperatureValue(from: rightAxleComponents[2])
        newTWDModel.rightAxle.thirdTire = getTemperatureValue(from: rightAxleComponents[3])
        newTWDModel.rightAxle.fourthTire = getTemperatureValue(from: rightAxleComponents[4])
                
        return newTWDModel
    }
}

struct NewTWDModel {
    let id: UUID
    var leftAxle: Axle
    var rightAxle: Axle
}

struct Axle {
    var firstTire: Double?
    var secondTire: Double?
    var thirdTire: Double?
    var fourthTire: Double?
}

