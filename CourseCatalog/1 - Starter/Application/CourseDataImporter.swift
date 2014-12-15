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

    let stack : CoreDataStack

    public init(stack:CoreDataStack = CoreDataStack()) {
        self.stack = stack
    }

    func importJSONDataInResourceNamed(name:String, inBundle bundle:NSBundle = NSBundle.mainBundle())
    {
        if let resourceURL = bundle.URLForResource(name.stringByDeletingPathExtension, withExtension: name.pathExtension) {
            let inputStream = NSInputStream(URL: resourceURL)
            inputStream?.open()
            if let json = NSJSONSerialization.JSONObjectWithStream(inputStream!, options: nil, error: nil) as? NSDictionary {
                importData(json)
            }
        }
    }

    public func importData(data:NSDictionary)
    {
        let elements = data["elements"] as? [AnyObject]
        let stack = self.stack
        let existTemplate = NSPredicate(format: "remoteID = $REMOTE_ID")!
        results = elements!.map { elementInfo in

            let remoteID : NSNumber? = elementInfo["id"] >>> JSONParse
            let existsFilter = existTemplate.predicateWithSubstitutionVariables(["REMOTE_ID": remoteID!])
            let course = self.createCourse <^>
                            stack <*>
                            existsFilter <*>
                            remoteID <*>
                            elementInfo["name"] >>> JSONParse <*>
                            elementInfo["shortName"] >>> JSONParse
            return course!
        }
    }

    func createCourse(stack:CoreDataStack)(uniquenessFilter:NSPredicate)(remoteID:NSNumber)(name:String)(shortName:String) -> Course
    {
        var course : Course
        if !stack.exists(Course.self, predicate: uniquenessFilter) {
            course = stack.create(Course.self)!
            course.remoteID = remoteID
        } else {
            let result = stack.find(Course.self, predicate: uniquenessFilter)!
            course = result.first!
        }

        course.name = name
        course.shortName = shortName
        return course
    }
}

typealias JSON = AnyObject
typealias JSONArray = Array<JSON>
typealias JSONDictionary = Dictionary<String, JSON>

func JSONParse<T>(json:JSON) -> T? {
    return json as? T
}
