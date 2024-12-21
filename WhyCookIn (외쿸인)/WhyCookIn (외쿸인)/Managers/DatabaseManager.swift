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
        
        // Check if user already exists
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
                isVisible: userEntity.isVisible
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
                           multipleEthnicities: [String])
    {
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
            
            profile.multipleNationalities = multipleNationalities.joined(separator: ",")
            profile.multipleEthnicities  = multipleEthnicities.joined(separator: ",")
            
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
        
        guard
            let userEntity = try? context.fetch(request).first,
            let pe = userEntity.profile
        else {
            return nil
        }
        
        let image: UIImage? = pe.photo.map { UIImage(data: $0) } ?? nil
        
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
            return []
        }
        
        return postEntities.compactMap { p in
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
        
        return commentEntities.compactMap { c in
            guard let authorEntity = c.author else {
                return nil
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
    
    // MARK: - Reactions
    
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
        return true
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
            userEntity.isVisible = visible
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
            let image: UIImage? = pe.photo.map { UIImage(data: $0) } ?? nil
            
            let multipleNationalities = pe.multipleNationalities?.split(separator: ",").map { String($0) } ?? []
            let multipleEthnicities  = pe.multipleEthnicities?.split(separator: ",").map { String($0) } ?? []
            
            guard let email = ue.email, let userID = ue.userID else {
                continue
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
    
    func recordLike(from liker: User, to liked: User) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "likerUserID == %@ AND likedUserID == %@", liker.userID as CVarArg, liked.userID as CVarArg)
        
        if let existing = try? context.fetch(request), !existing.isEmpty {
            return
        }
        
        let newLike = LikeEntity(context: context)
        newLike.likerUserID = liker.userID
        newLike.likedUserID = liked.userID
        
        CoreDataManager.shared.saveContext()
    }
    
    func createChatThreadIfMutualMatch(between userA: User, and userB: User) -> ChatThreadEntity? {
        guard isMutualMatch(between: userA, and: userB) else {
            return nil
        }
        
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<ChatThreadEntity> = ChatThreadEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "(userAID == %@ AND userBID == %@) OR (userAID == %@ AND userBID == %@)",
            userA.userID as CVarArg,
            userB.userID as CVarArg,
            userB.userID as CVarArg,
            userA.userID as CVarArg
        )
        
        if let existingThreads = try? context.fetch(request),
           let thread = existingThreads.first {
            return thread
        }
        
        let newThread = ChatThreadEntity(context: context)
        newThread.id = UUID()
        newThread.userAID = userA.userID
        newThread.userBID = userB.userID
        
        do {
            try context.save()
            return newThread
        } catch {
            print("Failed to create chat thread: \(error)")
            return nil
        }
    }
    
    func recordReaction(from liker: User, to liked: User, isLike: Bool) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "likerUserID == %@ AND likedUserID == %@", liker.userID as CVarArg, liked.userID as CVarArg)
        
        if let existing = try? context.fetch(request), let first = existing.first {
            first.isLike = isLike
        } else {
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
    
    func isMutualMatch(between userA: User, and userB: User) -> Bool {
        let context = CoreDataManager.shared.context
        
        let requestA: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
        requestA.predicate = NSPredicate(
            format: "likerUserID == %@ AND likedUserID == %@ AND isLike == true",
            userA.userID as CVarArg, userB.userID as CVarArg
        )
        let aLikesB = ((try? context.fetch(requestA).first) != nil)
        
        let requestB: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
        requestB.predicate = NSPredicate(
            format: "likerUserID == %@ AND likedUserID == %@ AND isLike == true",
            userB.userID as CVarArg, userA.userID as CVarArg
        )
        let bLikesA = ((try? context.fetch(requestB).first) != nil)
        
        return aLikesB && bLikesA
    }
    
    func fetchNewUsersForSwipe(excluding currentUser: User) -> [UserProfile] {
        let context = CoreDataManager.shared.context
        
        // 1. Figure out who the user has already reacted to
        let reactionsRequest: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
        reactionsRequest.predicate = NSPredicate(format: "likerUserID == %@", currentUser.userID as CVarArg)
        let reactedUserIDs: [UUID] = (try? context.fetch(reactionsRequest))?.compactMap { $0.likedUserID } ?? []
        
        // 2. Fetch all users except the current user and except those in reactedUserIDs
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "userID != %@ AND NOT (userID IN %@)",
            currentUser.userID as CVarArg,
            reactedUserIDs
        )
        
        guard let userEntities = try? context.fetch(request) else {
            return []
        }
        
        var profiles: [UserProfile] = []
        
        for ue in userEntities {
            guard let pe = ue.profile else { continue }
            
            // Convert multipleNationality / multipleEthnicity strings to arrays
            let multipleNationalities = pe.multipleNationalities?
                .split(separator: ",")
                .map { String($0) } ?? []
            let multipleEthnicities = pe.multipleEthnicities?
                .split(separator: ",")
                .map { String($0) } ?? []
            
            // Safely unwrap userID/email
            guard let email = ue.email, let userID = ue.userID else {
                continue
            }
            
            // Create UIImage if photo exists
            let userPhoto: UIImage? = pe.photo.flatMap { UIImage(data: $0) }
            
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
                photo: userPhoto,
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
    
    
    func user(_ currentUser: User, didMatchUser otherUser: User) -> ChatThreadEntity? {
        recordReaction(from: currentUser, to: otherUser, isLike: true)
        if isMutualMatch(between: currentUser, and: otherUser) {
            return createChatThreadIfMutualMatch(between: currentUser, and: otherUser)
        }
        return nil
    }
    
    func fetchUserThreads(for user: User) -> [ChatThreadEntity] {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<ChatThreadEntity> = ChatThreadEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "userAID == %@ OR userBID == %@",
            user.userID as CVarArg, user.userID as CVarArg
        )
        
        // Sort by lastMessageTimestamp descending
        let sort = NSSortDescriptor(key: "lastMessageTimestamp", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            let threads = try context.fetch(request)
            return threads
        } catch {
            print("Error fetching threads: \(error)")
            return []
        }
    }
    
    func getOtherUser(in thread: ChatThreadEntity, currentUser: User) -> User? {
        let context = CoreDataManager.shared.context
        
        let otherUserID: UUID
        if thread.userAID == currentUser.userID {
            guard let bID = thread.userBID else { return nil }
            otherUserID = bID
        } else {
            guard let aID = thread.userAID else { return nil }
            otherUserID = aID
        }
        
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
    
    func sendMessage(in thread: ChatThreadEntity,
                     from user: User,
                     content: String,
                     completion: @escaping (Bool) -> Void)
    {
        let context = CoreDataManager.shared.context
        
        // Update the lastMessageTimestamp so the newest thread goes on top
        thread.lastMessageTimestamp = Date()
        
        // Create the message
        let newMessage = MessageEntity(context: context)
        newMessage.id = UUID()
        newMessage.senderUserID = user.userID
        
        let otherUserID = (thread.userAID == user.userID) ? thread.userBID : thread.userAID
        newMessage.receiverUserID = otherUserID
        newMessage.content = content
        newMessage.timestamp = Date()
        newMessage.isRead = false
        newMessage.type = "text"
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
        
        // Also update lastMessageTimestamp
        thread.lastMessageTimestamp = Date()
        
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
    
    // Hide a thread from a specific user by adding them to deletedFor array
    func hideThreadForUser(thread: ChatThreadEntity, userID: UUID) {
        let context = CoreDataManager.shared.context
        var hiddenIDs = thread.deletedFor?
            .split(separator: ",")
            .compactMap { UUID(uuidString: String($0)) } ?? []
        
        if !hiddenIDs.contains(userID) {
            hiddenIDs.append(userID)
        }
        
        thread.deletedFor = hiddenIDs.map { $0.uuidString }.joined(separator: ",")
        
        do {
            try context.save()
        } catch {
            print("Failed to hide thread: \(error)")
        }
    }
    
    // "Unhide" a thread for a user if a new message arrives
    func unhideThreadForUser(thread: ChatThreadEntity, userID: UUID) {
        let context = CoreDataManager.shared.context
        var hiddenIDs = thread.deletedFor?
            .split(separator: ",")
            .compactMap { UUID(uuidString: String($0)) } ?? []
        
        hiddenIDs.removeAll { $0 == userID }
        
        thread.deletedFor = hiddenIDs.map { $0.uuidString }.joined(separator: ",")
        
        do {
            try context.save()
        } catch {
            print("Failed to unhide thread: \(error)")
        }
    }
    
    func requestDeleteForBoth(thread: ChatThreadEntity, requestingUserID: UUID) {
        let context = CoreDataManager.shared.context
        thread.deleteForBothRequestedBy = requestingUserID
        thread.deleteForBothApproved = false
        
        do {
            try context.save()
        } catch {
            print("Error requesting delete for both: \(error)")
        }
    }
    
    func confirmDeleteForBoth(thread: ChatThreadEntity, approvingUserID: UUID, approved: Bool) {
        let context = CoreDataManager.shared.context
        
        if approved {
            // Remove from the DB entirely
            context.delete(thread)
            do {
                try context.save()
            } catch {
                print("Error deleting for both: \(error)")
            }
        } else {
            // The other user has declined
            thread.deleteForBothRequestedBy = nil
            thread.deleteForBothApproved = false
            do {
                try context.save()
            } catch {
                print("Error reverting delete request: \(error)")
            }
        }
    }
    
    // Returns total unread messages for the current user
    func getUnreadCountForAllThreads(for user: User) -> Int {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "isRead == NO AND receiverUserID == %@",
            user.userID as CVarArg
        )
        do {
            return try context.count(for: request)
        } catch {
            print("Error fetching unread count: \(error)")
            return 0
        }
    }
    
    // Checks if there's at least one unread message for currentUser in this thread
    func threadHasUnreadMessage(for thread: ChatThreadEntity, currentUser: User) -> Bool {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "chatThread == %@ AND isRead == NO AND receiverUserID == %@",
            thread, currentUser.userID as CVarArg
        )
        
        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }
    
    // Marks all messages in the thread as read for the given user
    func markAllMessagesAsRead(in thread: ChatThreadEntity, for user: User) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "chatThread == %@ AND isRead == NO AND receiverUserID == %@",
            thread, user.userID as CVarArg
        )
        
        do {
            let unreadMessages = try context.fetch(request)
            for msg in unreadMessages {
                msg.isRead = true
            }
            try context.save()
        } catch {
            print("Error marking messages as read: \(error)")
        }
    }
    
    func deleteComment(commentID: UUID) {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<CommentEntity> = CommentEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", commentID as CVarArg)
        
        do {
            if let commentEntity = try context.fetch(fetchRequest).first {
                context.delete(commentEntity)
                try context.save()
                print("Comment deleted for ID: \(commentID)")
            } else {
                print("No comment entity found for ID: \(commentID)")
            }
        } catch {
            print("Error deleting comment with ID \(commentID): \(error)")
        }
    }
    
    func deletePost(_ post: Post) {
        let context = CoreDataManager.shared.context
        
        // 1) Find PostEntity by id
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", post.id as CVarArg)
        if let pEntity = (try? context.fetch(request))?.first {
            // 2) Optionally delete related comments if you want:
            if let commentEntities = pEntity.comments {
                for cObj in commentEntities {
                    if let c = cObj as? CommentEntity {
                        context.delete(c)
                    }
                }
            }
            // 3) Delete post
            context.delete(pEntity)
            // 4) Save
            do {
                try context.save()
            } catch {
                print("Failed to delete post: \(error)")
            }
        }
    }

}
