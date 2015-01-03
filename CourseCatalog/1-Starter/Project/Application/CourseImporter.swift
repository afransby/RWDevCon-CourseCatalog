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
    public var results : [Course] = []

    let stack : CoreDataStack

    public init(stack:CoreDataStack = CoreDataStack()) {
        self.stack = stack
    }

    func urlForResourceNamed(name:String, bundle:NSBundle) -> NSURL?
    {
        return bundle.URLForResource(name.stringByDeletingPathExtension, withExtension: name.pathExtension)
    }
    
    func inputStreamFromURL(resourceURL:NSURL) -> NSInputStream?
    {
        return NSInputStream(URL: resourceURL)
    }

    func jsonObjectFromInputStream(inputStream:NSInputStream) -> AnyObject?
    {
        inputStream.open()
        return NSJSONSerialization.JSONObjectWithStream(inputStream, options: NSJSONReadingOptions.allZeros, error: nil)
    }
    
    func importJSONDataInResourceNamed(name:String, inBundle bundle:NSBundle = NSBundle.mainBundle())
    {
        if let url = urlForResourceNamed(name, bundle:bundle)
        {
            let courses = url
                        >>- inputStreamFromURL
                        >>- jsonObjectFromInputStream
                        >>- importData
            
            results = courses ?? []
        }
    }

    public func importData(From dataObject:AnyObject) -> [Course]
    {
        let results = dataObject
                    >>- _Course.decodeObjects
                    >>- mapSome
                    >>- CourseAdapter(stack: self.stack).adapt
        
        logger.debug("Decoded \(results?.count) courses")
        return results ?? []
    }
}
