//
//  Comment.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/13/24.
//

import Foundation

struct Comment {
    let id: UUID
    let author: User
    let content: String
    let timestamp: Date
}
