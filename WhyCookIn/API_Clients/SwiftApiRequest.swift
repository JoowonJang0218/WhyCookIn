//
//  SwiftApiRequest.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/22/24.
//

import Foundation

/// The Swift counterpart of `ApiRequest<T>`
/// T is your request body type, often Data or maybe your custom struct
struct SwiftApiRequest<T> {
    let method: SwiftMethod
    let domain: String         // e.g. "https://ncloud.apigw.ntruss.com"
    let basePath: String       // e.g. "/geolocation/v2"
    let path: String           // e.g. "/geoLocation"
    var queryParams: [String: Any] = [:]
    var formParams: [String: Any] = [:]
    var httpHeaders: [String: String] = [:]
    var body: T?               // if you're sending JSON or something
    var isCustomFormParams: Bool = false
    var isRequiredApiKey: Bool = false

    /// If you want a convenience initializer to mimic the Java approach:
    init(
        method: String,
        path: String,
        queryParams: [String: Any] = [:],
        formParams: [String: Any] = [:],
        httpHeaders: [String: String] = [:],
        body: T? = nil,
        isCustomFormParams: Bool = false,
        isRequiredApiKey: Bool = false,
        domain: String = "https://ncloud.apigw.ntruss.com",
        basePath: String = "/geolocation/v2"
    ) throws {
        self.method = try SwiftMethod.from(method)
        self.domain = domain
        self.basePath = basePath
        self.path = path
        self.queryParams = queryParams
        self.formParams = formParams
        self.httpHeaders = httpHeaders
        self.body = body
        self.isCustomFormParams = isCustomFormParams
        self.isRequiredApiKey = isRequiredApiKey
    }
}

