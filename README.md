# SwiftyNetwork

SwiftyNetwork is a lightweight Swift networking library that makes it easy to perform HTTP requests, handle authentication, parse JSON, and upload files. It provides a unified response type with clear success, failure, and no-content cases, making error handling more predictable.

## Features

- 🔹 Simple async/await API for clean networking code  
- 🔹 Automatic JSON encoding/decoding with `Codable`  
- 🔹 Unified response handling via `BackendResponse<T>`  
- 🔹 Support for authentication tokens (e.g. Bearer)  
- 🔹 Multipart uploads for files and images  
- 🔹 Extensible status handling via `HTTPStatusRepresentable`

## Installation

Add **SwiftyNetwork** as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/SwiftyNetwork.git", from: "1.0.0")
]
```
Then import it where needed:
```swift
import SwiftyNetwork
```

## Usage

### Perform a JSON Request

```swift
struct User: Decodable {
    let id: Int
    let name: String
}

let network = SwiftyNetwork(token: "your-auth-token")

let response: BackendResponse<User> = await network.request(
    url: "https://api.example.com/user/1",
    requestType: .get,
    withToken: true
)

switch response {
case .success(let user, let status):
    print("User loaded: \(user.name), status: \(status.code)")
case .noContent(let status):
    print("No content, status: \(status.code)")
case .failure(let status, _):
    print("Request failed with status: \(status.code)")
}
```

### Perform a Request Without Response

```swift
let response: BackendResponse<Void> = await network.request(
    url: "https://api.example.com/user/1",
    requestType: .delete,
    withToken: true
)
```

### Perform a Multipart Upload
```swift
let data = Data(...) // e.g. image data

let response: BackendResponse<Void> = await network.requestMultipart(
    urlString: "https://api.example.com/upload",
    contentType: "image/jpeg",
    paramName: "file",
    fileName: "avatar.jpg",
    dataToUpload: data,
    requestType: .post,
    withToken: true
)
```

## Response Handling
All requests return a 
```swift
BackendResponse<T>:
.success(T, status) → Decoded response body
.noContent(status) → Empty response (e.g. HTTP 204)
.failure(status, body) → Failed request with optional body
```
