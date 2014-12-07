//
//  Course.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/7/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import Foundation
import CoreData

public class Course: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var shortName: String
    @NSManaged var remoteID: NSNumber
    @NSManaged var smallIcon: AnyObject
    @NSManaged var largeIcon: AnyObject
    @NSManaged var instructorName: String
    @NSManaged var summary: String
    @NSManaged var syllabus: String

}
