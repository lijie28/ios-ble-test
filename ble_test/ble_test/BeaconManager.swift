//
//  BeaconManager.swift
//  ble_test
//
//  Created by Jack on 2020/11/19.
//  Copyright © 2020 Jack. All rights reserved.
//

import UIKit
import CoreLocation

protocol BeaconManagerDelegate {
    func tellSth(mes: String)
    func didEnterRegion()
}

class BeaconManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = BeaconManager()
    
    var delegate: BeaconManagerDelegate?
    var myLocationManager: CLLocationManager!
    var myBeaconRegion: CLBeaconRegion!
    var beaconUuids: NSMutableArray!
    var beaconDetails: NSMutableArray!
    var on = false
    let myBeaconUUIDList = [
        "FDA50693-A4E2-4FB1-AFCF-C6EB07647825"
//        "fda50693-a4e2-4fb1-afcf-c6eb07647825"
    ]
    
    override init() {
        super.init()
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
    }
    
    func needServe(_ need: Bool) {
        if need {
            if myLocationManager == nil {
                myLocationManager = CLLocationManager()
                myLocationManager.delegate = self
                myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
                myLocationManager.distanceFilter = 1
                myLocationManager.allowsBackgroundLocationUpdates = true
                let status = CLLocationManager.authorizationStatus()
                print("CLAuthorizedStatus: \(status.rawValue)");
                if(status == .notDetermined) {
                    myLocationManager.requestAlwaysAuthorization()
                }
                on = true
            }
        } else {
            myLocationManager.delegate = nil
            myLocationManager = nil
            delegate?.tellSth(mes: "set location manager = nil")
            on = false
        }
    }
    
    func startMyMonitoring() {
        for i in 0 ..< myBeaconUUIDList.count {
            let uuid: NSUUID! = NSUUID(uuidString: "\(myBeaconUUIDList[i])")
            let identifierStr: String = "com.mybeacon.region.\(i)"
            if #available(iOS 13.0, *) {
                myBeaconRegion = CLBeaconRegion(uuid: uuid as UUID, identifier: identifierStr)
            } else {
                myBeaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: identifierStr)
            }
            myBeaconRegion.notifyEntryStateOnDisplay = false
            myBeaconRegion.notifyOnEntry = true
            myBeaconRegion.notifyOnExit = true
            myLocationManager.startMonitoring(for: myBeaconRegion)
            delegate?.tellSth(mes: "startMonitoring \(identifierStr)")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("locationManager didChangeAuthorizationStatus");
        switch (status) {
        case .notDetermined:
            print("not determined")
            break
        case .restricted:
            print("restricted")
            break
        case .denied:
            print("denied")
            break
        case .authorizedAlways:
            print("authorizedAlways")
            startMyMonitoring()
            break
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            startMyMonitoring()
            break
        @unknown default:
            print("unknown")
            break
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region);
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch (state) {
        case .inside:
            print("iBeacon inside");
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            break;
        case .outside:
            print("iBeacon outside")
            delegate?.tellSth(mes: "iBeacon outside")
            break;
        case .unknown:
            print("iBeacon unknown")
            delegate?.tellSth(mes: "iBeacon unknown")
            break;
        }
    }
    
    

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
        if(beacons.count > 0){
            for i in 0 ..< beacons.count {
                let beacon = beacons[i]

                let location = String(format: "%.3f", beacon.accuracy)
//                print( "距离beacon\(location)m")
                let beaconUUID = beacon.proximityUUID;
                let minorID = beacon.minor;
                let majorID = beacon.major;
                let rssi = beacon.rssi;
                var proximity = ""
                switch (beacon.proximity) {
                case CLProximity.unknown :
//                    print("Proximity: Unknown");
                    proximity = "Unknown"
                    break
                case CLProximity.far:
//                    print("Proximity: Far");
                    proximity = "Far"
                    break
                case CLProximity.near:
//                    print("Proximity: Near");
                    proximity = "Near"
                    break
                case CLProximity.immediate:
//                    print("Proximity: Immediate");
                    proximity = "Immediate"
                    break
                @unknown default:
                    break
                }
                beaconUuids.add(beaconUUID.uuidString)
                var myBeaconDetails = "Major: \(majorID) "
                myBeaconDetails += "Minor: \(minorID) "
                myBeaconDetails += "Proximity:\(proximity) "
                myBeaconDetails += "RSSI:\(rssi)"
//                print(myBeaconDetails)
                delegate?.tellSth(mes: "距离beacon\(location)m \n \(myBeaconDetails)")
                beaconDetails.add(myBeaconDetails)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion: iBeacon found");
        print( "进入beacon区域")
        delegate?.tellSth(mes: "进入beacon区域")
        delegate?.didEnterRegion()
        manager.startRangingBeacons(in: myBeaconRegion)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion: iBeacon lost");
         print("离开beacon区域")
         delegate?.tellSth(mes: "离开beacon区域")
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    
    
    

    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
}
