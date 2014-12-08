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
//            elementInfo["id"]
            let course = self.stack.create(Course.self)!
            println("Course: \(course.name)")
            return course
        }
        println("Sample result: \(results.first!)")
    }
}
