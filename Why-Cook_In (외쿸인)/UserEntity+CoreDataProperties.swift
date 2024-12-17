//
//  UserEntity+CoreDataProperties.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/17/24.
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
    @NSManaged public var comments: CommentEntity?
    @NSManaged public var posts: PostEntity?
    @NSManaged public var profile: ProfileEntity?

}

extension UserEntity : Identifiable {

}
