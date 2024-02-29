//
//  DataManager.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 23.11.2023.
//

import Foundation
import SwiftUI
import CoreBluetooth
import CoreLocation
import UserNotifications
import os.log

let tpmsServiceCBUUID = CBUUID(string: "0xFBB0")

let saveDebugLog = false
let useOSConsoleLog = false

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

let csvHeader:String = "timestamp," +
    "lat,lon,latlon_acc_m,latlon_acc_ft," +
    "elevation_m,elevation_acc_m,elevation_ft,elevation_acc_ft," +
    "speed_mps,speed_acc_mps,speed_mph,speed_acc_mph," +
    "have_tire," +
    "tire_fl_kpa,tire_fl_psi,tire_fl_c,tire_fl_f," +
    "tire_fr_kpa,tire_fr_psi,tire_fr_c,tire_fr_f," +
    "tire_rl_kpa,tire_rl_psi,tire_rl_c,tire_rl_f," +
    "tire_rr_kpa,tire_rr_psi,tire_rr_c,tire_rr_f" +
    "\n"

class DataManager: NSObject, ObservableObject {
    static let shared = DataManager()
    
    @Published var latestRow: String = csvHeader
    @Published var screenText: String = "..."
    
    var connectedTWDId: String?
    var connectedTWDAxiesCount: Int?
    
    @Published var axies: [AxiesData] = []
    
    @Published var tpms_ids : [String] = []
    
    var connectedTPMSIds: [String] = []
    
    let locationManager = CLLocationManager()
    var centralManager: CBCentralManager!

    var latestLoc:CLLocation = CLLocation(latitude: 0, longitude: 0)
    var latestUpdate:Date = Date.init()
    
    var tpms_pressure_kpa : [String: Double] = [:]
    var tpms_temperature_c : [String: Double] = [:]
    var tpms_pressure_kpa_persist : [String: Double] = [:]
    var tpms_temperature_c_persist : [String: Double] = [:]
    var tpms_last_tick : [String: Date] = [:]
    
    var logPath:URL = URL.init(fileURLWithPath: "/dev/null")
    var haveLog = false
    var csvPath:URL = URL.init(fileURLWithPath: "/dev/null")
    var haveCsv = false
    
    var didStartCsv = false
    var didGetTireData = false
    
    var canShowNotifications = false
    
    func log(_ message:String) {
        if (useOSConsoleLog) {
            os_log("%@", log: .default, type: .info, message)
        }
        if (saveDebugLog && haveLog) {
            do {
                let fileHandle = try FileHandle(forWritingTo: logPath)
                let data = message.data(using: String.Encoding.utf8, allowLossyConversion: true)!
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } catch {
                self.log_error("Error appending to log \(self.logPath.absoluteString)")
            }
        }
    }
    func log_debug(_ message:String) {
        if (useOSConsoleLog) {
            os_log("%@", log: .default, type: .debug, message)
        }
        if (saveDebugLog && haveLog) {
            do {
                let fileHandle = try FileHandle(forWritingTo: logPath)
                let data = message.data(using: String.Encoding.utf8, allowLossyConversion: true)!
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } catch {
                self.log_error("Error appending to log \(self.logPath.absoluteString)")
            }
        }
    }
    func log_error(_ message:String) {
        if (useOSConsoleLog) {
            os_log("%@", log: .default, type: .error, message)
        }
        if (saveDebugLog && haveLog) {
            do {
                let fileHandle = try FileHandle(forWritingTo: logPath)
                let data = message.data(using: String.Encoding.utf8, allowLossyConversion: true)!
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } catch {
                os_log("Error appending to log", log: .default, type: .error)
            }
        }
    }
    func init_csv() {
        do {
            try csvHeader.write(to: self.csvPath, atomically: true, encoding: .utf8)
        } catch {
            self.log_error("Error writing to csv: \(self.csvPath.absoluteString)")
        }
    }
    func write_csv(_ csvLine:String) {
        if (haveCsv) {
            if (!didStartCsv) {
                init_csv()
                didStartCsv = true
            }
            do {
                let fileHandle = try FileHandle(forWritingTo: csvPath)
                let data = csvLine.data(using: String.Encoding.utf8, allowLossyConversion: true)!
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } catch {
                self.log_error("Error appending to csv: `\(self.csvPath.absoluteString)`")
            }
        } else {
            self.log_error("Tried to write CSV line, but `haveCsv` is false.")
        }
    }
    
    override init() {
        super.init()
    }
    
