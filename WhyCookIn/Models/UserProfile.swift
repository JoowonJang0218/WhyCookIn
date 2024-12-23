//
//  UserProfile.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/16/24.
//

import Foundation
import UIKit

struct UserProfile {
    let userID: UUID
    let email: String
    let firstName: String
    let lastName: String
    let nationality: String
    let birthday: Date
    let sex: String
    let ethnicity: String
    let homeCountry: String
    let childhoodCountry: String
    let photo: UIImage?
    let isVisible: Bool
    let multipleNationalities: [String]
    let multipleEthnicities: [String]
}
