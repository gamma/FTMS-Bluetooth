//
//  Fields.swift
//  Read data of varying sizes from given data object.
//  Specifically for reading FTMS data objects.
//
//  see https://github.com/svenmeier/coxswain/blob/72d9a806c4a6f7bef2dbfaa415871284d5f3a19d/app/src/main/java/svenmeier/coxswain/bluetooth/Fields.java
//
//  Created by Gerry Weißbach on 27.09.19.
//

import Foundation

extension FixedWidthInteger {
    var byteWidth:Int {
        return self.bitWidth/UInt8.bitWidth
    }
    static var byteWidth:Int {
        return Self.bitWidth/UInt8.bitWidth
    }
}

public class Fields {

    public static var UINT8 = UInt8.self.byteWidth
    public static var UINT16 = UInt16.self.byteWidth
    public static var UINT32 = UInt32.self.byteWidth
    public static var SINT16 = Int16.self.byteWidth

    var flags: UInt16 = 0

    var data: NSData

    var offset = 0
    
    // Init and read flags
    init( _ data: NSData, flagSize: Int ) {
        self.data = data;
        self.flags = get( Fields.UINT16 )
    }

    // Return the bool value of the given flag number.
    public func flag( _ bit: Int) -> Bool {
        return (flags & (1 << bit)) != 0;
    }
    
    // Read the fields. Always going forward, should be used only once per read cycle
    public func get<T>( _ format: Int ) -> T {
        
        var value: T = NSNumber(0) as! T
        self.data.getBytes(&value, range: NSRange.init(location: offset, length: format))
        offset += format & 0xf
        
        return value
    }
}
