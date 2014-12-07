//
//  CatalogDataSource.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/6/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import CoreData

@objc protocol CatalogDataSourceDelegate {
    func dataSourceDidAddNewObject(dataSource:CatalogDataSource, atIndexPath indexPath:NSIndexPath)
    func dataSourceDidRemoveObject(dataSource:CatalogDataSource, atIndexPath indexPath:NSIndexPath)
}

@objc class CatalogDataSource : NSObject, NSFetchedResultsControllerDelegate
{
    var courses : NSFetchedResultsController?
    var objects = [AnyObject]()
    weak var delegate : CatalogDataSourceDelegate?

    override init(){
        println("Loading Catalog Data Source")
    }

    func loadCourses() {
        CourseCatalogRequest().send() { response in
        }
    }

    func addNewObject() {
        addObjectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
    }
    
    func addObjectAtIndexPath(indexPath:NSIndexPath) {
        objects.insert(NSDate(), atIndex: indexPath.row)
        delegate?.dataSourceDidAddNewObject(self, atIndexPath: indexPath)
    }

    func removeObjectAtIndexPath(indexPath:NSIndexPath) {
        objects.removeAtIndex(indexPath.row)
        delegate?.dataSourceDidRemoveObject(self, atIndexPath: indexPath)
    }

    func objectAtIndexPath(indexPath:NSIndexPath) -> NSDate {
        return objects[indexPath.row] as NSDate
    }
}

struct CourseCatalogRequest {
    func send(completion: (response:CourseCatalogResponse) -> ()) {
        completion(response: CourseCatalogResponse())
    }
}

struct CourseCatalogResponse {

}

