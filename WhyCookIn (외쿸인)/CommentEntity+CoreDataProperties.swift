//
//  CommentEntity+CoreDataProperties.swift
//  WhyCookIn (외쿸인)
//
//  Created by Joowon Jang on 12/19/24.
//
//

import Foundation
import CoreData


extension CommentEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CommentEntity> {
        return NSFetchRequest<CommentEntity>(entityName: "CommentEntity")
    }

    @NSManaged public var content: String?
    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var author: UserEntity?
    @NSManaged public var likes: NSSet?
    @NSManaged public var post: PostEntity?

}

// MARK: Generated accessors for likes
extension CommentEntity {

    @objc(addLikesObject:)
    @NSManaged public func addToLikes(_ value: LikeEntity)

    @objc(removeLikesObject:)
    @NSManaged public func removeFromLikes(_ value: LikeEntity)

    @objc(addLikes:)
    @NSManaged public func addToLikes(_ values: NSSet)

    @objc(removeLikes:)
    @NSManaged public func removeFromLikes(_ values: NSSet)

}

extension CommentEntity : Identifiable {

}