    func setup(connectedTWDId: String?, connectedTWDAxiesCount: Int?) {
        guard let connectedTWDId, let connectedTWDAxiesCount else { return }
        self.connectedTWDId = connectedTWDId
        self.connectedTWDAxiesCount = connectedTWDAxiesCount
        
        for index in 0..<connectedTWDAxiesCount {
            axies.append(AxiesData(axisNumber: index + 1, leftTire: TPMSModel.emptyState, rightTire: TPMSModel.emptyState))
        }
        
        fetchConnectedTPMStoTWD()
        
        loadLastData()
        
        let path = try? FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
        if (path != nil) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-MM-dd'T'HHmmss"
            let nowStr = dateFormatter.string(from: Date.init())
            let csv_fn = "data-\(nowStr).csv"
            csvPath = path!.appendingPathComponent(csv_fn)
            haveCsv = true

            if (saveDebugLog) {
                let log_fn = "log-\(nowStr).txt"
                logPath = path!.appendingPathComponent(log_fn)
                haveLog = true
            }
        }

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func loadLastData() {
        guard !connectedTPMSIds.isEmpty else { return }
        
        for index in 1...connectedTPMSIds.count {
            guard !connectedTPMSIds[index - 1].isEmpty else { return }
            let tpms = UserDefaults.standard.getObject(forKey: "lastLog_TPMS\(connectedTPMSIds[index - 1])", castTo: TPMSModel.self)
            
            guard let tpms else { return }
            
            let axleIndex: Int = Int((index - 1) / 2)
            
            if index % 2 == 0 {
                axies[axleIndex].rightTire = tpms
                axies[axleIndex].isRightSaved = true
                axies[axleIndex].isRightCleanTPMS = false
            } else {
                axies[axleIndex].leftTire = tpms
                axies[axleIndex].isLeftSaved = true
                axies[axleIndex].isLeftCleanTPMS = false
            }
        }
        
        canShowNotifications = true
    }
    
    func disconnectTWD() {
        axies = []
        connectedTWDId = nil
        connectedTWDAxiesCount = nil
        connectedTPMSIds = []
    }
    
    func saveLastConnectedTPMSDevices() {
        guard connectedTWDId != nil else { return }
        
        UserDefaults.standard.setObject(connectedTPMSIds, forKey: "LastConnectedTPMSDevices")
    }
    
    func forgetLastConnectedTPMSDevices() {
        UserDefaults.standard.removeObject(forKey: "LastConnectedTPMSDevices")
    }
    
    func getLastConnectedTPMSDevices() -> [String] {
        if let lastConnectedTPMSDevices = UserDefaults.standard.getObject(forKey: "LastConnectedTPMSDevices", castTo: [String].self) {
            return lastConnectedTPMSDevices
        } else {
            return []
        }
    }
    
    func saveConnectedTPMStoTWD() {
        guard let connectedTWDId else { return }
        
        UserDefaults.standard.setObject(connectedTPMSIds, forKey: "TPMSDevicesForTWD\(connectedTWDId)")
    }
    
    func deleteConnectedTPMStoTWD() {
        guard let connectedTWDId else { return }
        
        UserDefaults.standard.removeObject(forKey: "TPMSDevicesForTWD\(connectedTWDId)")
    }
    
    func fetchConnectedTPMStoTWD() {
        guard let connectedTWDId else { return }
        
        if let retrievedIds = UserDefaults.standard.getObject(forKey: "TPMSDevicesForTWD\(connectedTWDId)", castTo: [String].self) {
            connectedTPMSIds = retrievedIds
        }
    }
    
    func performLastConnectedTPMSAction(connectedDevices: [String]) {        
        connectedTPMSIds = connectedDevices
        saveConnectedTPMStoTWD()
        saveLastConnectedTPMSDevices()
    }
    
    func newData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd'T'HH:mm:ss.SSSZZZ"
        let timeStr = dateFormatter.string(from: latestUpdate)
        
        let lat = self.latestLoc.coordinate.latitude
        let lon = self.latestLoc.coordinate.longitude
        let latlon_acc = self.latestLoc.horizontalAccuracy
        let elevation = self.latestLoc.altitude
        let elevation_acc = self.latestLoc.verticalAccuracy
        var vel = self.latestLoc.speed
        var vel_acc = self.latestLoc.speedAccuracy
        
        if (vel < 0) {
            vel = 0
        }
        if (vel_acc < 0) {
            vel_acc = 0
        }

        // http://www.kylesconverter.com/speed-or-velocity/meters-per-second-to-miles-per-hour
        
