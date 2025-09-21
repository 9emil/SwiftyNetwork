//
//  UnknownResponse.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//


/// Fallback for unknown/unhandled HTTP status codes.
public struct UnknownResponse: HTTPStatusRepresentable {

    // MARK: - RawRepresentable
    public let rawValue: Int

    /// Initialize with a raw HTTP status code
    public init?(rawValue: Int) {
        self.rawValue = rawValue
    }

    internal init(code: Int) {
        self.rawValue = code
    }

    // MARK: - HTTPStatusRepresentable
    /// The numeric status code (same as rawValue)
    public var code: Int { rawValue }

    /// Description for unknown response
    public var description: String { "Unknown" }

    /// Category for unknown status (fallback to clientError)
    public var category: ResponseStatusCode {
        ResponseStatusCode.from(code) ?? .clientError
    }
}
