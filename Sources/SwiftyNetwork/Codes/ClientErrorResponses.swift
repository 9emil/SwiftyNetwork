//
//  ClientErrorResponses.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

/// Enum representing HTTP 4xx client error responses
public enum ClientErrorResponse: Int {
    /// 400 Bad Request - The server could not understand the request due to invalid syntax.
    case badRequest = 400

    /// 401 Unauthorized - Authentication is required and has failed or has not yet been provided.
    case unauthorized = 401

    /// 402 Payment Required - Reserved for future use.
    case paymentRequired = 402

    /// 403 Forbidden - The client does not have access rights to the content.
    case forbidden = 403

    /// 404 Not Found - The server can not find the requested resource.
    case notFound = 404

    /// 405 Method Not Allowed - The request method is known by the server but has been disabled.
    case methodNotAllowed = 405

    /// 406 Not Acceptable - The server cannot produce a response matching the list of acceptable values.
    case notAcceptable = 406

    /// 407 Proxy Authentication Required - Authentication with a proxy is required.
    case proxyAuthenticationRequired = 407

    /// 408 Request Timeout - The server timed out waiting for the request.
    case requestTimeout = 408

    /// 409 Conflict - The request conflicts with the current state of the server.
    case conflict = 409

    /// 410 Gone - The requested resource is no longer available and will not be available again.
    case gone = 410

    /// 411 Length Required - The server refuses to accept the request without a defined Content-Length header.
    case lengthRequired = 411

    /// 412 Precondition Failed - The server does not meet one of the preconditions sent in the request.
    case preconditionFailed = 412

    /// 413 Payload Too Large - The request is larger than the server is willing or able to process.
    case payloadTooLarge = 413

    /// 414 URI Too Long - The URI provided was too long for the server to process.
    case uriTooLong = 414

    /// 415 Unsupported Media Type - The media format of the request is not supported by the server.
    case unsupportedMediaType = 415

    /// 416 Range Not Satisfiable - The range specified by the Range header field in the request can't be fulfilled.
    case rangeNotSatisfiable = 416

    /// 417 Expectation Failed - The server can't meet the requirements of the Expect request-header field.
    case expectationFailed = 417

    /// 418 I'm a teapot - April Fools' joke; not implemented.
    case imATeapot = 418

    /// 421 Misdirected Request - The request was directed at a server that is not able to produce a response.
    case misdirectedRequest = 421

    /// 422 Unprocessable Entity - The server understands the content type of the request but was unable to process it.
    case unprocessableEntity = 422

    /// 423 Locked - The resource that is being accessed is locked.
    case locked = 423

    /// 424 Failed Dependency - The request failed due to failure of a previous request.
    case failedDependency = 424

    /// 425 Too Early - Indicates that the server is unwilling to risk processing a request that might be replayed.
    case tooEarly = 425

    /// 426 Upgrade Required - The client should switch to a different protocol.
    case upgradeRequired = 426

    /// 428 Precondition Required - The server requires the request to be conditional.
    case preconditionRequired = 428

    /// 429 Too Many Requests - The user has sent too many requests in a given amount of time.
    case tooManyRequests = 429

    /// 431 Request Header Fields Too Large - The server is unwilling to process the request because its header fields are too large.
    case requestHeaderFieldsTooLarge = 431

    /// 451 Unavailable For Legal Reasons - The content has been made unavailable for legal reasons.
    case unavailableForLegalReasons = 451
}

extension ClientErrorResponse {
    public var description: String {
        switch self {
        case .badRequest: return "Bad Request"
        case .unauthorized: return "Unauthorized"
        case .paymentRequired: return "Payment Required"
        case .forbidden: return "Forbidden"
        case .notFound: return "Not Found"
        case .methodNotAllowed: return "Method Not Allowed"
        case .notAcceptable: return "Not Acceptable"
        case .proxyAuthenticationRequired: return "Proxy Authentication Required"
        case .requestTimeout: return "Request Timeout"
        case .conflict: return "Conflict"
        case .gone: return "Gone"
        case .lengthRequired: return "Length Required"
        case .preconditionFailed: return "Precondition Failed"
        case .payloadTooLarge: return "Payload Too Large"
        case .uriTooLong: return "URI Too Long"
        case .unsupportedMediaType: return "Unsupported Media Type"
        case .rangeNotSatisfiable: return "Range Not Satisfiable"
        case .expectationFailed: return "Expectation Failed"
        case .imATeapot: return "I'm a teapot"
        case .misdirectedRequest: return "Misdirected Request"
        case .unprocessableEntity: return "Unprocessable Entity"
        case .locked: return "Locked"
        case .failedDependency: return "Failed Dependency"
        case .tooEarly: return "Too Early"
        case .upgradeRequired: return "Upgrade Required"
        case .preconditionRequired: return "Precondition Required"
        case .tooManyRequests: return "Too Many Requests"
        case .requestHeaderFieldsTooLarge: return "Request Header Fields Too Large"
        case .unavailableForLegalReasons: return "Unavailable For Legal Reasons"
        }
    }
}

extension ClientErrorResponse: HTTPStatusRepresentable {
    public var code: Int {
        return rawValue
    }

    public var category: ResponseStatusCode {
        return .clientError
    }
}
