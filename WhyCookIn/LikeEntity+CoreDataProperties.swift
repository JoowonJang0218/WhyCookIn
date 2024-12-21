//
//  LikeEntity+CoreDataProperties.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/20/24.
//
//

import Foundation
import CoreData


extension LikeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikeEntity> {
        return NSFetchRequest<LikeEntity>(entityName: "LikeEntity")
    }

    @NSManaged public var likedUserID: UUID?
    @NSManaged public var likerUserID: UUID?
    @NSManaged public var isLike: Bool
    @NSManaged public var comment: CommentEntity?
    @NSManaged public var message: MessageEntity?
    @NSManaged public var post: PostEntity?
    @NSManaged public var user: UserEntity?

}

extension LikeEntity : Identifiable {

}
