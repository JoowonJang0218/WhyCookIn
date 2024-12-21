//
//  CommunityViewModel.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import Foundation

class CommunityViewModel {
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        let posts = DatabaseManager.shared.fetchPosts()
        completion(posts)
    }

    func addPost(title: String, content: String, category: String, author: User) {
        let post = Post(id: UUID(), author: author, title: title, content: content, category: category, timestamp: Date())
        DatabaseManager.shared.savePost(post)
    }

    func empathizePost(_ post: Post, by user: User) {
        DatabaseManager.shared.empathizePost(post, by: user)
    }
}
