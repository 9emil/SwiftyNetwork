//
//  HttpType.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

/// Supported HTTP methods for backend requests.
public enum HttpType: String {
    /// The GET method requests a representation of the specified resource.
    case get = "GET"
    /// The POST method is used to submit an entity to the specified resource.
    case post = "POST"
    /// The PUT method replaces all current representations of the target resource with the request payload.
    case put = "PUT"
    /// The PATCH method is used to apply partial modifications to a resource.
    case patch = "PATCH"
    /// The DELETE method deletes the specified resource.
    case delete = "DELETE"
    /// The HEAD method asks for a response identical to a GET request, but without the response body.
    case head = "HEAD"
    /// The OPTIONS method describes the communication options for the target resource.
    case options = "OPTIONS"
}
