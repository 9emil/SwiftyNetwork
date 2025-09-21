//
//  RedirectionResponses.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

/// Enum representing HTTP 3xx redirection responses
public enum RedirectionResponse: Int {
    /// 300 Multiple Choices - Indicates multiple options for the resource that the client may follow.
    case multipleChoices = 300

    /// 301 Moved Permanently - This and all future requests should be directed to the given URI.
    case movedPermanently = 301

    /// 302 Found - Tells the client to look at another URL.
    case found = 302

    /// 303 See Other - The response can be found under a different URI and should be retrieved using a GET method.
    case seeOther = 303

    /// 304 Not Modified - Indicates the resource has not been modified since the last request.
    case notModified = 304

    /// 305 Use Proxy - Deprecated response code; was used to indicate a resource must be accessed through a proxy.
    case useProxy = 305

    /// 306 Switch Proxy - No longer used.
    case switchProxy = 306

    /// 307 Temporary Redirect - Instructs the client to repeat the request with another URI using the same method.
    case temporaryRedirect = 307

    /// 308 Permanent Redirect - The request and all future requests should be repeated using another URI.
    case permanentRedirect = 308
}

extension RedirectionResponse {
    public var description: String {
        switch self {
        case .multipleChoices: return "Multiple Choices"
        case .movedPermanently: return "Moved Permanently"
        case .found: return "Found"
        case .seeOther: return "See Other"
        case .notModified: return "Not Modified"
        case .useProxy: return "Use Proxy"
        case .switchProxy: return "Switch Proxy"
        case .temporaryRedirect: return "Temporary Redirect"
        case .permanentRedirect: return "Permanent Redirect"
        }
    }
}

extension RedirectionResponse: HTTPStatusRepresentable {
    public var code: Int {
        return rawValue
    }

    public var category: ResponseStatusCode {
        return .successful
    }
}
