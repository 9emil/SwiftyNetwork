//
//  SuccessfulResponses.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

/// Enum representing HTTP 2xx successful responses
public enum SuccessfulResponse: Int {
    /// 200 OK - The request has succeeded.
    case ok = 200

    /// 201 Created - The request has succeeded and a new resource has been created.
    case created = 201

    /// 202 Accepted - The request has been accepted for processing, but the processing is not complete.
    case accepted = 202

    /// 203 Non-Authoritative Information - The returned meta-information is not exactly the same as available from the origin server.
    case nonAuthoritativeInformation = 203

    /// 204 No Content - The server successfully processed the request, but is not returning any content.
    case noContent = 204

    /// 205 Reset Content - The server successfully processed the request, but is not returning any content and requires that the requester reset the document view.
    case resetContent = 205

    /// 206 Partial Content - The server is delivering only part of the resource due to a range header sent by the client.
    case partialContent = 206
}

extension SuccessfulResponse {
    public var description: String {
        switch self {
        case .ok: return "OK"
        case .created: return "Created"
        case .accepted: return "Accepted"
        case .nonAuthoritativeInformation: return "Non-Authoritative Information"
        case .noContent: return "No Content"
        case .resetContent: return "Reset Content"
        case .partialContent: return "Partial Content"
        }
    }
}

extension SuccessfulResponse: HTTPStatusRepresentable {
    public var code: Int {
        return rawValue
    }

    public var category: ResponseStatusCode {
        return .successful
    }
}
