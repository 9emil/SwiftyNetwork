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
    internal let baseURL: URL?

    // MARK: - Init
    // MARK: - Init (without baseURL)
    /// Creates a new `SwiftyNetwork` instance without a predefined base URL.
    ///
    /// - Parameters:
    ///   - delegate: Optional delegate for logging and handling authentication events.
    ///               Defaults to `DefaultSwiftyDelegate()`.
    ///   - token: Optional initial authentication token (e.g. a bearer token).
    ///            Can be updated later using `updateToken(_:)`.
    ///
    /// - Note: Use this initializer if your requests will always specify a full URL.
    ///         If your backend has a common root, prefer the `init(baseURL:delegate:token:)` initializer.
    public init(delegate: SwiftyDelegate? = DefaultSwiftyDelegate(),
                token: String? = nil) {
        self.delegate = delegate
        self.token = token
        self.baseURL = nil
    }

    /// Creates a new `SwiftyNetwork` instance bound to a specific API base URL.
    ///
    /// - Parameters:
    ///   - baseURL: The root URL of your backend (e.g. `"https://api.example.com"`).
    ///              All requests will be made relative to this base.
    ///   - delegate: Optional delegate for logging and handling authentication events.
    ///               Defaults to `DefaultSwiftyDelegate()`.
    ///   - token: Optional initial authentication token (e.g. a bearer token).
    ///            Can be updated later with `updateToken(_:)`.
    ///
    /// - Note: This initializer will `fatalError` if the given `baseURL` string
    ///         cannot be converted into a valid `URL`.
    public init(baseURL: String,
                delegate: SwiftyDelegate? = DefaultSwiftyDelegate(),
                token: String? = nil) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid baseURL: \(baseURL)")
        }
        self.baseURL = url
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
                                      urlParameters: [URLQueryItem]? = nil,
                                      withToken: Bool = false) -> URLRequest? {
        guard var url = URL(string: url) else {
            delegate?.addLogString("Invalid URL: \(url)")
            return nil
        }
        if let urlParameters {
            if #available(iOS 16.0, *) {
                url = url.appending(queryItems: urlParameters)
            } else {
                url = url.appendingQueryItems(urlParameters)
            }
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
    /// Sends an HTTP request to a full URL and attempts to decode the JSON response into
    /// the given `Decodable` type.
    ///
    /// - Parameters:
    ///   - url: The absolute URL string to request.
    ///   - body: Optional `Encodable` request body (e.g., JSON payload). Defaults to `nil`.
    ///   - requestType: The HTTP method to use (e.g., `.get`, `.post`, `.delete`).
    ///   - withToken: Whether to include the authentication token in the request header.
    ///
    /// - Returns:
    ///   - `.success(T, status)` if the request succeeds and the response is decoded into type `T`.
    ///   - `.noContent(status)` if the server responds with an empty body (e.g., 204 No Content).
    ///   - `.failure(status, body)` if the request fails or decoding is unsuccessful.
    public func request<T: Decodable>(url: String,
                                      body: Encodable? = nil,
                                      requestType: HttpType,
                                      urlParameters: [URLQueryItem]? = nil,
                                      withToken: Bool = false) async -> BackendResponse<T> {
        guard let request = generateRequestFrom(url: url,
                                                requestType: requestType,
                                                body: body,
                                                urlParameters: urlParameters,
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

    /// Sends an HTTP request to an API endpoint relative to the `baseURL`.
    /// Falls back to `.failure` if `baseURL` is not configured.
    ///
    /// - Parameters:
    ///   - endpoint: The relative path of the API endpoint (e.g., `/users/me`).
    ///   - body: Optional `Encodable` request body (e.g., JSON payload). Defaults to `nil`.
    ///   - requestType: The HTTP method to use (e.g., `.get`, `.post`, `.delete`).
    ///   - withToken: Whether to include the authentication token in the request header.
    ///
    /// - Returns:
    ///   A `BackendResponse<T>` with the same semantics as `request(url:...)`:
    ///   - `.success(T, status)` if the request succeeds and decoding works.
    ///   - `.noContent(status)` if the response body is empty.
    ///   - `.failure(status, body)` if `baseURL` is missing, the request fails, or decoding fails.
    public func request<T: Decodable>(endpoint: String,
                                      body: Encodable? = nil,
                                      requestType: HttpType,
                                      urlParameters: [URLQueryItem]? = nil,
                                      withToken: Bool = false) async -> BackendResponse<T> {
        guard let baseURL else {
            delegate?.addLogString("Missing baseURL for endpoint: \(endpoint)")
            return .failure(status: UnknownResponse(rawValue: -1)!, body: nil)
        }
        return await request(url: baseURL.absoluteString + endpoint,
                             body: body,
                             requestType: requestType,
                             urlParameters: urlParameters,
                             withToken: withToken)
    }

    // MARK: - Request for Void (no response body)

    /// Sends an HTTP request to a full URL when no response body is expected.
    ///
    /// Useful for endpoints like `DELETE`, `POST` (with no response), or any call
    /// that only requires status-code validation.
    ///
    /// - Parameters:
    ///   - url: The absolute URL string to request.
    ///   - body: Optional `Encodable` request body (e.g., JSON payload). Defaults to `nil`.
    ///   - requestType: The HTTP method to use (e.g., `.post`, `.delete`).
    ///   - withToken: Whether to include the authentication token in the request header.
    ///
    /// - Returns:
    ///   - `.noContent(status)` if the request succeeds and no body is returned (e.g., 204).
    ///   - `.failure(status, body)` if the request fails.
    public func request(url: String,
                        body: Encodable? = nil,
                        requestType: HttpType,
                        urlParameters: [URLQueryItem]? = nil,
                        withToken: Bool = false) async -> BackendResponse<Void> {
        guard let request = generateRequestFrom(url: url,
                                                requestType: requestType,
                                                body: body,
                                                urlParameters: urlParameters,
                                                withToken: withToken) else {
            return .failure(status: UnknownResponse(code: -1), body: nil)
        }
        do {
            let (_, response) = try await session.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            let status = ResponseStatusCode.from(statusCode ?? -1)?
                .responseStatus(from: statusCode ?? -1)
                ?? UnknownResponse(code: statusCode ?? -1)
            if status.category == .successful {
                return .noContent(status: status)
            } else {
                return .failure(status: status, body: nil)
            }
        } catch {
            delegate?.addLogString("Backend call error: \(error.localizedDescription)")
            return .failure(status: UnknownResponse(code: -1), body: nil)
        }
    }

    /// Sends an HTTP request to a relative API endpoint (based on `baseURL`)
    /// when no response body is expected.
    ///
    /// Falls back to `.failure` if `baseURL` is not set.
    ///
    /// - Parameters:
    ///   - endpoint: The relative path of the API endpoint (e.g., `/logout`).
    ///   - body: Optional `Encodable` request body. Defaults to `nil`.
    ///   - requestType: The HTTP method to use (e.g., `.post`, `.delete`).
    ///   - withToken: Whether to include the authentication token in the request header.
    ///
    /// - Returns:
    ///   - `.noContent(status)` if the request succeeds and no body is returned.
    ///   - `.failure(status, body)` if `baseURL` is missing or the request fails.
    public func request(endpoint: String,
                        body: Encodable? = nil,
                        requestType: HttpType,
                        urlParameters: [URLQueryItem]? = nil,
                        withToken: Bool = false) async -> BackendResponse<Void> {
        guard let baseURL else {
            delegate?.addLogString("Missing baseURL for endpoint: \(endpoint)")
            return .failure(status: UnknownResponse(rawValue: -1)!, body: nil)
        }
        return await request(url: baseURL.absoluteString + endpoint,
                             body: body,
                             requestType: requestType,
                             urlParameters: urlParameters,
                             withToken: withToken)
    }

    // MARK: - Multipart upload (generic)

    /// Performs a multipart/form-data upload request (e.g., file, image, binary data),
    /// and optionally decodes the backend JSON response into a `Decodable` type.
    ///
    /// - Note:
    ///   If the endpoint does not return a response body, set `T = Void`.
    ///   In that case, `.noContent(status)` will be returned instead of decoding.
    ///
    /// - Parameters:
    ///   - urlString: The absolute URL string for the upload endpoint.
    ///   - contentType: MIME type of the file being uploaded (e.g., `"image/png"`).
    ///   - paramName: The form-data parameter name expected by the backend.
    ///   - fileName: The filename to associate with the uploaded data.
    ///   - dataToUpload: The raw `Data` to upload.
    ///   - requestType: The HTTP method (e.g., `.post`, `.put`).
    ///   - withToken: Whether to include the authentication token in the request header.
    ///
    /// - Returns:
    ///   - `.success(decoded, status)` if the upload succeeds and response is decoded.
    ///   - `.noContent(status)` if `T == Void` or the response body is empty.
    ///   - `.failure(status, body)` if upload fails or decoding fails.
    public func requestMultipart<T: Decodable>(urlString: String,
                                               contentType: String,
                                               paramName: String,
                                               fileName: String,
                                               dataToUpload: Data,
                                               requestType: HttpType,
                                               withToken: Bool = false) async -> BackendResponse<T> {
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

    /// Performs a multipart/form-data upload request to a relative API endpoint
    /// (resolved against the configured `baseURL`).
    ///
    /// Falls back to `.failure` if `baseURL` is missing.
    ///
    /// - Parameters:
    ///   - endpoint: Relative API endpoint (e.g., `"/upload/avatar"`).
    ///   - contentType: MIME type of the file being uploaded (e.g., `"image/jpeg"`).
    ///   - paramName: The form-data parameter name expected by the backend.
    ///   - fileName: The filename to associate with the uploaded data.
    ///   - dataToUpload: The raw `Data` to upload.
    ///   - requestType: The HTTP method (e.g., `.post`, `.put`).
    ///   - withToken: Whether to include the authentication token in the request header.
    ///
    /// - Returns:
    ///   - `.success(decoded, status)` if upload succeeds and response is decoded.
    ///   - `.noContent(status)` if `T == Void` or the response body is empty.
    ///   - `.failure(status, body)` if `baseURL` is missing, upload fails, or decoding fails.
    public func requestMultipart<T: Decodable>(endpoint: String,
                                               contentType: String,
                                               paramName: String,
                                               fileName: String,
                                               dataToUpload: Data,
                                               requestType: HttpType,
                                               withToken: Bool = false) async -> BackendResponse<T> {
        guard let baseURL else {
            delegate?.addLogString("Missing baseURL for endpoint: \(endpoint)")
            return .failure(status: UnknownResponse(rawValue: -1)!, body: nil)
        }
        return await requestMultipart(urlString: baseURL.absoluteString + endpoint,
                                      contentType: contentType,
                                      paramName: paramName,
                                      fileName: fileName,
                                      dataToUpload: dataToUpload,
                                      requestType: requestType,
                                      withToken: withToken)
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
            if data.isEmpty && status.category == .successful {
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
