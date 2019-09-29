//
//  File.swift
//  
//
//  Created by Gerry Weißbach on 18.09.19.
//

import Foundation
import Combine
import CoreBluetooth

class FTMSPeripheralDelegate : NSObject, CBPeripheralDelegate {

    var rowerData = Subject<RowerData>(value: RowerData())
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print( "[CBPeripheralDelegate] did discover FTMS service", peripheral.services! )
        peripheral.discoverCharacteristics(nil, for: peripheral.services![0])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print( "[CBPeripheralDelegate] did discover FTMS characteristic", service.characteristics ?? "" )
        
        service.characteristics?.forEach( { c in
            peripheral.setNotifyValue(true, for: c)
        } )
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print( "[CBPeripheralDelegate] did update value", descriptor )
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        switch( characteristic.uuid ) {
        case FTMSUUID.characteristicRowerData.uuid:

            guard let data = characteristic.value else { return }
            let fields = Fields( data as NSData, flagSize: Fields.UINT16 )
            
            if (fields.flag(0) == false) { // more data
                rowerData.value.strokeRate = fields.get(Fields.UINT8) / 2; // stroke rate 0.5
                rowerData.value.strokeCount = fields.get(Fields.UINT16); // stroke count
            }
            if (fields.flag(1)) {
                rowerData.value.averageStrokeRate = fields.get(Fields.UINT8); // average stroke rate
            }
            if (fields.flag(2)) {
                rowerData.value.totalDistance = fields.get(Fields.UINT16) +
                        (fields.get(Fields.UINT8) << 16); // total distance
            }
            if (fields.flag(3)) {
                rowerData.value.instantaneousPace = fields.get(Fields.UINT16); // instantaneous pace
            }
            if (fields.flag(4)) {
                rowerData.value.averagePace = fields.get(Fields.UINT16); // average pace
            }
            if (fields.flag(5)) {
                rowerData.value.instantaneousPower = fields.get(Fields.SINT16); // instantaneous power
            }
            if (fields.flag(6)) {
                rowerData.value.averagePower = fields.get(Fields.SINT16); // average power
            }
            if (fields.flag(7)) {
                rowerData.value.resistenceLevel = fields.get(Fields.SINT16); // resistance level
            }
            if (fields.flag(8)) { // expended energy
                rowerData.value.totalEnergy = fields.get(Fields.UINT16); // total energy
                rowerData.value.energyPerHour = fields.get(Fields.UINT16); // energy per hour
                rowerData.value.energyPerMinute = fields.get(Fields.UINT8); // energy per minute
            }
            if (fields.flag(9)) {
                let heartRate_ : UInt8 = fields.get(Fields.UINT8); // heart rate
                if (heartRate_ > 0) {
                    rowerData.value.heartRate = heartRate_;
                }
            }
            if (fields.flag(10)) {
                rowerData.value.metabolicEquivilent = fields.get(Fields.UINT8) * 10; // metabolic equivalent 0.1 kcal
            }
            if (fields.flag(11)) {
                let elapsedTime_ : UInt16 = fields.get(Fields.UINT16); // elapsed time
                let delta = elapsedTime_ - rowerData.value.elapsedTime;
                //  erroneous  values are sent on minute boundaries, so ignore these deltas
                if (delta == 59 || delta == 60) {
                    // 359 ... 300 ... 360
                    // 599 ... 659 ... 600
                    print("bluetooth rower erroneous elapsed time %s, duration is %s", elapsedTime_, rowerData.value.elapsedTime)
                } else {
                    rowerData.value.elapsedTime = elapsedTime_;
                }
            }
            if (fields.flag(12)) {
                rowerData.value.remainingTime = fields.get(Fields.UINT16); // remaining time
            }

            rowerData.notify()
            
            break;
        
        default:

            guard let data = characteristic.value else { return }
            print( "[STATUS]", characteristic.uuid, data)
            break;
        }
    }
}
