//
//  ViewController.swift
//  ble_test
//
//  Created by Jack on 2020/6/30.
//  Copyright © 2020 Jack. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    let bleManager = BLEManager.shared
    let beacomManager = BeaconManager.shared
    
    @IBOutlet weak var labBeaconInfo: UILabel!
    
    @IBOutlet weak var labBleInfo: UILabel!
    @IBOutlet weak var labBleTableView: UITableView!
    @IBOutlet weak var labBleTitle: UILabel!
    @IBOutlet weak var btnOn: UIButton!
    
    @IBOutlet weak var btnOff: UIButton!
    @IBOutlet weak var btnSetBeacon: UIButton!
    
    
    private var connectedBlock: (() -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
//        bleManager.delegate = self
//        beacomManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(didActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func enterBackground() {
        self.bleManager.stopScan()
    }
    
    @objc func didActive() {
        print("didActive")
        self.bleManager.connect()
    }
    
    @IBAction func clickAtOn(_ sender: Any) {
        
        openDoor()
    }
    
    @IBAction func clickAtOff(_ sender: Any) {
        
        //        self.writeCharacteristic
        closeDoor()
    }
    
    private func openDoor() {
        
        let value: UInt8 = 0x11
        let writeData = Data([value])
        self.bleManager.writeData(writeData)
    }
    
    private func closeDoor() {
        
        let value: UInt8 = 0x10
        let writeData = Data([value])
        self.bleManager.writeData(writeData)
    }
    
    @IBAction func clickOnSetBeacon(_ sender: Any) {
        
        beacomManager.needServe(!beacomManager.on)
        if beacomManager.on {
            self.btnSetBeacon.setTitle("关闭beacon定位", for: .normal)
            //            beacomManager.delegate = self
        } else {
            self.btnSetBeacon.setTitle("开启beacon定位", for: .normal)
        }
    }
}

extension ViewController: BeaconManagerDelegate {
    
    func didEnterRegion() {
//        if self.bleManager.getConnectState() == . connected {
//            openDoor()
//        } else {
//            self.bleManager.scanAndConnect()
//            self.connectedBlock = { [weak self] () -> () in
//                self?.openDoor()
//            }
//        }
    }
    
    
    func tellSth(mes: String) {
        guard self.labBeaconInfo != nil else { return}
        self.labBeaconInfo.text = mes
    }
}

extension ViewController: BLEManagerDelegate {
    
    func didConnected() {
//        if let connectedBlock = self.connectedBlock {
//            connectedBlock()
//            self.connectedBlock = nil
//        }
    }
}
