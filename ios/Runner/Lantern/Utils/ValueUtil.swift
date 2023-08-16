//
//  Value.swift
//  Runner
//
//  Created by jigar fumakiya on 28/07/23.
//

import Foundation
import Internalsdk
import SQLite



class ValueUtil {
    // Define the types constants
    static let TYPE_BYTES = 0
    static let TYPE_STRING = 1
    static let TYPE_INT = 2
    
    static func makeValue(from anyValue: Any) -> MinisqlValue {
        let value: MinisqlValue!
        switch anyValue {
        case is String:
            value = MinisqlValue(string: anyValue as! String)
        case is Int:
            value = MinisqlValue(int: anyValue as! Int)
        case is UInt8:
            value = MinisqlValue(bytes: anyValue as! Data)
        default:
            fatalError("Unsupported type")
        }
        return value
    }

    static func getValue(from internalsdkValue: MinisqlValue) -> Any {
        switch internalsdkValue.type {
        case TYPE_STRING:
            return internalsdkValue.string
        case TYPE_INT:
            return Int(internalsdkValue.int_)
        case TYPE_BYTES:
            return internalsdkValue.bytes
        default:
            fatalError("Unsupported type")
        }
    }

    static func toBindingsArray(_ args: MinisqlValuesProtocol) -> [Binding?] {
        var bindings = [Binding?]()
        for i in 0..<args.len() {
            guard let arg = args.get(i) else {
                bindings.append(nil)
                continue
            }
            switch arg.type {
            case TYPE_STRING:
                bindings.append(arg.string)
            case TYPE_INT:
                bindings.append(arg.int_)
            case TYPE_BYTES:
                bindings.append(arg.bytes)
            default:
                bindings.append(nil)
            }
        }
        return bindings
    }
}
