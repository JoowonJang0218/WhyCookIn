//
//  ChatThreadEntity+CoreDataProperties.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/19/24.
//
//

import Foundation
import CoreData


extension ChatThreadEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatThreadEntity> {
        return NSFetchRequest<ChatThreadEntity>(entityName: "ChatThreadEntity")
    }

    @NSManaged public var id: UUID?
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
