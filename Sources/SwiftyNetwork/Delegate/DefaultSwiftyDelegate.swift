//
//  DefaultBackendHandlerDelegate.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

/// Default delegate implementation that logs to the console (only in DEBUG builds).
///
/// This is provided so consumers of `SwiftyNetwork` don’t *have* to set a delegate
/// unless they want custom behavior.
public final class DefaultSwiftyDelegate: SwiftyDelegate {
    public init() {}

    public func addLogString(_ message: String) {
        #if DEBUG
        print("SwiftyNetwork: \(message)")
        #endif
    }

    public func authWasInvalid(origin: String) {
        #if DEBUG
        print("SwiftyNetwork: authWasInvalid at \(origin)")
        #endif
    }

    public func backendUnavailable() {
        #if DEBUG
        print("SwiftyNetwork: backendUnavailable")
        #endif
    }

    public func serverTime(moment: Double) {
        #if DEBUG
        print("SwiftyNetwork: serverTime: \(moment)")
        #endif
    }
}
