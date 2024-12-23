//
//  SwiftV2Api.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/22/24.
//

import Foundation

class SwiftV2Api {
    let apiClient: SwiftApiClient

    init(apiClient: SwiftApiClient) {
        self.apiClient = apiClient
    }

    /// A. 위치정보 조회
    /// - parameter request: The Swift version of GetLocationRequest
    /// - returns: SwiftApiResponse<GetLocationResponse> if success
    /// - throws: SdkError or ApiError
    func geoLocationGet(
        _ request: GetLocationRequest
    ) throws -> SwiftApiResponse<GetLocationResponse> {
        // Build query params from the request
        var queryParams = [String: Any]()
        queryParams["ip"] = request.ip
        if let enc = request.enc { queryParams["enc"] = enc }
        if let ext = request.ext { queryParams["ext"] = ext }
        if let respFormat = request.responseFormatType { queryParams["responseFormatType"] = respFormat }

        // Build SwiftApiRequest
        let apiReq = try SwiftApiRequest<Any>(
            method: "GET",
            path: "/geoLocation",
            queryParams: queryParams,
            // formParams, etc. can remain empty
            formParams: [:],
            httpHeaders: [:],
            body: nil,
            isCustomFormParams: false,
            isRequiredApiKey: true,     // or false, depending on your usage
            domain: "https://ncloud.apigw.ntruss.com",
            basePath: "/geolocation/v2"
        )

        // Now call the client
        let response = try apiClient.call(apiReq, returnType: GetLocationResponse.self)
        return response
    }

    /// Another overload that returns just `GetLocationResponse` for convenience:
    func geoLocationGetResult(
        _ request: GetLocationRequest
    ) throws -> GetLocationResponse {
        let apiResponse = try geoLocationGet(request)
        guard let body = apiResponse.body else {
            throw SdkError("No response body.")
        }
        return body
    }
}

