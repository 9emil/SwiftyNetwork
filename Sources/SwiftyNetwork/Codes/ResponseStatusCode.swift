//
//  ResponseStatusCode.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

/// Enum representing categories of HTTP status codes
public enum ResponseStatusCode {
    case informational
    case successful
    case redirect
    case clientError
    case serverError

    static func from(_ code: Int) -> ResponseStatusCode? {
        switch code {
        case 100..<200: return .informational
        case 200..<300: return .successful
        case 300..<400: return .redirect
        case 400..<500: return .clientError
        case 500..<600: return .serverError
        default: return nil
        }
    }

    /// Attempts to map an Int status code to a conforming enum case
    func responseStatus(from code: Int) -> (any HTTPStatusRepresentable)? {
        if let status = InformationalResponse(rawValue: code) {
            return status
        } else if let status = SuccessfulResponse(rawValue: code) {
            return status
        } else if let status = RedirectionResponse(rawValue: code) {
            return status
        } else if let status = ClientErrorResponse(rawValue: code) {
            return status
        } else if let status = ServerErrorResponse(rawValue: code) {
            return status
        } else {
            return nil
        }
    }
}
