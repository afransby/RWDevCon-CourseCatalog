//
//  CatalogDataSource.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/6/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import CoreData
import Swell

@objc protocol CatalogDataSourceDelegate {
    func dataSourceDidAddNewObject(dataSource:CatalogDataSource, atIndexPath indexPath:NSIndexPath)
    func dataSourceDidRemoveObject(dataSource:CatalogDataSource, atIndexPath indexPath:NSIndexPath)
}

@objc class CatalogDataSource : NSObject, NSFetchedResultsControllerDelegate
{
    lazy var logger = Logger.getLogger("CatalogDataSource")
    lazy var courses : NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "Course")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()

    let stack = CoreDataStack(storeName: "Catalog.sqlite")
    weak var delegate : CatalogDataSourceDelegate?

    override init(){
        super.init()
        logger.debug("Loading Catalog Data Source")
        loadCourses()
    }

    func loadCourses()
    {
        let importer = CourseImporter(stack: stack)
        importer.importJSONDataInResourceNamed("Courses.json")
        stack.save()

        var error : NSError?
        let success = courses.performFetch(&error)
        if !success
        {
            logger.error("Error fetching courses: \(error)")
        }
    }

    func objectAtIndexPath(indexPath:NSIndexPath) -> Course {
        return courses.objectAtIndexPath(indexPath) as Course
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch(type) {
        case .Insert:
            delegate?.dataSourceDidAddNewObject(self, atIndexPath: newIndexPath!)
        case .Delete:
            delegate?.dataSourceDidRemoveObject(self, atIndexPath: indexPath!)
        case .Update:
            logger.debug("Updated row \(indexPath!)")
        case .Move:
            logger.debug("Moved row from \(indexPath!) to \(newIndexPath!)")
        }
    }
}

