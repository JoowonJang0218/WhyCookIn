//
//  Post.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import Foundation

struct Post {
    let id: UUID
    let author: User
    let title: String
    let content: String
    let category: String
    let timestamp: Date
}
