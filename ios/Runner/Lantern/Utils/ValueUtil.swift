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
            value = MinisqlNewValueString(anyValue as! String)
        case is Int:
            value =  MinisqlNewValueInt(anyValue as! Int)
            //        case is SQLite.Blob:
            //            logger.log("Make value SQLite.Blob")
            //            let blob = anyValue as! SQLite.Blob
            //            let data:NSData = Data(blob.bytes)
            //            value = MinisqlNewValueBytes(data)
            //            logger.log("Make value SQLite.Blob Completed with \(data) \(blob.bytes)")
        case is UInt8:
            logger.log("Make value UInt8 with value \(anyValue)")
            let blob = anyValue as! SQLite.Blob
            let data = Data(blob.bytes)
            value = MinisqlNewValueBytes(data)
            logger.log("Make value UInt8 Completed with \(data.count) bytes \(blob.bytes)")
        default:
            fatalError("Unsupported type \(type(of: anyValue)) with value: \(anyValue)")
        }
        return value
    }
    
    static func getValue(from internalsdkValue: MinisqlValue) -> Any {
        switch internalsdkValue.type {
        case TYPE_STRING:
            return internalsdkValue.string()
        case TYPE_INT:
            return Int(internalsdkValue.int_() as Int)
        case TYPE_BYTES:
            return internalsdkValue.bytes()
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
                bindings.append(arg.string())
            case TYPE_INT:
                bindings.append(arg.int_())
            case TYPE_BYTES:
                let byteArray = [UInt8](arg.bytes()!)
                bindings.append(Blob(bytes: byteArray))
                
            default:
                bindings.append(nil)
            }
        }
        return bindings
    }
    
    static func fromBindingToMinisqlValue(binding: Binding) -> MinisqlValue {
        let value: MinisqlValue!
        switch binding.bindingType {
        case "String":
            value = MinisqlNewValueString(binding as! String)
        case "Int64":
            value =  MinisqlNewValueInt(Int(binding as! Int64))
        case "Blob":
            let blob = binding as! Blob
            let data = Data(blob.bytes)
            value = MinisqlNewValueBytes(data)
            logger.log("Blob value (Data representation): \(data)")
  default:
            fatalError("Unsupported SQLite.Binding type: \(binding.bindingType)")
        }
        return value
    }
    
    
    
}
extension Binding {
    var bindingType: String {
        switch self {
        case is Int64:
            return "Int64"
        case is Double:
            return "Double"
        case is String:
            return "String"
        case is Blob:
            return "Blob"
        case is NSNumber:
            return "NSNumber"
        default:
            return "Unknown"
        }
    }
}
