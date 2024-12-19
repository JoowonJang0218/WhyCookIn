//
//  UserEntity+CoreDataProperties.swift
//  WhyCookIn (외쿸인)
//
//  Created by Joowon Jang on 12/19/24.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var email: String?
    @NSManaged public var first_name: String?
    @NSManaged public var isVisible: Bool
    @NSManaged public var last_name: String?
    @NSManaged public var password: String?
    @NSManaged public var userID: UUID?
    @NSManaged public var comments: NSSet?
    @NSManaged public var likes: NSSet?
    @NSManaged public var posts: NSSet?
    @NSManaged public var profile: ProfileEntity?

}

// MARK: Generated accessors for comments
extension UserEntity {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: CommentEntity)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: CommentEntity)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}

// MARK: Generated accessors for likes
extension UserEntity {

    @objc(addLikesObject:)
    @NSManaged public func addToLikes(_ value: LikeEntity)

    @objc(removeLikesObject:)
    @NSManaged public func removeFromLikes(_ value: LikeEntity)

    @objc(addLikes:)
    @NSManaged public func addToLikes(_ values: NSSet)

    @objc(removeLikes:)
    @NSManaged public func removeFromLikes(_ values: NSSet)

}

// MARK: Generated accessors for posts
extension UserEntity {

    @objc(addPostsObject:)
    @NSManaged public func addToPosts(_ value: PostEntity)

    @objc(removePostsObject:)
    @NSManaged public func removeFromPosts(_ value: PostEntity)

    @objc(addPosts:)
    @NSManaged public func addToPosts(_ values: NSSet)

    @objc(removePosts:)
    @NSManaged public func removeFromPosts(_ values: NSSet)

}

extension UserEntity : Identifiable {

}
