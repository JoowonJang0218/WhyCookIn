//
//  PostEntity+CoreDataProperties.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/17/24.
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
    @NSManaged public var comments: CommentEntity?

}

extension PostEntity : Identifiable {

}
