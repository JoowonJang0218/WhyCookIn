//
//  SwiftApiClient.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/22/24.
//

import Foundation

class SwiftApiClient {
    /// If you had credentials, you might store them here
    /// e.g. var apiKeyID: String, var apiKeySecret: String
    /// or an optional function to apply the credentials to a request.

    /// Logging or timeouts might also be stored here:
    var enableLogging: Bool = false

    init(enableLogging: Bool = false) {
        self.enableLogging = enableLogging
    }

    /// The main call function, equivalent to `call(...)` in Java
    /// - parameter request: The SwiftApiRequest describing your call
    /// - parameter returnType: A type to decode if it's JSON, or omit for raw data
    /// - throws: ApiError if the server fails, or SdkError if something else is wrong
    /// - returns: SwiftApiResponse<T>, where T might be e.g. a struct or `Data`
    func call<T: Decodable>(
        _ request: SwiftApiRequest<Any>,
        returnType: T.Type
    ) throws -> SwiftApiResponse<T> {
        // 1) Build the URL
        guard var urlComponents = URLComponents(string: request.domain + request.basePath + request.path) else {
            throw SdkError("Invalid domain/basePath/path combination.")
        }

        // attach queryParams
        var queryItems: [URLQueryItem] = []
        for (k, v) in request.queryParams {
            // If `v` is an array, you'd add multiple items. We'll keep it simple:
            queryItems.append(URLQueryItem(name: k, value: "\(v)"))
        }
        urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let finalURL = urlComponents.url else {
            throw SdkError("Failed to construct URL from components.")
        }

        // 2) Create a URLRequest
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue

        // merge headers
        for (k, v) in request.httpHeaders {
            urlRequest.addValue(v, forHTTPHeaderField: k)
        }

        // If you have a body of type `Any`, check if it's Data or Encodable, etc.:
        if let actualBody = request.body {
            // First, if it’s raw `Data` already:
            if let bodyData = actualBody as? Data {
                urlRequest.httpBody = bodyData
                // Optionally set a Content-Type
                // urlRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            }
            // Next, if it’s some type that conforms to Encodable:
            else if let encodableBody = actualBody as? Encodable {
                // Wrap in AnyEncodable so JSONEncoder can handle it
                let wrapped = AnyEncodable(encodableBody)
                do {
                    let bodyData = try JSONEncoder().encode(wrapped)
                    urlRequest.httpBody = bodyData
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    throw SdkError("Failed to JSON-encode the request body.", underlyingError: error)
                }
            }
            // Otherwise, we don't know how to handle it:
            else {
                throw SdkError("Cannot encode the body; it’s neither Data nor Encodable.")
            }
        }

        // 3) Perform a synchronous call for demonstration
        //    (In real iOS code, you'd do an async approach or use completion handlers.)
        let (data, urlResponse, error) = URLSession.shared.syncRequest(urlRequest: urlRequest)

        // If you want to do logging:
        if enableLogging {
            print("[SwiftApiClient] Request: \(urlRequest)")
            print("[SwiftApiClient] Error: \(String(describing: error))")
            print("[SwiftApiClient] Response: \(String(describing: urlResponse))")
        }

        if let err = error {
            // This is a "pre-server" error
            throw SdkError("Failed to execute API call", underlyingError: err)
        }

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw SdkError("No HTTP response")
        }

        let statusCode = httpResponse.statusCode
        // Build a "headers" dictionary
        var headersMap = [String: [String]]()
        for (k, v) in httpResponse.allHeaderFields {
            guard let key = k as? String else { continue }
            // Some header fields could be single or multiple values
            headersMap[key] = ["\(v)"]
        }

        // If failure:
        if statusCode < 200 || statusCode >= 300 {
            throw ApiError(
                message: "Server returned an error. Status code = \(statusCode)",
                statusCode: statusCode,
                headers: headersMap,
                bodyData: data
            )
        }

        // If success, parse `data` into the expected T
        let responseValue: T?
        if T.self == Data.self {
            // If T is Data, just cast:
            responseValue = data as? T
        } else {
            // decode as JSON
            guard let responseData = data else {
                throw SdkError("No data in body but T is not Data.")
            }
            do {
                responseValue = try JSONDecoder().decode(T.self, from: responseData)
            } catch {
                throw ApiError(
                    message: "Failed to decode JSON into \(T.self)",
                    statusCode: statusCode,
                    headers: headersMap,
                    bodyData: responseData
                )
            }
        }

        return SwiftApiResponse(statusCode: statusCode, headers: headersMap, body: responseValue)
    }
}

// A quick extension to do synchronous requests in a demo. Not recommended in real iOS code!
extension URLSession {
    func syncRequest(urlRequest: URLRequest) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)
        let task = self.dataTask(with: urlRequest) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return (data, response, error)
    }
}

