//
//  SwiftMethod.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/22/24.
//

import Foundation

enum SwiftMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
    case OPTIONS
    case HEAD

    static func from(_ name: String) throws -> SwiftMethod {
        if let method = SwiftMethod(rawValue: name.uppercased()) {
            return method
        } else {
            throw SdkError("This method is not supported: \(name)")
        }
    }
}

