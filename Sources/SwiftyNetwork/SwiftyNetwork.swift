//
//  SwiftyNetwork.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 21/09/2025.
//

import Foundation

/// Entry point for performing backend calls.
public class SwiftyNetwork {

    // MARK: - URLSession
    /// Ephemeral session (no persistent storage)
    public let session: URLSession = URLSession(configuration: .ephemeral)
    
    // MARK: - Variables injected from app
    internal weak var delegate: SwiftyDelegate?
    internal var token: String?
    
    // MARK: - Lifecycle
    /// Initializes the backend handler.
    /// - Parameters:
    ///   - delegate: Optional delegate for logging and event handling.
    ///   - token: Optional initial authentication token.
    public init(delegate: SwiftyDelegate? = DefaultSwiftyDelegate(),
                token: String? = nil) {
        self.delegate = delegate
        self.token = token
    }
    
    // MARK: - Token management
    /// Updates the token used for authenticated requests.
    /// - Parameter token: New token value or nil to clear.
    public func updateToken(_ token: String?) {
        self.token = token
    }
    
    // MARK: - Request generation
    /// Generates a URLRequest with optional token and encoded body.
    internal func generateRequestFrom(url: String,
                                      requestType: HttpType,
                                      body: Encodable?,
                                      withToken: Bool) -> URLRequest? {
        guard let url = URL(string: url) else {
            delegate?.addLogString("Invalid URL: \(url)")
            return nil
        }
        
        var request = requestForUrl(url, httpMethod: requestType.rawValue)
        
        if withToken {
            guard let token = token, !token.isEmpty else {
                delegate?.addLogString("Missing token for URL=\(url). Request blocked.")
                return nil
            }
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                delegate?.addLogString("Failed to encode body for URL=\(url): \(error)")
            }
        }
        
        return request
    }
    
    /// Generates a base URLRequest with default headers.
    private func requestForUrl(_ url: URL, httpMethod: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}

// MARK: - SwiftyNetwork Extension: Requests
extension SwiftyNetwork {
    
    // MARK: Generic JSON request (Decodable)
    /// Makes a backend request and decodes the response into a Decodable type.
    /// Returns `.success(T)` if decoding succeeds, `.noContent` for empty responses,
    /// and `.failure` for errors.
    public func request<T: Decodable>(url: String,
                                      body: Encodable? = nil,
                                      requestType: HttpType,
                                      withToken: Bool) async -> BackendResponse<T> {
        guard let request = generateRequestFrom(url: url,
                                                requestType: requestType,
                                                body: body,
                                                withToken: withToken) else {
            return .failure(status: UnknownResponse(code: -1), body: nil)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            return handleDataResponse(type: T.self, data: data, statusCode: statusCode, url: url)
        } catch {
            delegate?.addLogString("Backend call error: \(error.localizedDescription)")
            return .failure(status: UnknownResponse(code: -1), body: nil)
        }
    }
    
    // MARK: Request for Void (no response body)
    /// Makes a backend request that does not expect a response body.
    public func request(url: String,
                        body: Encodable? = nil,
                        requestType: HttpType,
                        withToken: Bool) async -> BackendResponse<Void> {
        guard let request = generateRequestFrom(url: url,
                                                requestType: requestType,
                                                body: body,
                                                withToken: withToken) else {
            return .failure(status: UnknownResponse(code: -1), body: nil)
        }
        
        do {
            let (_, response) = try await session.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            let status = ResponseStatusCode.from(statusCode ?? -1)?
                .responseStatus(from: statusCode ?? -1)
                ?? UnknownResponse(code: statusCode ?? -1)
            return .noContent(status: status)
        } catch {
            delegate?.addLogString("Backend call error: \(error.localizedDescription)")
            return .failure(status: UnknownResponse(code: -1), body: nil)
        }
    }
    
    // MARK: Multipart upload (generic)
    /// Performs a multipart upload (file/image) and optionally decodes JSON response.
    /// Use `T = Void` if no response body is expected.
    public func requestMultipart<T: Decodable>(urlString: String,
                                               contentType: String,
                                               paramName: String,
                                               fileName: String,
                                               dataToUpload: Data,
                                               requestType: HttpType,
                                               withToken: Bool) async -> BackendResponse<T> {
        guard let url = URL(string: urlString) else {
            return .failure(status: UnknownResponse(code: -1), body: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = requestType.rawValue
        if withToken, let token = token, !token.isEmpty {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let bodyData = makeMultipartData(boundary: boundary,
                                         paramName: paramName,
                                         fileName: fileName,
                                         contentType: contentType,
                                         data: dataToUpload)

        do {
            let (data, response) = try await URLSession.shared.upload(for: request, from: bodyData)
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            let status = ResponseStatusCode.from(statusCode ?? -1)?
                .responseStatus(from: statusCode ?? -1)
                ?? UnknownResponse(code: statusCode ?? -1)

            // If T is Void, return noContent; otherwise decode JSON
            if T.self == Void.self {
                return BackendResponse<T>.noContent(status: status)
            } else {
                return handleDataResponse(type: T.self, data: data, statusCode: statusCode, url: urlString)
            }

        } catch {
            delegate?.addLogString("Multipart upload error: \(error.localizedDescription)")
            return .failure(status: UnknownResponse(code: -1), body: nil)
        }
    }
    
    // MARK: - Response Handling
    /// Centralized decoding and status handling for requests
    internal func handleDataResponse<T: Decodable>(type: T.Type,
                                                   data: Data,
                                                   statusCode: Int?,
                                                   url: String) -> BackendResponse<T> {
        guard let statusCode else {
            return .failure(status: UnknownResponse(code: -1), body: nil)
        }
        
        let status = ResponseStatusCode.from(statusCode)?
            .responseStatus(from: statusCode)
            ?? UnknownResponse(code: statusCode)
        
        switch status.category {
        case .successful:
            if data.isEmpty {
                return .noContent(status: status)
            }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return .success(decoded, status: status)
            } catch {
                delegate?.addLogString("Decoding error for \(T.self): \(error)")
                return .failure(status: status, body: data)
            }
        default:
            delegate?.addLogString("Backend call error: URL=\(url), Status=\(status.code) \(status.description)")
            return .failure(status: status, body: data)
        }
    }
    
    // MARK: - Multipart Builder
    /// Constructs multipart/form-data body
    private func makeMultipartData(boundary: String,
                                   paramName: String,
                                   fileName: String,
                                   contentType: String,
                                   data: Data) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
