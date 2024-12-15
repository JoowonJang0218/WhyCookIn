//
//  DatabaseManager.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import Foundation
import UIKit

struct UserProfile {
    let nationality: String
    let age: Int
    let sex: String
    let ethnicity: String
    let homeCountry: String
    let childhoodCountry: String
    let photo: UIImage?
}

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var users = [String: (password: String, user: User)]()
    private var posts = [Post]()
    private var categories = [
        "category_general",
        "category_housing",
        "category_immigration",
        "category_jobs",
        "category_suggest_new",
        "category_sim_card",
        "category_bank_account"
    ]
    private var userProfiles: [String: UserProfile] = [:]
    
    // For comments, we’ll keep a dictionary keyed by post ID
    private var commentsForPost: [UUID: [Comment]] = [:]
    
    // For user visibility
    private var userVisibility: [String: Bool] = [:]
    
    private init() {}
    
    // MARK: - User-related methods
    func addUser(email: String, password: String, name: String, userID: String) -> Bool {
        guard users[email] == nil else { return false }
        let newUser = User(id: UUID(), name: name, email: email, userID: userID)
        users[email] = (password, newUser)
        return true
    }
    
    func verifyUser(email: String, password: String) -> Bool {
        guard let stored = users[email] else { return false }
        return stored.password == password
    }
    
    func fetchUser(email: String) -> User? {
        return users[email]?.user
    }
    
    // MARK: - Profile methods
    func updateUserProfile(user: User,
                           nationality: String,
                           age: Int,
                           sex: String,
                           ethnicity: String,
                           homeCountry: String,
                           childhoodCountry: String,
                           photo: UIImage?) {
        userProfiles[user.email] = UserProfile(
            nationality: nationality,
            age: age,
            sex: sex,
            ethnicity: ethnicity,
            homeCountry: homeCountry,
            childhoodCountry: childhoodCountry,
            photo: photo
        )
    }
    
    func getUserProfile(user: User) -> UserProfile? {
        return userProfiles[user.email]
    }
    
    func updateUserProfilePhoto(user: User, photo: UIImage) {
        guard var existingProfile = userProfiles[user.email] else {
            // If no profile exists yet, create one with defaults
            let newProfile = UserProfile(
                nationality: "",
                age: 0,
                sex: "",
                ethnicity: "",
                homeCountry: "",
                childhoodCountry: "",
                photo: photo
            )
            userProfiles[user.email] = newProfile
            return
        }
        
        existingProfile = UserProfile(
            nationality: existingProfile.nationality,
            age: existingProfile.age,
            sex: existingProfile.sex,
            ethnicity: existingProfile.ethnicity,
            homeCountry: existingProfile.homeCountry,
            childhoodCountry: existingProfile.childhoodCountry,
            photo: photo
        )
        
        userProfiles[user.email] = existingProfile
    }
    
    // MARK: - Visibility methods
    func setUserVisibility(user: User, visible: Bool) {
        userVisibility[user.email] = visible
    }
    
    func isUserVisible(user: User) -> Bool {
        return userVisibility[user.email] ?? true // default to true
    }
    
    // MARK: - Post-related methods
    func savePost(_ post: Post) {
        posts.append(post)
    }
    
    func fetchPosts() -> [Post] {
        return posts.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    // Categories
    func fetchCategories() -> [String] {
        return categories
    }
    
    func addCategory(_ category: String) {
        if !categories.contains(category) && !category.isEmpty {
            categories.append(category)
        }
    }
    
    // MARK: - Comment methods
    func addComment(to post: Post, author: User, content: String) {
        let newComment = Comment(id: UUID(), author: author, content: content, timestamp: Date())
        if commentsForPost[post.id] != nil {
            commentsForPost[post.id]?.append(newComment)
        } else {
            commentsForPost[post.id] = [newComment]
        }
    }
    
    func fetchComments(for post: Post) -> [Comment] {
        return commentsForPost[post.id]?.sorted(by: { $0.timestamp < $1.timestamp }) ?? []
    }
}