        let c_latlon_acc_ft = latlon_acc * 3.280839895013123
        let c_elevation_ft = elevation * 3.280839895013123
        let c_elevation_ft_acc = elevation_acc * 3.280839895013123
        let c_vel_mph = vel * 2.2369362920544025
        let c_vel_mph_acc = vel_acc * 2.2369362920544025

        let f_lat = String(format: "%.4f", lat)
        let f_lon = String(format: "%.4f", lon)
        
        let f_ele_ft = String(format: "%.1f", c_elevation_ft)
        let f_ele_ft_acc = String(format: "%.1f", c_elevation_ft_acc)
        let f_vel_mph = String(format: "%.1f", c_vel_mph)
        let f_vel_mph_acc = String(format: "%.1f", c_vel_mph_acc)
        
        let f_latlon_acc_ft = String(format: "%d", Int(c_latlon_acc_ft))

        latestRow = "\(timeStr),\(lat),\(lon),\(latlon_acc),\(c_latlon_acc_ft),\(elevation),\(elevation_acc),\(c_elevation_ft),\(c_elevation_ft_acc),\(vel),\(vel_acc),\(c_vel_mph),\(c_vel_mph_acc)"
        
        screenText = "\(timeStr)\n\(f_lat), \(f_lon) (± \(f_latlon_acc_ft) ft)\n@ \(f_ele_ft) ft (± \(f_ele_ft_acc))\n\n\(f_vel_mph) mph (± \(f_vel_mph_acc))\n\n"
        
        var haveTire = "0"
        for key in tpms_last_tick.keys {
            let pressure_kpa = tpms_pressure_kpa[key]
            let temperature_c = tpms_temperature_c[key]
            if (pressure_kpa ?? 0 >= 50.0) && (pressure_kpa ?? 0 < 300.0) {
                haveTire = "1"
            }
            if (temperature_c != 0.0) {
                haveTire = "1"
            }
        }
        latestRow += ",\(haveTire)"

        for key in tpms_last_tick.keys {
            let pressure_kpa = tpms_pressure_kpa[key]
            let pressure_kpa_persist = tpms_pressure_kpa_persist[key]
            let pressure_psi = (pressure_kpa ?? 0 * 0.14503773779)
            let pressure_psi_persist = (pressure_kpa_persist ?? 0 * 0.14503773779)
            let temperature_c = tpms_temperature_c[key]
            let temperature_c_persist = tpms_temperature_c_persist[key]
            let temperature_f = ((temperature_c ?? 0 * 9/5) + 32)
            let temperature_f_persist = ((temperature_c_persist ?? 0 * 9/5) + 32)

            let f_pressure_kpa: Double = 0
            let f_pressure_psi: Double = 0
            let f_temperature_c: Double = 0
            let f_temperature_f: Double = 0
            
            var f_pressure_psi_screen: Double = 0
            var f_temperature_f_screen: Double = 0
            
            let formatPsi = NumberFormatter()
            formatPsi.minimumFractionDigits = 2
            formatPsi.maximumFractionDigits = 2
            let formatFahrenheit = NumberFormatter()
            formatFahrenheit.minimumFractionDigits = 1
            formatFahrenheit.maximumFractionDigits = 1
            let formatSeconds = NumberFormatter()
            formatSeconds.minimumFractionDigits = 1
            formatSeconds.maximumFractionDigits = 1
            
            var haveVal = false
            
            var finalPreassure = -1000.0
            
            if (pressure_kpa_persist ?? 0 >= 0.5) && (pressure_kpa_persist ?? 0 < 300.0) {
                finalPreassure = Double(pressure_kpa_persist ?? 0)
                haveVal = true
            } else {
                f_pressure_psi_screen = 0
            }
            
            var finalTemperature = -1000.0
            
            if (temperature_c_persist != 0.0) {
                finalTemperature = temperature_f_persist
            } else {
                f_temperature_f_screen = 0
            }
            let secSinceLastTick: Double = abs(tpms_last_tick[key]?.timeIntervalSinceNow ?? 0)
            var f_sec_screen: Double = 0
            if (haveVal) {
                f_sec_screen = secSinceLastTick
            } else {
                f_sec_screen = 0
            }
            
            latestRow += ",\(f_pressure_kpa),\(f_pressure_psi),\(f_temperature_c),\(f_temperature_f)"
            
            for index in 0..<axies.count {
                if axies[index].leftTire.id == key {
                    if finalTemperature != -1000.0 {
                        axies[index].leftTire.tireData.temperature = finalTemperature
                    }
                    if finalPreassure != -1000.0 {
                        axies[index].leftTire.tireData.preassure = finalPreassure
                    }
                    axies[index].leftTire.tireData.updateDate = Date.now
                }
                
                if axies[index].rightTire.id == key {
                    if finalTemperature != -1000.0 {
                        axies[index].rightTire.tireData.temperature = finalTemperature
                    }
                    if finalPreassure != -1000.0 {
                        axies[index].rightTire.tireData.preassure = finalPreassure
                    }
                    axies[index].rightTire.tireData.updateDate = Date.now
                }
            }
        }
                
