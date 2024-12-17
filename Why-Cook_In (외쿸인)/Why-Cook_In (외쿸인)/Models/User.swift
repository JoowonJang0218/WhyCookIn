//
//  User.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import Foundation

struct User {
    let userID: UUID
    let firstName: String
    let lastName: String
    let email: String
    // password is usually not stored directly in a struct, just in the database for verification
    // isVisible could be used if needed in the UI:
    let isVisible: Bool
}
