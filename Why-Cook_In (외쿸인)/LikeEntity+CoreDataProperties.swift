//
//  LikeEntity+CoreDataProperties.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/19/24.
//
//

import Foundation
import CoreData


extension LikeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikeEntity> {
        return NSFetchRequest<LikeEntity>(entityName: "LikeEntity")
    }

    @NSManaged public var likerUserID: UUID?
    @NSManaged public var likedUserID: UUID?
    @NSManaged public var user: UserEntity?
    @NSManaged public var post: PostEntity?
    @NSManaged public var comment: CommentEntity?
    @NSManaged public var message: MessageEntity?

}

extension LikeEntity : Identifiable {

}
