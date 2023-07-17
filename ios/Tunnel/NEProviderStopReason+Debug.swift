//
//  NEProviderStopReason+Debug.swift
//  Tunnel
//

import NetworkExtension

// Just for logging purposes, logging self or self.rawValue is un-readable.
extension NEProviderStopReason {
    var debugString: String {
        switch self {
        case .none:
            return "NEProviderStopReasonNone"
        case .userInitiated:
            return "NEProviderStopReasonUserInitiated"
        case .providerFailed:
            return "NEProviderStopReasonProviderFailed"
        case .noNetworkAvailable:
            return "NEProviderStopReasonNoNetworkAvailable"
        case .unrecoverableNetworkChange:
            return "NEProviderStopReasonUnrecoverableNetworkChange"
        case .providerDisabled:
            return "NEProviderStopReasonProviderDisabled"
        case .authenticationCanceled:
            return "NEProviderStopReasonAuthenticationCanceled"
        case .configurationFailed:
            return "NEProviderStopReasonConfigurationFailed"
        case .idleTimeout:
            return "NEProviderStopReasonIdleTimeout"
        case .configurationDisabled:
            return "NEProviderStopReasonConfigurationDisabled"
        case .configurationRemoved:
            return "NEProviderStopReasonConfigurationRemoved"
        case .superceded:
            return "NEProviderStopReasonSuperceded"
        case .userLogout:
            return "NEProviderStopReasonUserLogout"
        case .userSwitch:
            return "NEProviderStopReasonUserSwitch"
        case .connectionFailed:
            return "NEProviderStopReasonConnectionFailed"
        case .sleep:
            return "NEProviderStopReasonSleep"
        case .appUpdate:
            return "NEProviderStopReasonAppUpdate"
        @unknown default:
            return "Unsupported NEProviderStopReason"
        }
    }
}
