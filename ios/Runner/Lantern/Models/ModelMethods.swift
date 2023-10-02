//
//  ModelMethods.swift
//  Runner
//
//  Created by jigar fumakiya on 20/09/23.
//

import Foundation
import Internalsdk

// This extension encapsulates various methods related to different models in the application, providing a type-safe way to reference methods for go (internalsdk).
//
extension SessionModel {
    enum Methods {
        case acceptTerms
        case createUser
        case getBandwidth
        case initModel
        case setCurrency
        case setDeviceId
        case setDnsServer
        case setEmail
        case setForceCountry
        case setLocal
        case setProvider
        case setProUser
        case setReferralCode
        case setSelectedTab
        case setStoreVersion
        case setTimezone

        var methodName: String {
            switch self {
            case .acceptTerms:
                return InternalsdkSESSION_MODEL_METHOD_ACCEPT_TERMS
            case .createUser:
                return InternalsdkSESSION_MODEL_METHOD_CREATE_USER
            case .getBandwidth:
                return InternalsdkSESSION_MODEL_METHOD_GET_BANDWIDTH
            case .initModel:
                return InternalsdkSESSION_MODEL_METHOD_INIT_MODEL
            case .setCurrency:
                return InternalsdkSESSION_MODEL_METHOD_SET_CURRENCY
            case .setDeviceId:
                return InternalsdkSESSION_MODEL_METHOD_SET_DEVICEID
            case .setDnsServer:
                return InternalsdkSESSION_MODEL_METHOD_SET_DNS_SERVER
            case .setEmail:
                return InternalsdkSESSION_MODEL_METHOD_SET_EMAIL
            case .setForceCountry:
                return InternalsdkSESSION_MODEL_METHOD_SET_FORCE_COUNTRY
            case .setLocal:
                return InternalsdkSESSION_MODEL_METHOD_SET_LOCAL
            case .setProvider:
                return InternalsdkSESSION_MODEL_METHOD_SET_PROVIDER
            case .setProUser:
                return InternalsdkSESSION_MODEL_METHOD_SET_PRO_USER
            case .setReferralCode:
                return InternalsdkSESSION_MODEL_METHOD_SET_REFERAL_CODE
            case .setSelectedTab:
                return InternalsdkSESSION_MODEL_METHOD_SET_SELECTED_TAB
            case .setStoreVersion:
                return InternalsdkSESSION_MODEL_METHOD_SET_STORE_VERSION
            case .setTimezone:
                return InternalsdkSESSION_MODEL_METHOD_SET_TIMEZONE
            }
        }
    }
}
