//
//  HTTPStatusRepresentable.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

/// A protocol that represents an HTTP status code and provides metadata
public protocol HTTPStatusRepresentable: RawRepresentable, CustomStringConvertible where RawValue == Int {
    /// The numeric status code (e.g. 200)
    var code: Int { get }

    /// The short description of the status code (e.g. "OK")
    var description: String { get }

    /// High-level category (e.g. .Successful, .ClientError)
    var category: ResponseStatusCode { get }
}
