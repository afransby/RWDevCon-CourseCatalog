//
//  Course+JSONDecoding.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/22/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import Foundation
import Argo
import Swell
import CoreData

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
    
    static func decodeObjects(json: JSON) -> [_Course?]?
    {
        let logger = Swell.getLogger("_Course:JSONDecodable")
        let elements = json["elements"] as? [AnyObject]
        let elementCount = (elements != nil) ? elements!.count : 0
        
        logger.debug("Decoding \(elementCount) elements")
        
        let results : [_Course?]? = elements?.map { elementInfo in
            return elementInfo >>- _Course.decode
        }
        logger.debug("Decoded \(results?.count) elements")
        return results
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
