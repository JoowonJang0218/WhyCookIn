//
//  CommunityViewModel.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import Foundation

class CommunityViewModel {
    private let databaseManager = DatabaseManager.shared
    private var posts: [Post] = []
    
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        posts = databaseManager.fetchPosts()
        completion(posts)
    }
    
    func addPost(title: String, content: String, category: String, author: User) {
        let newPost = Post(id: UUID(),
                           author: author,
                           title: title,
                           content: content,
                           category: category,
                           timestamp: Date())
        databaseManager.savePost(newPost)
    }
}

