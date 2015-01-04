//
//  CourseDataSource.swift
//  CourseCatalog
//
//  Created by Saul Mora on 1/3/15.
//  Copyright (c) 2015 Magical Panda. All rights reserved.
//

import CoreData
import Argo

class CourseDataSource: NSObject {
    private let stack : CoreDataStack = CoreDataStack(storeName: "catalog.sqlite")
    private var course : Course?
    
    init(course:Course) {

        var error : NSError?
        self.course = stack.mainContext.existingObjectWithID(course.objectID, error: &error) as Course?

        super.init()
    }

    func updateCourseDetails(completion:(Course?) -> ()) {
        completion(nil)
//        requestCourse(course?.remoteID) { result in
//        }
//            println(result)
//            switch result {
//            case .Value(let value):
//                completion?(value())
//            case .Error:
//                completion?(nil)
//            }
//        }
    }
}

func requestCourse(id:Int, completion: (Result<Course>) -> ()) {
    let baseURL = NSURL(string: "https://api.coursera.org/api/catalog.v1/courses")!
    let parseJSON = { $0 >>- _Course.decode >>- CourseAdapter(stack: CoreDataStack()).adapt }
    let courseResource = jsonResource("courses", .GET, [:], parseJSON)
    apiRequest({ _ in }, baseURL, courseResource, defaultFailureHandler) { course in
        completion(Result(course))
    }
}
