//
//  ProfileEntity+CoreDataProperties.swift
//  WhyCookIn (외쿸인)
//
//  Created by Joowon Jang on 12/19/24.
//
//

import Foundation
import CoreData


extension ProfileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileEntity> {
        return NSFetchRequest<ProfileEntity>(entityName: "ProfileEntity")
    }

    @NSManaged public var banned: Bool
    @NSManaged public var birthday: Date?
    @NSManaged public var childhoodCountry: String?
    @NSManaged public var ethnicity: String?
    @NSManaged public var homeCountry: String?
    @NSManaged public var multipleEthnicities: String?
    @NSManaged public var multipleNationalities: String?
    @NSManaged public var nationality: String?
    @NSManaged public var photo: Data?
    @NSManaged public var sex: String?
    @NSManaged public var user: UserEntity?

}

extension ProfileEntity : Identifiable {

}
