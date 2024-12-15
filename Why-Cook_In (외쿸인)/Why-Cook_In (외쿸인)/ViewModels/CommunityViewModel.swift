//
//  CommunityViewModel.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import Foundation

class CommunityViewModel {
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        var posts = DatabaseManager.shared.fetchPosts()
        // Insert AI bot post
        if posts.count > 0 {
            let lm = LanguageManager.shared
            let jokes = [lm.string(forKey: "ai_joke_1"), lm.string(forKey: "ai_joke_2")]
            let joke = jokes.randomElement() ?? lm.string(forKey: "ai_joke_1")
            let botUser = User(id: UUID(), name: "AI Bot", email: "bot@why-cook-in.com", userID: "aibot")
            let botPost = Post(id: UUID(), author: botUser, title: "AI Bot", content: joke, category: "category_general", timestamp: Date())
            posts.insert(botPost, at: 0)
        }
        completion(posts)
    }

    func addPost(title: String, content: String, category: String, author: User) {
        let post = Post(id: UUID(), author: author, title: title, content: content, category: category, timestamp: Date())
        DatabaseManager.shared.savePost(post)
    }
}

