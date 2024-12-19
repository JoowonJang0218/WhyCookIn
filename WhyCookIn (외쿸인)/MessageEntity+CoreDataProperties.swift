//
//  MessageEntity+CoreDataProperties.swift
//  WhyCookIn (외쿸인)
//
//  Created by Joowon Jang on 12/19/24.
//
//

import Foundation
import CoreData


extension MessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    }

    @NSManaged public var content: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isRead: Bool
    @NSManaged public var mediaData: Data?
    @NSManaged public var receiverUserID: UUID?
    @NSManaged public var senderUserID: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var type: String?
    @NSManaged public var chatThread: ChatThreadEntity?
    @NSManaged public var likes: NSSet?

}

// MARK: Generated accessors for likes
extension MessageEntity {

    @objc(addLikesObject:)
    @NSManaged public func addToLikes(_ value: LikeEntity)

    @objc(removeLikesObject:)
    @NSManaged public func removeFromLikes(_ value: LikeEntity)

    @objc(addLikes:)
    @NSManaged public func addToLikes(_ values: NSSet)

    @objc(removeLikes:)
    @NSManaged public func removeFromLikes(_ values: NSSet)

}

extension MessageEntity : Identifiable {

}
