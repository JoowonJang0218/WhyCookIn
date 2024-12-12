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
        "category_suggest_new"
    ]
    private var userProfiles: [String: UserProfile] = [:]
    
    private init() {}
    
    // User-related methods
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
    
    // Profile methods
    func updateUserProfile(user: User,
                           nationality: String,
                           age: Int,
                           sex: String,
                           ethnicity: String,
                           homeCountry: String,
                           childhoodCountry: String,
                           photo: UIImage?) {
        userProfiles[user.email] = UserProfile(nationality: nationality,
                                               age: age,
                                               sex: sex,
                                               ethnicity: ethnicity,
                                               homeCountry: homeCountry,
                                               childhoodCountry: childhoodCountry,
                                               photo: photo)
    }
    
    func getUserProfile(user: User) -> UserProfile? {
        return userProfiles[user.email]
    }
    
    // Post-related methods
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
}
