//
//  ApiError.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/22/24.
//

import Foundation

/// Represents an error from the server, containing HTTP status, headers, and possibly a response body.
struct ApiError: Error {
    let message: String
    let statusCode: Int
    let headers: [String: [String]]?
    let bodyData: Data?

    init(
        message: String,
        statusCode: Int,
        headers: [String: [String]]? = nil,
        bodyData: Data? = nil
    ) {
        self.message = message
        self.statusCode = statusCode
        self.headers = headers
        self.bodyData = bodyData
    }
}

