//
//  BLEManager.swift
//  ble_test
//
//  Created by Jack on 2020/6/30.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol BLEManagerDelegate {
    
    func didConnected()
}

class BLEManager: NSObject {
    
    static let shared = BLEManager()
    
    var delegate: BLEManagerDelegate?
    
    var manager: CBCentralManager?
    var theOne: CBPeripheral?
    
    private var writeCharacteristic: CBCharacteristic!
    
    override init() {
        super.init()
        self.newManager()
    }
    
    func newManager() {
        self.manager = CBCentralManager.init(delegate: self, queue: nil)
    }
    
    func writeData(_ data: Data) {
        print(#function)
        self.theOne?.writeValue(data, for: self.writeCharacteristic, type: .withoutResponse)
    }
    
    
    func stopScan() {
        if let manager = self.manager, manager.isScanning {
            manager.stopScan()
        }
    }
    
    func scanAndConnect() {
        print("scanAndConnect: \(self.manager?.state ?? nil)")
        guard let manager = self.manager else {
            return
        }
        if manager.state == .poweredOn {
//            UIApplicationState state = [UIApplication sharedApplication].st
            let uuid = CBUUID(string:"FFF0")
            manager.scanForPeripherals(withServices: [uuid], options: nil)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.scanAndConnect()
            }
        }
    }
    
    func connect() {
        if let theOne = self.theOne {
            self.manager?.connect(theOne, options: nil)
        } else {
            self.scanAndConnect()
        }
    }
    
    func getConnectState() -> CBPeripheralState? {
        
        return theOne?.state
    }
    
}

// MARK: CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("is poweredOn,scan")
        default:
            print("is else")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print(#function)
        self.manager?.stopScan()
        self.theOne = peripheral
        self.theOne?.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(#function)
        self.theOne = nil
        if let manager = self.manager, manager.isScanning {
            manager.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(#function)
        if (peripheral == self.theOne) {
            print("didDisconnectPeripheral:", peripheral)
            self.theOne = nil
            
            if let manager = self.manager, manager.isScanning {
                manager.stopScan()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print(#function)
//        print(peripheral)
        if (peripheral.name == "HC-42") {
            print(peripheral)
            self.theOne = peripheral
            self.manager?.connect(self.theOne!, options: nil)
        }
    }
    
    
}

// MARK: CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print(#function)
        if error != nil {
            print("连接外设失败===\(String(describing: error))")
            return
        }
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print(#function, service)
        print("发现特征的服务:\(service.uuid.data)   ===  服务UUID:\(service.uuid)")
        if error != nil {
            print("发现错误的特征：\(String(describing: error?.localizedDescription))")
            return
        }
        
        for characteristic in service.characteristics! {
            switch characteristic.uuid.uuidString.uppercased() {
            case "FFE1":
                print("连接成功")
            
                self.theOne?.setNotifyValue(true, for: characteristic)
                self.writeCharacteristic = characteristic
                self.delegate?.didConnected()
                self.manager?.stopScan()
                break
            default:
                print("未找到特殊值:, \(characteristic.uuid.description ),\(characteristic.uuid.uuidString )")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        print(#function, characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        
        print(#function, service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("更新数据失败\(String(describing: error?.localizedDescription))")
            return
        }
        let data = characteristic.value
        
        print("返回的数据是：\(data!)")
//        if self.delegate != nil {
//            self.delegate.readData(data: data)
//        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if error != nil {
            print("发送数据失败!error信息:\(String(describing: error))")
        }
    }
}
