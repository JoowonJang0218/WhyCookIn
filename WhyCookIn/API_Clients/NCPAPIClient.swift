//
//  NCPAPIClient.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/22/24.
//

import Foundation

class NCPAPIClient {
    
    let clientID = "4gr3vrh2nb"
    // X-NCP-APIGW-API-KEY-ID
    let clientSecret = "nXUODHc7nH98s5iSdHnflIYvk3cLJNOEP5X3F7y8"
    // X-NCP-APIGW-API-KEY
    
    // Example: Reverse Geocoding
    // e.g. GET https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=126.97843,37.56668&orders=legalcode,admcode&output=json
    // docs: https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc
    func reverseGeocode(longitude: Double,
                        latitude: Double,
                        completion: @escaping (Result<Data, Error>) -> Void) {
        
        let baseURL = "https://naveropenapi.apigw.ntruss.com"
        let path = "/map-reversegeocode/v2/gc"
        
        // Use your own query parameter logic
        let coordsParam = "\(longitude),\(latitude)"
        
        var urlComponents = URLComponents(string: baseURL + path)!
        urlComponents.queryItems = [
            URLQueryItem(name: "coords", value: coordsParam),
            URLQueryItem(name: "orders", value: "legalcode,admcode"),
            URLQueryItem(name: "output", value: "json")
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "BadURL", code: -1, userInfo:nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add the required headers:
        request.addValue(clientID, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        
        // Perform request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Check for basic errors
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -2, userInfo:nil)))
                return
            }
            // Optionally check status code, parse JSON, etc.
            completion(.success(data))
        }
        task.resume()
    }
}

