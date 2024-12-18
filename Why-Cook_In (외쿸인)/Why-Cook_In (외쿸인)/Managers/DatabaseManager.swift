//
//  DatabaseManager.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import Foundation
import UIKit
import CoreData

class DatabaseManager {
    static let shared = DatabaseManager()
    private init() {}
    
    // MARK: - User Methods
    func addUser(email: String, password: String, firstName: String, lastName: String, userID: UUID) -> Bool {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        
        if (try? context.fetch(request).first) != nil {
            return false // user already exists
        }
        
        let newUser = UserEntity(context: context)
        newUser.email = email
        newUser.password = password
        newUser.first_name = firstName
        newUser.last_name = lastName
        newUser.userID = userID
        
        CoreDataManager.shared.saveContext()
        return true
    }
    
    func verifyUser(email: String, password: String) -> Bool {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)
        
        return (try? context.fetch(request).first) != nil
    }
    
    func fetchUser(email: String) -> User? {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        
        if let userEntity = try? context.fetch(request).first {
            return User(
                userID: userEntity.userID ?? UUID(),
                firstName: userEntity.first_name ?? "",
                lastName: userEntity.last_name ?? "",
                email: userEntity.email ?? "",
                isVisible: userEntity.isVisible == true
            )
        }
        return nil
    }
    
    func getCurrentUser() -> User? {
        guard let currentUserEmail = AuthenticationService.shared.getCurrentUser()?.email else { return nil }
        return fetchUser(email: currentUserEmail)
    }
    
    // MARK: - Profile Methods
    func updateUserProfile(user: User,
                           nationality: String,
                           birthday: Date,    // replace age: Int with birthday: Date
                           sex: String,
                           ethnicity: String,
                           homeCountry: String,
                           childhoodCountry: String,
                           photo: UIImage?) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", user.email)
        
        if let userEntity = try? context.fetch(request).first {
            let profile: ProfileEntity
            if let existingProfile = userEntity.profile {
                profile = existingProfile
            } else {
                profile = ProfileEntity(context: context)
                userEntity.profile = profile
            }
            
            profile.nationality = nationality
            profile.birthday = birthday   // set the birthday date
            profile.sex = sex
            profile.ethnicity = ethnicity
            profile.homeCountry = homeCountry
            profile.childhoodCountry = childhoodCountry
            if let img = photo, let imageData = img.jpegData(compressionQuality: 0.9) {
                profile.photo = imageData
            }
            
            CoreDataManager.shared.saveContext()
        }
    }
    
    func calculateAge(from birthday: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        return ageComponents.year ?? 0
    }
    
    
    
    func getUserProfile(user: User) -> UserProfile? {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", user.email)
        
        if let userEntity = try? context.fetch(request).first {
            // Convert UserEntity and associated ProfileEntity to UserProfile
            guard let profileEntity = userEntity.profile else { return nil }
            
            let image: UIImage?
            if let data = profileEntity.photo {
                image = UIImage(data: data)
            } else {
                image = nil
            }
            
            let userProfile = UserProfile(
                nationality: profileEntity.nationality ?? "",
                birthday: profileEntity.birthday ?? Date(), // Ensure birthday is saved in ProfileEntity
                sex: profileEntity.sex ?? "",
                ethnicity: profileEntity.ethnicity ?? "",
                homeCountry: profileEntity.homeCountry ?? "",
                childhoodCountry: profileEntity.childhoodCountry ?? "",
                photo: image,
                isVisible: userEntity.isVisible
            )
            
            return userProfile
        }
        return nil
    }
    
    // MARK: - Post Methods
    func savePost(_ post: Post) {
        let context = CoreDataManager.shared.context
        
        let userRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        userRequest.predicate = NSPredicate(format: "email == %@", post.author.email)
        // Wait, `post` doesn't have email attribute. We must get `post.author.email`.
        userRequest.predicate = NSPredicate(format: "email == %@", post.author.email)
        
        guard let userEntity = try? context.fetch(userRequest).first else { return }
        
        let postEntity = PostEntity(context: context)
        postEntity.id = post.id
        postEntity.title = post.title
        postEntity.content = post.content
        postEntity.category = post.category
        postEntity.timestamp = post.timestamp
        postEntity.author = userEntity
        
        CoreDataManager.shared.saveContext()
    }
    func fetchPosts() -> [Post] {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sort]
        
        guard let postEntities = try? context.fetch(request) else {
            return [] // Return empty array if fetch fails
        }
        
        return postEntities.compactMap { (p: PostEntity) -> Post? in
            // If author is missing, return nil to skip this post
            guard let authorEntity = p.author else {
                return nil
            }
            
            let author = User(
                userID: authorEntity.userID ?? UUID(),
                firstName: authorEntity.first_name ?? "",
                lastName: authorEntity.last_name ?? "",
                email: authorEntity.email ?? "",
                isVisible: authorEntity.isVisible
            )
            
            // Construct a Post object using the entity's attributes,
            // providing default values for optionals
            return Post(
                id: p.id ?? UUID(),
                author: author,
                title: p.title ?? "",
                content: p.content ?? "",
                category: p.category ?? "",
                timestamp: p.timestamp ?? Date()
            )
        }
    }
    
    
    
    // MARK: - Comments
    func addComment(to post: Post, author: User, content: String) {
        let context = CoreDataManager.shared.context
        
        let postRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        postRequest.predicate = NSPredicate(format: "id == %@", post.id as CVarArg)
        guard let postEntity = try? context.fetch(postRequest).first else { return }
        
        let userRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        userRequest.predicate = NSPredicate(format: "email == %@", author.email)
        guard let userEntity = try? context.fetch(userRequest).first else { return }
        
        let commentEntity = CommentEntity(context: context)
        commentEntity.id = UUID()
        commentEntity.content = content
        commentEntity.timestamp = Date()
        commentEntity.author = userEntity
        commentEntity.post = postEntity
        
        CoreDataManager.shared.saveContext()
    }
    
    func fetchComments(for post: Post) -> [Comment] {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<CommentEntity> = CommentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "post.id == %@", post.id as CVarArg)
        
        let sort = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [sort]
        
        guard let commentEntities = try? context.fetch(request) else { return [] }
        
        return commentEntities.compactMap { (c: CommentEntity) -> Comment? in
            guard let authorEntity = c.author else {
                return nil // Allowed since closure returns Comment?
            }
            
            let author = User(
                userID: authorEntity.userID ?? UUID(),
                firstName: authorEntity.first_name ?? "",
                lastName: authorEntity.last_name ?? "",
                email: authorEntity.email ?? "",
                isVisible: authorEntity.isVisible
            )
            
            return Comment(
                id: c.id ?? UUID(),
                author: author,
                content: c.content ?? "",
                timestamp: c.timestamp ?? Date()
            )
        }
    }
    
    
    // MARK: - Reactions (I feel this shit)
    private var reactionsForPost: [UUID: Int] = [:] // For now, still in-memory. You could add a reactions attribute to PostEntity.
    
    func empathizePost(_ post: Post, by user: User) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", post.id as CVarArg)
        
        if let postEntity = try? context.fetch(request).first {
            postEntity.reactionsCount += 1
            CoreDataManager.shared.saveContext()
        }
    }
    
    func getReactionsCount(for post: Post) -> Int {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", post.id as CVarArg)
        if let postEntity = try? context.fetch(request).first {
            return Int(postEntity.reactionsCount)
        }
        return 0
    }
    
    func isUserVisible(user: User) -> Bool {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", user.email)
        
        if let userEntity = try? context.fetch(request).first {
            return userEntity.isVisible
        }
        return true // Default if user not found, or choose false if you prefer.
    }
    
    func setUserVisibility(user: User, visible: Bool) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", user.email)
        
        if let userEntity = try? context.fetch(request).first {
            userEntity.isVisible = visible
            CoreDataManager.shared.saveContext()
        }
    }
    
    func deleteUser(email: String) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        
        if let userEntity = try? context.fetch(request).first {
            context.delete(userEntity)
            CoreDataManager.shared.saveContext()
        }
    }
    func fetchAllUsers() -> [User] {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        guard let userEntities = try? context.fetch(request) else { return [] }
        
        return userEntities.map { ue in
            User(
                userID: ue.userID ?? UUID(),
                firstName: ue.first_name ?? "",
                lastName: ue.last_name ?? "",
                email: ue.email ?? "",
                isVisible: ue.isVisible
            )
        }
    }
    func updateUserVisibility(user: User, visible: Bool) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", user.email)
        
        if let userEntity = try? context.fetch(request).first {
            userEntity.isVisible = visible // Make sure isVisible is an attribute of UserEntity
            do {
                try context.save()
            } catch {
                print("Failed to save visibility: \(error)")
            }
        }
    }
}
