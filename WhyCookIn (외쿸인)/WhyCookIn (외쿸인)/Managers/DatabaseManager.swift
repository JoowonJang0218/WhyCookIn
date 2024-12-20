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
                           firstName: String,
                           lastName: String,
                           nationality: String,
                           birthday: Date,
                           sex: String,
                           ethnicity: String,
                           homeCountry: String,
                           childhoodCountry: String,
                           photo: UIImage?,
                           multipleNationalities: [String],
                           multipleEthnicities: [String]) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", user.email)
        
        if let userEntity = try? context.fetch(request).first {
            userEntity.first_name = firstName
            userEntity.last_name = lastName
            
            let profile: ProfileEntity
            if let existingProfile = userEntity.profile {
                profile = existingProfile
            } else {
                profile = ProfileEntity(context: context)
                userEntity.profile = profile
            }
            
            profile.nationality = nationality
            profile.birthday = birthday
            profile.sex = sex
            profile.ethnicity = ethnicity
            profile.homeCountry = homeCountry
            profile.childhoodCountry = childhoodCountry
            if let img = photo, let imageData = img.jpegData(compressionQuality: 0.9) {
                profile.photo = imageData
            }
            
            // Store multiple arrays as comma-separated strings for simplicity
            profile.multipleNationalities = multipleNationalities.joined(separator: ",")
            profile.multipleEthnicities = multipleEthnicities.joined(separator: ",")
            
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
        
        guard let userEntity = try? context.fetch(request).first,
              let pe = userEntity.profile else {
            return nil
        }
        
        let image: UIImage? = pe.photo != nil ? UIImage(data: pe.photo!) : nil
        
        let multipleNationalities = pe.multipleNationalities?.split(separator: ",").map { String($0) } ?? []
        let multipleEthnicities = pe.multipleEthnicities?.split(separator: ",").map { String($0) } ?? []
        
        return UserProfile(
            userID: userEntity.userID ?? UUID(),
            email: userEntity.email ?? "",
            firstName: userEntity.first_name ?? "",
            lastName: userEntity.last_name ?? "",
            nationality: pe.nationality ?? "",
            birthday: pe.birthday ?? Date(),
            sex: pe.sex ?? "",
            ethnicity: pe.ethnicity ?? "",
            homeCountry: pe.homeCountry ?? "",
            childhoodCountry: pe.childhoodCountry ?? "",
            photo: image,
            isVisible: userEntity.isVisible,
            multipleNationalities: multipleNationalities,
            multipleEthnicities: multipleEthnicities
        )
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
    func fetchOtherUsersProfiles(excluding currentUser: User) -> [UserProfile] {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email != %@", currentUser.email)
        
        guard let userEntities = try? context.fetch(request) else { return [] }
        
        var profiles: [UserProfile] = []
        
        for ue in userEntities {
            guard let pe = ue.profile else { continue }
            let image: UIImage? = pe.photo != nil ? UIImage(data: pe.photo!) : nil
            let multipleNationalities = pe.multipleNationalities?.split(separator: ",").map { String($0) } ?? []
            let multipleEthnicities = pe.multipleEthnicities?.split(separator: ",").map { String($0) } ?? []
            
            // Make sure ue.email and ue.userID are not nil, or handle defaults if they are nil
            guard let email = ue.email, let userID = ue.userID else {
                continue // Can't form a valid UserProfile without these
            }
            
            let p = UserProfile(
                userID: userID,
                email: email,
                firstName: ue.first_name ?? "",
                lastName: ue.last_name ?? "",
                nationality: pe.nationality ?? "",
                birthday: pe.birthday ?? Date(),
                sex: pe.sex ?? "",
                ethnicity: pe.ethnicity ?? "",
                homeCountry: pe.homeCountry ?? "",
                childhoodCountry: pe.childhoodCountry ?? "",
                photo: image,
                isVisible: ue.isVisible,
                multipleNationalities: multipleNationalities,
                multipleEthnicities: multipleEthnicities
            )
            
            if p.isVisible {
                profiles.append(p)
            }
        }
        return profiles
    }
    
    // MARK: - Likes and Matches
    
    /// Records a 'like' from one user to another by creating a LikeEntity.
    /// If a LikeEntity already exists for this pair, it does nothing.
    func recordLike(from liker: User, to liked: User) {
        let context = CoreDataManager.shared.context
        
        // Check if this like already exists
        let request: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "likerUserID == %@ AND likedUserID == %@", liker.userID as CVarArg, liked.userID as CVarArg)
        
        if let existing = try? context.fetch(request), !existing.isEmpty {
            // Already exists, do nothing
            return
        }
        
        let newLike = LikeEntity(context: context)
        newLike.likerUserID = liker.userID
        newLike.likedUserID = liked.userID
        
        CoreDataManager.shared.saveContext()
    }
    
    /// Creates a chat thread if a mutual match is detected between two users.
    /// Returns the newly created ChatThreadEntity if created, or nil if no match or thread already exists.
    func createChatThreadIfMutualMatch(between userA: User, and userB: User) -> ChatThreadEntity? {
        guard isMutualMatch(between: userA, and: userB) else {
            return nil
        }
        
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<ChatThreadEntity> = ChatThreadEntity.fetchRequest()
        request.predicate = NSPredicate(format: "(userAID == %@ AND userBID == %@) OR (userAID == %@ AND userBID == %@)",
                                        userA.userID as CVarArg,
                                        userB.userID as CVarArg,
                                        userB.userID as CVarArg,
                                        userA.userID as CVarArg)
        
        if let existingThreads = try? context.fetch(request), let thread = existingThreads.first {
            print("createChatThreadIfMutualMatch: Existing thread found \(thread.id?.uuidString ?? "No ID")")
            return thread
        }
        
        let newThread = ChatThreadEntity(context: context)
        newThread.id = UUID()
        newThread.userAID = userA.userID
        newThread.userBID = userB.userID
        
        print("createChatThreadIfMutualMatch: Creating a new thread with userAID=\(userA.userID), userBID=\(userB.userID)")
        do {
            try context.save()
            print("createChatThreadIfMutualMatch: Successfully saved new thread \(newThread.id?.uuidString ?? "No ID")")
        } catch {
            print("Failed to create chat thread: \(error)")
        }
        
        return newThread
    }

    
    
    // MARK: - High Level Operation: User 'Match' Action
    /// Records a reaction (like or pass) from one user to another.
    /// If isLike = true, it's a like; if false, it's a pass.
    func recordReaction(from liker: User, to liked: User, isLike: Bool) {
        let context = CoreDataManager.shared.context
        
        let request: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "likerUserID == %@ AND likedUserID == %@", liker.userID as CVarArg, liked.userID as CVarArg)
        
        if let existing = try? context.fetch(request), let first = existing.first {
            // If already exists, update isLike if needed
            first.isLike = isLike
        } else {
            // Create a new reaction
            let newReaction = LikeEntity(context: context)
            newReaction.likerUserID = liker.userID
            newReaction.likedUserID = liked.userID
            newReaction.isLike = isLike
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save reaction: \(error)")
        }
    }
    
    
    func recordPass(from passer: User, to passed: User) {
        recordReaction(from: passer, to: passed, isLike: false)
    }
    
    /// Checks if two users mutually liked each other.
    func isMutualMatch(between userA: User, and userB: User) -> Bool {
        let context = CoreDataManager.shared.context
        
        let requestA: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
        requestA.predicate = NSPredicate(format: "likerUserID == %@ AND likedUserID == %@ AND isLike == true", userA.userID as CVarArg, userB.userID as CVarArg)
        let aLikesB = (try? context.fetch(requestA).first) != nil
        
        let requestB: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
        requestB.predicate = NSPredicate(format: "likerUserID == %@ AND likedUserID == %@ AND isLike == true", userB.userID as CVarArg, userA.userID as CVarArg)
        let bLikesA = (try? context.fetch(requestB).first) != nil
        
        return aLikesB && bLikesA
    }
    
    /// Fetch other user profiles excluding those the currentUser has already reacted to.
    func fetchNewUsersForSwipe(excluding currentUser: User) -> [UserProfile] {
        let context = CoreDataManager.shared.context
        
        // Fetch all reactions by currentUser
        let reactionsRequest: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
        reactionsRequest.predicate = NSPredicate(format: "likerUserID == %@", currentUser.userID as CVarArg)
        let reactedUserIDs: [UUID] = (try? context.fetch(reactionsRequest))?.compactMap { $0.likedUserID } ?? []
        
        // Now fetch all users except currentUser and except those in reactedUserIDs
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        let excludeEmails = reactedUserIDs.compactMap { userID -> String? in
            // We must find user by userID to exclude them by email or by userID directly
            // If you stored userID in UserEntity, we can exclude by userID directly:
            return nil // We'll do a different approach
        }
        
        // Better approach:
        // We'll exclude by userID. Add userID to UserEntity and do:
        request.predicate = NSPredicate(format: "userID != %@ AND NOT (userID IN %@)", currentUser.userID as CVarArg, reactedUserIDs)
        
        guard let userEntities = try? context.fetch(request) else { return [] }
        
        var profiles: [UserProfile] = []
        for ue in userEntities {
            guard let pe = ue.profile else { continue }
            let image: UIImage? = pe.photo != nil ? UIImage(data: pe.photo!) : nil
            let multipleNationalities = pe.multipleNationalities?.split(separator: ",").map { String($0) } ?? []
            let multipleEthnicities = pe.multipleEthnicities?.split(separator: ",").map { String($0) } ?? []
            
            guard let email = ue.email, let userID = ue.userID else { continue }
            
            let p = UserProfile(
                userID: userID,
                email: email,
                firstName: ue.first_name ?? "",
                lastName: ue.last_name ?? "",
                nationality: pe.nationality ?? "",
                birthday: pe.birthday ?? Date(),
                sex: pe.sex ?? "",
                ethnicity: pe.ethnicity ?? "",
                homeCountry: pe.homeCountry ?? "",
                childhoodCountry: pe.childhoodCountry ?? "",
                photo: image,
                isVisible: ue.isVisible,
                multipleNationalities: multipleNationalities,
                multipleEthnicities: multipleEthnicities
            )
            
            if p.isVisible {
                profiles.append(p)
            }
        }
        return profiles
    }
    
    /// Attempts to create a chat thread if mutual match.
    func user(_ currentUser: User, didMatchUser otherUser: User) -> ChatThreadEntity? {
        recordReaction(from: currentUser, to: otherUser, isLike: true)
        
        // Check if mutual
        if isMutualMatch(between: currentUser, and: otherUser) {
            return createChatThreadIfMutualMatch(between: currentUser, and: otherUser)
        }
        return nil
    }
    
    func fetchUserThreads(for user: User) -> [ChatThreadEntity] {
        print("Fetching threads for user: \(user.email) ID: \(user.userID)")
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<ChatThreadEntity> = ChatThreadEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userAID == %@ OR userBID == %@", user.userID as CVarArg, user.userID as CVarArg)

        do {
            let threads = try context.fetch(request)
            print("Found \(threads.count) threads for user \(user.email)")
            return threads
        } catch {
            print("Error fetching threads: \(error)")
            return []
        }
    }

    
    /// Given a thread and the currentUser, return the other user in the thread
    func getOtherUser(in thread: ChatThreadEntity, currentUser: User) -> User? {
        let context = CoreDataManager.shared.context
        
        // Identify the "other" userID
        let otherUserID: UUID
        if thread.userAID == currentUser.userID {
            guard let bID = thread.userBID else { return nil }
            otherUserID = bID
        } else {
            guard let aID = thread.userAID else { return nil }
            otherUserID = aID
        }
        
        // Fetch the userEntity for otherUserID
        let userRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        userRequest.predicate = NSPredicate(format: "userID == %@", otherUserID as CVarArg)
        guard let otherUserEntity = try? context.fetch(userRequest).first else { return nil }
        
        return User(
            userID: otherUserEntity.userID ?? UUID(),
            firstName: otherUserEntity.first_name ?? "",
            lastName: otherUserEntity.last_name ?? "",
            email: otherUserEntity.email ?? "",
            isVisible: otherUserEntity.isVisible
        )
    }
    
    func fetchMessages(for thread: ChatThreadEntity) -> [MessageEntity] {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "chatThread == %@", thread)
        let sort = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [sort]
        
        return (try? context.fetch(request)) ?? []
    }
    
    func sendMessage(in thread: ChatThreadEntity, from user: User, content: String, completion: @escaping (Bool) -> Void) {
        let context = CoreDataManager.shared.context
        
        // Create new message
        let newMessage = MessageEntity(context: context)
        newMessage.id = UUID()
        newMessage.senderUserID = user.userID
        // Assume the other user in the thread is userBID if current user is userAID else userAID
        let otherUserID = (thread.userAID == user.userID) ? thread.userBID : thread.userAID
        newMessage.receiverUserID = otherUserID
        newMessage.content = content
        newMessage.timestamp = Date()
        newMessage.isRead = false
        newMessage.type = "text" // simple case
        newMessage.chatThread = thread
        
        do {
            try context.save()
            completion(true)
        } catch {
            print("Failed to send message: \(error)")
            completion(false)
        }
    }
    
    func addMessage(to thread: ChatThreadEntity, sender: User, content: String) {
        let context = CoreDataManager.shared.context
        let msg = MessageEntity(context: context)
        msg.id = UUID()
        msg.senderUserID = sender.userID
        msg.receiverUserID = (thread.userAID == sender.userID) ? thread.userBID : thread.userAID
        msg.content = content
        msg.timestamp = Date()
        msg.isRead = false
        msg.type = "text"
        msg.chatThread = thread
        
        CoreDataManager.shared.saveContext()
    }
    
    func fetchUser(by userID: UUID) -> User? {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", userID as CVarArg)
        
        if let ue = try? context.fetch(request).first {
            return User(
                userID: ue.userID ?? UUID(),
                firstName: ue.first_name ?? "",
                lastName: ue.last_name ?? "",
                email: ue.email ?? "",
                isVisible: ue.isVisible
            )
        }
        return nil
    }
}
