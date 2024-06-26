//
//  Value.swift
//  Runner
//
//  Created by jigar fumakiya on 28/07/23.
//

import Foundation
import Internalsdk
import SQLite

public class ValueUtil {
  // Define the types constants
  public static let TYPE_BYTES = Int(MinisqlValueTypeBytes)
  public static let TYPE_STRING = Int(MinisqlValueTypeString)
  public static let TYPE_INT = Int(MinisqlValueTypeInt)
  public static let TYPE_BOOL = Int(MinisqlValueTypeBool)

  public static func makeValue(from anyValue: Any) -> MinisqlValue {
    let value: MinisqlValue!

    switch anyValue {
    case is String:
      value = MinisqlNewValueString(anyValue as! String)
    case is Int:
      value = MinisqlNewValueInt(anyValue as! Int)
    case is Bool:
      value = MinisqlNewValueBool(anyValue as! Bool)
    case is UInt8:
      let blob = anyValue as! SQLite.Blob
      let data = Data(blob.bytes)
      value = MinisqlNewValueBytes(data)
    default:
      fatalError("Unsupported type \(type(of: anyValue)) with value: \(anyValue)")
    }
    return value
  }

  public static func convertFromMinisqlValue(from internalsdkValue: MinisqlValue) -> Any? {
    switch internalsdkValue.type {
    case TYPE_STRING:
      return internalsdkValue.string()
    case TYPE_INT:
      return Int(internalsdkValue.int_() as Int)
    case TYPE_BYTES:
      return internalsdkValue.bytes()
    case TYPE_BOOL:
      return internalsdkValue.bool_()
    default:
      fatalError("Unsupported type")
    }
  }

  public static func toBindingsArray(_ args: MinisqlValuesProtocol) -> [Binding?] {
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
