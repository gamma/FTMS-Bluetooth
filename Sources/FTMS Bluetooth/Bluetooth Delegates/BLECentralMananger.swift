//
//  BLECentralMananger.swift
//  FTMS Rower WatchKit Extension
//
//  Created by Gerry Weißbach on 16.09.19.
//  Copyright © 2019 Gerry Weißbach. All rights reserved.
//

import CoreBluetooth

@available(watchOS 6.0, *)
@available(iOS 13.0, *)
@available(OSX 10.15, *)
class BLECentralMananger: NSObject, CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("[BluetoothManager] state: unknown")
            break
        case .resetting:
            print("[BluetoothManager] state: resetting")
            break
        case .unsupported:
            print("[BluetoothManager] state: not available")
            break
        case .unauthorized:
            print("[BluetoothManager] state: not authorized")
            break
        case .poweredOff:
            print("[BluetoothManager] state: powered off")
            BluetoothManager.stopScanningForFTMS()
            break
        case .poweredOn:
            print("[BluetoothManager] state: powered on")
            break
        @unknown default:
            print("[BluetoothManager] state: unknown")
        }
        
        BluetoothManager.isReady.value = (central.state == .poweredOn)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        print("[BluetoothManager] did connect:", peripheral.name ?? "")
        peripheral.discoverServices([FTMSUUID.serviceFTMS.uuid])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("[BluetoothManager] did discover:", peripheral)
        BluetoothManager.stopScanningForFTMS();
        BluetoothManager.connectPeripheral(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        print("[BluetoothManager] did disconnect:", peripheral.name ?? "")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {

        print("[BluetoothManager] did fail to connect:", peripheral.name ?? "")
    }
}
