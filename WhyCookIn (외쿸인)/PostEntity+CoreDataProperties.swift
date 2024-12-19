//
//  PostEntity+CoreDataProperties.swift
//  WhyCookIn (외쿸인)
//
//  Created by Joowon Jang on 12/19/24.
//
//

import Foundation
import CoreData


extension PostEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostEntity> {
        return NSFetchRequest<PostEntity>(entityName: "PostEntity")
    }

    @NSManaged public var category: String?
    @NSManaged public var content: String?
    @NSManaged public var id: UUID?
    @NSManaged public var reactionsCount: Int64
    @NSManaged public var timestamp: Date?
    @NSManaged public var title: String?
    @NSManaged public var author: UserEntity?
    @NSManaged public var comments: NSSet?
    @NSManaged public var likes: NSSet?

}

// MARK: Generated accessors for comments
extension PostEntity {

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
extension PostEntity {

    @objc(addLikesObject:)
    @NSManaged public func addToLikes(_ value: LikeEntity)

    @objc(removeLikesObject:)
    @NSManaged public func removeFromLikes(_ value: LikeEntity)

    @objc(addLikes:)
    @NSManaged public func addToLikes(_ values: NSSet)

    @objc(removeLikes:)
    @NSManaged public func removeFromLikes(_ values: NSSet)

}

extension PostEntity : Identifiable {

}
