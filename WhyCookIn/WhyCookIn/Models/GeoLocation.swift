//
//  GeoLocation.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/22/24.
//
//  geolocation
//  <br/>https://ncloud.apigw.ntruss.com/geolocation/v2
//
//  OpenAPI spec version: 2018-07-04T02:49:01Z
//
//  NOTE: This class is auto generated by the swagger code generator program.
//  https://github.com/swagger-api/swagger-codegen.git
//  Do not edit the class manually.
//

import Foundation

/// GeoLocation
///
/// 국가코드, 행정동 코드, 도/광역시/주, 시/군/구, 동, 위도, 경도, 통신사 이름
struct GeoLocation: Codable {
    /// 국가코드
    let country: String?
    
    /// 행정동 코드
    let code: String?
    
    /// 도, 광역시, 주
    let r1: String?
    
    /// 시, 군, 구
    let r2: String?
    
    /// 동
    let r3: String?
    
    /// 위도
    let lat: String?
    
    /// 경도 (Java called it `_long`)
    let long: String?
    
    /// 통신사 이름
    let net: String?
}
