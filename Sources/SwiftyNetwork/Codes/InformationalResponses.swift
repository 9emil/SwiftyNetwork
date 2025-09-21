//
//  InformationalResponses.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

/// Enum representing HTTP 1xx informational responses
public enum InformationalResponse: Int {
    /// 100 Continue - The server has received the request headers and the client should proceed to send the request body.
    case `continue` = 100

    /// 101 Switching Protocols - The requester has asked the server to switch protocols.
    case switchingProtocols = 101

    /// 102 Processing - The server has received and is processing the request, but no response is available yet.
    case processing = 102

    /// 103 Early Hints - Used to return some response headers before final HTTP message.
    case earlyHints = 103
}

extension InformationalResponse {
    public var description: String {
        switch self {
        case .continue: return "Continue"
        case .switchingProtocols: return "Switching Protocols"
        case .processing: return "Processing"
        case .earlyHints: return "Early Hints"
        }
    }
}

extension InformationalResponse: HTTPStatusRepresentable {
    public var code: Int {
        return rawValue
    }

    public var category: ResponseStatusCode {
        return .successful
    }
}
