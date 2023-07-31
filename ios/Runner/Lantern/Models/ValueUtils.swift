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
    static let TYPE_STRING = 0
    static let TYPE_INT = 1
    static let TYPE_BOOL = 2

    static func makeValue(from anyValue: Any) -> InternalsdkValue {
        let value = InternalsdkValue()
        switch anyValue {
        case is String:
            value.type = TYPE_STRING
            value.string = anyValue as! String
        case is Int:
            value.type = TYPE_INT
            value.int_ = Int(anyValue as! Int)
        case is Bool:
            value.type = TYPE_BOOL
            value.bool_ = anyValue as! Bool
        default:
            fatalError("Unsupported type")
        }
        return value
    }

    static func getValue(from internalsdkValue: InternalsdkValue) -> Any {
        switch internalsdkValue.type {
        case TYPE_STRING:
            return internalsdkValue.string
        case TYPE_INT:
            return Int(internalsdkValue.int_)
        case TYPE_BOOL:
            return internalsdkValue.bool_
        default:
            fatalError("Unsupported type")
        }
    }

    static func toBindingsArray(_ args: InternalsdkValueArrayProtocol) -> [Binding?] {
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
            case TYPE_BOOL:
                bindings.append(arg.bool_)
            default:
                bindings.append(nil)
            }
        }
        return bindings
    }
}
