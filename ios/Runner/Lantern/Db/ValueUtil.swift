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
    static let TYPE_BYTES = Int(MinisqlValueTypeBytes)
    static let TYPE_STRING = Int(MinisqlValueTypeString)
    static let TYPE_INT = Int(MinisqlValueTypeInt)
    static let TYPE_BOOL = Int(MinisqlValueTypeBool)
    
    static func makeValue(from anyValue: Any) -> MinisqlValue {
        let value: MinisqlValue!
        
        switch anyValue {
        case is String:
            value = MinisqlNewValueString(anyValue as! String)
        case is Int:
            value =  MinisqlNewValueInt(anyValue as! Int)
        case is Bool:
            value =  MinisqlNewValueBool(anyValue as! Bool)
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
    
    static func convertFromMinisqlValue(from internalsdkValue: MinisqlValue) -> Any? {
        switch internalsdkValue.type {
        case TYPE_STRING:
            return internalsdkValue.string()
        case TYPE_INT:
            return Int(internalsdkValue.int_() as Int)
        case TYPE_BYTES:
            return internalsdkValue.bytes()!
        case TYPE_BOOL:
            return internalsdkValue.bool_()
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
            case TYPE_BOOL:
                bindings.append(arg.bool_())
            case TYPE_BYTES:
                if let bytes = arg.bytes() {
                    let byteArray = [UInt8](bytes)
                    bindings.append(Blob(bytes: byteArray))
                } else {
                    bindings.append(nil)
                }
                
            default:
                bindings.append(nil)
            }
        }
        return bindings
    }
    
    static func setValueFromBinding(binding: Binding, value: MinisqlValue) {
        switch binding.bindingType {
        case "String":
            value.setString(binding as? String)
        case "Int64":
            value.setInt(Int(binding as! Int64))
        case "Bool":
            value.setBool(Bool(binding as! Bool))
        case "Blob":
            let blob = binding as! Blob
            let data = Data(blob.bytes)
            value.setBytes(data)
        default:
            fatalError("Unsupported SQLite.Binding type: \(binding.bindingType)")
        }
    }
    
    static func convertToMinisqlValue(_ anyValue: Any) -> MinisqlValue? {
        switch anyValue {
        case is String:
            return MinisqlNewValueString(anyValue as! String)
        case is Int:
            return MinisqlNewValueInt(anyValue as! Int)
        case is Bool:
            return MinisqlNewValueBool(anyValue as! Bool)
        case is [Any]: // For arrays
            if let jsonData = try? JSONSerialization.data(withJSONObject: anyValue, options: []),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                return MinisqlNewValueString(jsonString)
            }
        case is [String: Any]: // For dictionaries
            if let jsonData = try? JSONSerialization.data(withJSONObject: anyValue, options: []),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                return MinisqlNewValueString(jsonString)
            }
        default:
            return MinisqlNewValueString("\(anyValue)")
        }
        return nil
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
        case is Bool:
            return "Bool"
        case is Blob:
            return "Blob"
        case is NSNumber:
            return "NSNumber"
        default:
            return "Unknown"
        }
    }
}
