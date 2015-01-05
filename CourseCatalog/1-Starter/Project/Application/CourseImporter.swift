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
import CoreData

public class CourseImporter: NSObject
{
    private let logger = Swell.getLogger("CourseImporter")
    public var results : [Course] = []
    internal dynamic var progress : Float = 0

    let stack : CoreDataStack

    public init(stack:CoreDataStack = CoreDataStack(storeName: "catalog.sqlite")) {
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
                    >>- adaptCourses
        
        logger.debug("Imported \(results?.count) courses")
        return results ?? []
    }
    
    private var adaptCoursesTotal : Float = 0
    private var adaptedCoursesCount = 0
    //TODO: Add steps for watching import progress
    func adaptCourses(courses:[_Course]) -> [Course]
    {
        let adapter = CourseAdapter(stack: stack)
        adaptCoursesTotal = Float(courses.count)
        logger.debug("Start Adapting \(adaptCoursesTotal) _Course objects")

        let notificationCenter = NSNotificationCenter.defaultCenter()
        let context = stack.backgroundContext
        notificationCenter.addObserver(self, selector: Selector("contextDidChange:"), name: NSManagedObjectContextObjectsDidChangeNotification, object: context)
        let results = adapter.adapt(courses)
        notificationCenter.removeObserver(self, name: NSManagedObjectContextObjectsDidChangeNotification, object: context)
        return results
    }
    
    func contextDidChange(notification:NSNotification)
    {
        let insertedObjects = notification.insertedObjects
        adaptedCoursesCount += insertedObjects.count
        progress = Float(adaptedCoursesCount) / adaptCoursesTotal
    }
}

extension NSNotification {
    var insertedObjects : NSSet {
        return userInfo?[NSInsertedObjectsKey] as? NSSet ?? NSSet()
    }
}
