//
//  AppDelegate.swift
//  ble_test
//
//  Created by Jack on 2020/6/30.
//  Copyright © 2020 Jack. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    
    let beaconManager = BeaconManager.shared
    //    let bleManager = BLEManager.shared
    private var connectedBlock: (() -> Void)? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = ViewController()
        self.window?.backgroundColor = UIColor.red
        self.window?.makeKeyAndVisible()
//        [UIApplication sharedApplication]
        //        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types:([.alert,.sound,.badge]), categories: nil))
        //        UIApplication.shared.registerForRemoteNotifications()
        //
        //        //在通过Location唤醒时，launchOptions包含了UIApplicationLaunchOptionsLocationKey，
        //        //用于只是是从Location重新唤醒的。
        //        if let option = launchOptions, let _ = option[.location] as? NSNumber {
        //            SENLocationManager.sharedInstance.startMonitor(relaunch: true);
        //        }
        beaconManager.needServe(true)
        beaconManager.delegate = self
        beaconManager.startMyMonitoring()
        
        BLEManager.shared.delegate = self
        BLEManager.shared.connect()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    //    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    //        // Called when a new scene session is being created.
    //        // Use this method to select a configuration to create the new scene with.
    //        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    //    }
    //
    //    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    //        // Called when the user discards a scene session.
    //        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    //        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    //    }
    private func openDoor() {
        
        let value: UInt8 = 0x11
        let writeData = Data([value])
        BLEManager.shared.writeData(writeData)
    }
    
    private func closeDoor() {
        
        let value: UInt8 = 0x10
        let writeData = Data([value])
        BLEManager.shared.writeData(writeData)
    }
    
}

extension AppDelegate: BeaconManagerDelegate {
    
    func didEnterRegion() {
        if BLEManager.shared.getConnectState() == . connected {
            openDoor()
        } else {
            if BLEManager.shared.manager?.state != .poweredOn {
                BLEManager.shared.newManager()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    BLEManager.shared.scanAndConnect()
                    self.connectedBlock = { [weak self] () -> () in
                        self?.openDoor()
                    }
                }
            } else {
                BLEManager.shared.scanAndConnect()
                self.connectedBlock = { [weak self] () -> () in
                    self?.openDoor()
                }
            }
        }
    }
    
    
    func tellSth(mes: String) {
        //        guard self.labBeaconInfo != nil else { return}
        //        self.labBeaconInfo.text = mes
    }
}

extension AppDelegate: BLEManagerDelegate {
    
    func didConnected() {
        if let connectedBlock = self.connectedBlock {
            connectedBlock()
            self.connectedBlock = nil
        }
    }
}
