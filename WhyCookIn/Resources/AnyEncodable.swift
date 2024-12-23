//
//  AnyEncodable.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/22/24.
//

import Foundation

/// A type-erased `Encodable` wrapper.
/// This allows us to encode any `Encodable` value
/// even if we only know it's 'Encodable' at runtime.
struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        _encode = { encoder in
            try wrapped.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

