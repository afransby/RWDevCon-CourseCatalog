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
    let stack : CoreDataStack
    init(stack:CoreDataStack)
    {
        self.stack = stack
    }
    
    func adapt(courses:[_Course]) -> [Course]
    {
        let existingCourseFilter = NSPredicate(format: "remoteID in %@", courses.map { $0.remoteID })
        let existingCourses = stack.find(Course.self, predicate: existingCourseFilter)
        
        let updatedExistingCourses = adaptExistingCourses(existingCourses, from: courses)
        let newAdaptedCourses = adaptNewCourses(updatedExistingCourses, from: courses)
        
        return newAdaptedCourses + updatedExistingCourses
    }
    
    private func adaptNewCourses(existingCourses:[Course]?, from courses:[_Course]) -> [Course]
    {
        if let existingCourses = existingCourses
        {
            let existingCourseIDs = existingCourses.map { $0.remoteID.integerValue }
            let newRawCourses = courses.filter { find(existingCourseIDs, $0.remoteID) != nil }

            return newRawCourses.map { self.adapt(from: $0) }
        }
        return []
    }
    
    private func adaptExistingCourses(existingCourses:[Course]?, from rawCourses:[_Course]) -> [Course]
    {
        if let existingCourses = existingCourses
        {
            let existingCourseIDs = existingCourses.map { $0.remoteID.integerValue }
            let existingRawCourses = rawCourses.filter { find(existingCourseIDs, $0.remoteID) == nil }

            return existingCourses.map { course in
                let filtered = filter(rawCourses) { $0.remoteID == course.remoteID }
                return self.adapt(course: course, from:filtered.first!)
            }
        }
        return []
    }
    
    private func adapt(course:Course? = nil, from rawCourse:_Course) -> Course
    {
        var adapted : Course = course ?? stack.createInBackground(Course.self)!

        adapted.remoteID = rawCourse.remoteID
        adapted.name = rawCourse.name
        adapted.shortName = rawCourse.shortName
        return adapted
    }
}

struct _Course
{
    let name:String
    let shortName:String
    let remoteID:Int
//    
//    static let uniqueFilterTemplate = NSPredicate(format: "remoteID = $REMOTE_ID")!
//    
//    func uniqueFilter() -> NSPredicate
//    {
//        return _Course.uniqueFilterTemplate.predicateWithSubstitutionVariables(["REMOTE_ID":remoteID])
//    }
}

extension _Course : JSONDecodable
{
    static func create(remoteID:Int)(name:String)(shortName:String) -> _Course
    {
        return _Course(name: name, shortName:shortName, remoteID: remoteID)
    }
    
    static func decodeObjects(json: JSON) -> [_Course?]?
    {
        let elements = json["elements"] as? [AnyObject]
        return elements?.map { elementInfo in
            return elementInfo >>- _Course.decode
        }
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
