//
//  CourseDataImporter.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/7/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import UIKit
import Argo

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
                importDataFrom(json)
            }
        }
    }

    public func importDataFrom(data:NSDictionary)
    {
        let elements = data["elements"] as? [AnyObject]
        let stack = self.stack
        let existTemplate = NSPredicate(format: "remoteID = $REMOTE_ID")!
        let adapter = CourseAdapter(context:stack.backgroundContext)
        let courses : [Course?] = elements!.map { elementInfo in
            let course = elementInfo >>-
                        _Course.decode >>-
                        adapter.courseFrom
            return course
        }
        results = courses.filter { $0 != nil }.map { $0! }
    }
}
