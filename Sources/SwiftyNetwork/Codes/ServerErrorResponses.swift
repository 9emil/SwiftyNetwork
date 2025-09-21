//
//  ServerErrorResponses.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

/// Enum representing HTTP 5xx server error responses
public enum ServerErrorResponse: Int {
    /// 500 Internal Server Error - The server encountered an unexpected condition that prevented it from fulfilling the request.
    case internalServerError = 500

    /// 501 Not Implemented - The server does not recognize the request method, or it lacks the ability to fulfill it.
    case notImplemented = 501

    /// 502 Bad Gateway - The server received an invalid response from the upstream server.
    case badGateway = 502

    /// 503 Service Unavailable - The server is currently unable to handle the request due to temporary overload or maintenance.
    case serviceUnavailable = 503

    /// 504 Gateway Timeout - The server did not receive a timely response from the upstream server.
    case gatewayTimeout = 504

    /// 505 HTTP Version Not Supported - The server does not support the HTTP protocol version used in the request.
    case httpVersionNotSupported = 505

    /// 506 Variant Also Negotiates - Transparent content negotiation for the request results in a circular reference.
    case variantAlsoNegotiates = 506

    /// 507 Insufficient Storage - The server is unable to store the representation needed to complete the request.
    case insufficientStorage = 507

    /// 508 Loop Detected - The server detected an infinite loop while processing a request.
    case loopDetected = 508

    /// 510 Not Extended - Further extensions to the request are required for the server to fulfill it.
    case notExtended = 510

    /// 511 Network Authentication Required - The client needs to authenticate to gain network access.
    case networkAuthenticationRequired = 511
}

extension ServerErrorResponse {
    public var description: String {
        switch self {
        case .internalServerError: return "Internal Server Error"
        case .notImplemented: return "Not Implemented"
        case .badGateway: return "Bad Gateway"
        case .serviceUnavailable: return "Service Unavailable"
        case .gatewayTimeout: return "Gateway Timeout"
        case .httpVersionNotSupported: return "HTTP Version Not Supported"
        case .variantAlsoNegotiates: return "Variant Also Negotiates"
        case .insufficientStorage: return "Insufficient Storage"
        case .loopDetected: return "Loop Detected"
        case .notExtended: return "Not Extended"
        case .networkAuthenticationRequired: return "Network Authentication Required"
        }
    }
}

extension ServerErrorResponse: HTTPStatusRepresentable {
    public var code: Int {
        return rawValue
    }

    public var category: ResponseStatusCode {
        return .successful
    }
}
