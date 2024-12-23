//
//  SdkError.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/22/24.
//

import Foundation

/// Errors that occur before making an actual HTTP call
/// (e.g. invalid arguments, missing credentials, unsupported methods).
struct SdkError: Error {
    let message: String
    let underlyingError: Error?

    init(_ message: String, underlyingError: Error? = nil) {
        self.message = message
        self.underlyingError = underlyingError
    }
}

