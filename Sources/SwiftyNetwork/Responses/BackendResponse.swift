//
//  BackendResponse.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

// MARK: - Unified backend response
public enum BackendResponse<T> {
    /// Request succeeded, decoded into type `T`
    case success(T, status: any HTTPStatusRepresentable)

    /// Request succeeded but no content (e.g., 204 No Content)
    case noContent(status: any HTTPStatusRepresentable)

    /// Request failed with an HTTP error
    case failure(status: any HTTPStatusRepresentable, body: Data?)
}
