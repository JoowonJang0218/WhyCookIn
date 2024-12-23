//
//  RestaurantSearchViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/15/24.
//

import Foundation
import UIKit
import NMapsMap

class RestaurantSearchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Restaurants"
        view.backgroundColor = .systemBackground
        
        // Create the map view at full size:
        let mapView = NMFMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Optionally configure the map:
        mapView.mapType = .basic
        // e.g. camera position, etc.
        
        // Finally, add the mapView to the VC’s view
        view.addSubview(mapView)
    }
    
    func fetchLocation(for ip: String) {
        // 1) Create your timestamp in milliseconds
        _ = "\(Int(Date().timeIntervalSince1970 * 1000))"
        let apiClient = NCPAPIClient()
        
        // 2) Compute the signature if needed
        //    (If the endpoint requires X-NCP-APIGW-Signature-V2)
        //    e.g. HMAC-SHA256 of (method + " " + url + "\n" + timestamp + "\n" + accessKey), then Base64-encode
        
        // 3) Build the URL with query params
        let endpoint = "https://ncloud.apigw.ntruss.com/geolocation/v2/geoLocation"
        var components = URLComponents(string: endpoint)!
        components.queryItems = [
            URLQueryItem(name: "ip", value: ip),
            URLQueryItem(name: "responseFormatType", value: "json")
            // ... etc
        ]
        
        // 4) Build the URLRequest
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue(apiClient.clientID,     forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue(apiClient.clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        // request.setValue(signatureString, forHTTPHeaderField: "x-ncp-apigw-signature-v2")
        // or if using an API Key approach:
        // request.setValue("YOUR-API-KEY-ID", forHTTPHeaderField: "x-ncp-apigw-api-key-id")
        // request.setValue("YOUR-API-KEY-SECRET", forHTTPHeaderField: "x-ncp-apigw-api-key")
        
        // 5) Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(GetLocationResponse.self, from: data)
                print("GeoResponse: \(result)")
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }
    
}
