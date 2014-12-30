//
//  CourseDataImporter.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/7/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import UIKit
import Argo
import Swell

func mapSome<T>(items:[T?]) -> [T]
{
    return items.filter { $0 != nil }.map { $0! }
}

public class CourseImporter: NSObject
{
    private let logger = Swell.getLogger("CourseImporter")
    private var _results : [Course]?
    public var results : [Course] {
        return _results ?? []
    }

    let stack : CoreDataStack

    public init(stack:CoreDataStack = CoreDataStack()) {
        self.stack = stack
    }

    func importJSONDataInResourceNamed(name:String, inBundle bundle:NSBundle = NSBundle.mainBundle())
    {
        if let resourceURL = bundle.URLForResource(name.stringByDeletingPathExtension, withExtension: name.pathExtension) {
            let inputStream = NSInputStream(URL: resourceURL)
            inputStream?.open()
            if let json : AnyObject = NSJSONSerialization.JSONObjectWithStream(inputStream!, options: NSJSONReadingOptions.allZeros, error: nil)
            {
                importDataFrom(json)
            }
        }
    }

    public func importDataFrom(data:AnyObject)
    {
        _results = data
                    >>- _Course.decodeObjects
                    >>- mapSome
                    >>- CourseAdapter(stack: self.stack).adapt
        logger.debug("Decoded \(_results?.count) courses")
    }
}
