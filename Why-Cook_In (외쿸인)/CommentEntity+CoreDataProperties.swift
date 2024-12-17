//
//  CommentEntity+CoreDataProperties.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/17/24.
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
    @NSManaged public var post: PostEntity?

}

extension CommentEntity : Identifiable {

}
