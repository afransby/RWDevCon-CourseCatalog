//
//  CoreDataStack+Additions.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/29/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import Foundation
import CoreData
import Swell

private func entityNameFromType<T : NSManagedObject>(type:T.Type) -> String
{
    if let entityName = type.entityName().componentsSeparatedByString(".").last {
        return entityName
    }
    return NSStringFromClass(type)
}

extension CoreDataStack
{
    func find<T : NSManagedObject>(type:T.Type, orderedBy: [NSSortDescriptor]? = nil, predicate:NSPredicate? = nil) -> [T]? {
        return find(type, orderedBy: orderedBy, predicate: predicate, inContext: mainContext)
    }
    
    func find<T : NSManagedObject>(type:T.Type, orderedBy: [NSSortDescriptor]? = nil, predicate:NSPredicate? = nil, inContext context:NSManagedObjectContext) -> [T]? {
        return nil
    }
    
    public func create<T : NSManagedObject>(type:T.Type) -> T? {
        return create(type, inContext: mainContext)
    }
    
    func create<T : NSManagedObject>(type:T.Type, inContext context:NSManagedObjectContext) -> T? {
        return nil
    }
    
    public func save() {
        saveUsing(Context: mainContext)
    }
    
    //TODO: Write save
    func saveUsing(Context context:NSManagedObjectContext) {

    }
}
