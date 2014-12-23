//
//  Course+JSONDecoding.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/22/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import Foundation
import Argo
import CoreData

class CourseAdapter
{
    let context : NSManagedObjectContext
    init(context:NSManagedObjectContext)
    {
        self.context = context
    }
    func courseFrom(course:_Course) -> Course
    {
        let entityName = "Course"
        if let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context) {
            let savedCourse = Course(entity:entity, insertIntoManagedObjectContext:context)
            savedCourse.remoteID = course.remoteID
            savedCourse.name = course.name
            return savedCourse
        }
        return Course()
    }
}

struct _Course
{
    let name:String
    let shortName:String
    let remoteID:Int
}

extension _Course : JSONDecodable
{
    static func create(remoteID:Int)(name:String)(shortName:String) -> _Course
    {
        return _Course(name: name, shortName:shortName, remoteID: remoteID)
    }
    
    static func decode(json: JSON) -> _Course?
    {
        return _JSONParse(json) >>-
            {   data in
                self.create
                    <^> data <| "id"
                    <*> data <| "name"
                    <*> data <| "shortName"
            }
    }
}
