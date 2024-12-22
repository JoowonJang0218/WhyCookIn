//
//  SwiftApiResponse.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/22/24.
//

import Foundation

/// Represents a successful response from your SwiftApiClient.
struct SwiftApiResponse<T> {
    let statusCode: Int
    let headers: [String: [String]]?
    let body: T?
}

