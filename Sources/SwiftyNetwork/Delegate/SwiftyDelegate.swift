//
//  BackendHandlerDelegate.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

/// Delegate protocol for `BackendHandler` to communicate important events back to the app layer.
///
/// Conform to this in your app layer to receive backend-related events like logging,
/// token invalidation, or backend throttling notifications.
public protocol SwiftyDelegate: AnyObject {

    /// Called whenever the backend handler wants to log a message (for debugging or monitoring).
    ///
    /// - Parameter message: A descriptive message about the backend operation.
    func addLogString(_ message: String)

    /// Called when authentication failed due to an invalid/expired token.
    ///
    /// - Parameter origin: The URL (or endpoint) that caused the failure.
    func authWasInvalid(origin: String)

    /// Called when the backend signals that it is temporarily unavailable
    /// (e.g. due to `429 Too Many Requests`).
    func backendUnavailable()
}
