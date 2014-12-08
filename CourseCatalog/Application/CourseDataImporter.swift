//
//  CourseDataImporter.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/7/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import UIKit

public class CourseDataImporter: NSObject {

    public var results : [Course] = []

    let stack : CoreDataStack = CoreDataStack()

    public func importData(data:NSDictionary) {
        let elements = data["elements"] as? [AnyObject]
        results = elements!.map { elementInfo in

            let course = self.createCourse <^>
                            elementInfo["id"] >>> JSONParse <*>
                            elementInfo["name"] >>> JSONParse
            return course!
        }
    }

    func createCourse(remoteID:NSNumber)(name:String) -> Course
    {
        let course = self.stack.create(Course.self)!
        course.remoteID = remoteID
        course.name = name
        return course
    }
}

typealias JSON = AnyObject
typealias JSONArray = Array<JSON>
typealias JSONDictionary = Dictionary<String, JSON>

func JSONParse<T>(json:JSON) -> T? {
    return json as? T
}
