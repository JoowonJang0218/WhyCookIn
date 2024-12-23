//
//  ChatThreadEntity+CoreDataProperties.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/24/24.
//
//

import Foundation
import CoreData


extension ChatThreadEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatThreadEntity> {
        return NSFetchRequest<ChatThreadEntity>(entityName: "ChatThreadEntity")
    }

    @NSManaged public var deletedFor: String?
    @NSManaged public var deleteForBothApproved: Bool
    @NSManaged public var deleteForBothRequestedBy: UUID?
    @NSManaged public var id: UUID?
    @NSManaged public var lastMessageTimestamp: Date?
    @NSManaged public var userAID: UUID?
    @NSManaged public var userBID: UUID?
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension ChatThreadEntity {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageEntity)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageEntity)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

extension ChatThreadEntity : Identifiable {

}