        latestRow += "\n"
        
        self.log_debug("\(self.latestRow)")
        if (didGetTireData) {
            self.write_csv(latestRow)
        }

        for key in tpms_pressure_kpa.keys {
            tpms_pressure_kpa[key] = 0.0
            tpms_temperature_c[key] = 0.0
        }

        if ((centralManager.state == .poweredOn) && !centralManager.isScanning) {
            centralManager.scanForPeripherals(withServices: [tpmsServiceCBUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
}

extension DataManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        latestLoc = locations[0]
        latestUpdate = Date.init()
        self.newData()
    }
}

extension DataManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .resetting:
            self.log_debug("central.state is .resetting")
        case .unsupported:
            self.log_debug("central.state is .unsupported")
        case .unauthorized:
            self.log_debug("central.state is .unauthorized")
        case .poweredOff:
            self.log_debug("central.state is .poweredOff")
        case .poweredOn:
            self.log_debug("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [tpmsServiceCBUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case .unknown:
            self.log("central.state is .unknown")
        default:
            self.log("unhandled central state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var name = ""
        if (peripheral.name != nil) {
            name = peripheral.name!
        }
        var s = "\nADVERTISEMENT FOUND:\n\(name):\t\(peripheral.identifier)\n"
        s += "CBAdvertisementDataLocalNameKey: \(advertisementData[CBAdvertisementDataLocalNameKey] ?? "none")\n"
        s += "CBAdvertisementDataManufacturerDataKey: \(advertisementData[CBAdvertisementDataManufacturerDataKey] ?? "none")\n"
        
        s += "CBAdvertisementDataServiceDataKey: \(advertisementData[CBAdvertisementDataServiceDataKey] ?? "none")\n"
        s += "CBAdvertisementDataServiceUUIDsKey: \(advertisementData[CBAdvertisementDataServiceUUIDsKey] ?? "none")\n"
        s += "CBAdvertisementDataOverflowServiceUUIDsKey: \(advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] ?? "none")\n"
        s += "CBAdvertisementDataTxPowerLevelKey: \(advertisementData[CBAdvertisementDataTxPowerLevelKey] ?? "none")\n"
        s += "CBAdvertisementDataIsConnectable: \(advertisementData[CBAdvertisementDataIsConnectable] ?? "none")\n"
        s += "CBAdvertisementDataSolicitedServiceUUIDsKey: \(advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey] ?? "none")\n"
        s += "\n=====\n\n"
        
        self.log_debug(s)
        
        // Per https://github.com/ricallinson/tpms/blob/c142138098c383e703635c2f6fb166a03134793c/sensor.go
        // bytes 8,9,10,11 / 1000 -> pressure in kpa
        // bytes 12,13,14,15 /100 -> temp in celsius
        let rawData:Data = advertisementData[CBAdvertisementDataManufacturerDataKey] as! Data
        let pressureRaw = rawData.subdata(in: Range(8...11))
        let pressureConv:Double = pressureRaw.withUnsafeBytes { Double($0.load(as: UInt32.self)) } / 1000.0
        let temperatureRaw = rawData.subdata(in: Range(12...15))
        let temperatureConv:Double = temperatureRaw.withUnsafeBytes { Double($0.load(as: UInt32.self)) } / 100.0
        
        if !tpms_ids.contains(name) {
            tpms_ids.append(name)
        }

        if connectedTPMSIds.contains(name) {
            let haveGoodTick = ((pressureConv != 0.0) || (temperatureConv != 0.0))
            if (haveGoodTick) {
                didGetTireData = true
                tpms_pressure_kpa[name] = pressureConv
                tpms_temperature_c[name] = temperatureConv
                if pressureConv != 0.0 {
                    tpms_pressure_kpa_persist[name] = pressureConv
                }
                if temperatureConv != 0.0 {
                    tpms_temperature_c_persist[name] = temperatureConv
                }
                latestUpdate = Date()
                tpms_last_tick[name] = Date()
            
                self.newData()
            }
        }
    }
}
