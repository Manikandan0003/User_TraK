//
//  Users+CoreDataProperties.swift
//  
//
//  Created by MANIKANDAN RAJA on 21/05/24.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Users {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users> {
        return NSFetchRequest<Users>(entityName: "Users")
    }

    @NSManaged public var email: String?
    @NSManaged public var gender: String?
    @NSManaged public var id: String?
    @NSManaged public var mobile: String?
    @NSManaged public var name: String?

}

extension Users : Identifiable {

}
