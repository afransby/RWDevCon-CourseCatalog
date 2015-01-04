//
//  CatalogDataSource.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/6/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import CoreData
import Swell

@objc protocol CatalogDataSourceDelegate
{
    func dataSourceDidAddNewObject(dataSource:CatalogDataSource, atIndexPath indexPath:NSIndexPath)
    func dataSourceDidRemoveObject(dataSource:CatalogDataSource, atIndexPath indexPath:NSIndexPath)
    func dataSourceWillChangeContent(dataSource:CatalogDataSource)
    func dataSourceDidChangeContent(dataSource:CatalogDataSource)
}

@objc class CatalogDataSource : NSObject, NSFetchedResultsControllerDelegate
{
    @IBOutlet var progressBar : UIProgressView!
    @IBOutlet weak var delegate : CatalogDataSourceDelegate?
    @IBOutlet private var stack : CoreDataStack!
    private let logger = Swell.getLogger("CatalogDataSource")
    
    lazy var courses : NSFetchedResultsController =
    {
        let request = NSFetchRequest(entityName: Course.entityName())
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self

        var error : NSError?
        let success = controller.performFetch(&error)
        if !success
        {
            println("Error fetching courses: \(error)")
        }
        else
        {
            println("Fetched \(controller.fetchedObjects?.count)")
        }

        return controller
    }()

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        loadCourses()
//    }
    
    private var catalogDataSourceObservingContext = "loadCourses"
    @IBAction func loadCourses()
    {
        if !stack.exists(Course.self)
        {
            logger.debug("Loading Catalog Data Source")
            let importer = CourseImporter(stack: stack)
            let options : NSKeyValueObservingOptions = .New | .Initial
            importer.addObserver(self, forKeyPath: "progress", options: options, context: &catalogDataSourceObservingContext)
            importer.importJSONDataInResourceNamed("Courses.json")
            importer.removeObserver(self, forKeyPath: "progress", context: &catalogDataSourceObservingContext)
            stack.saveUsing(Context: stack.backgroundContext)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &catalogDataSourceObservingContext
        {
            if keyPath == "progress"
            {
                let newValue = change[NSKeyValueChangeNewKey] as? NSNumber
                self.progressBar?.progress = Float(newValue ?? 0)
            }
        }
        else
        {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    func courseAtIndexPath(indexPath:NSIndexPath) -> Course
    {
        return courses.objectAtIndexPath(indexPath) as Course
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        println("Fetched Rows: \(controller.fetchedObjects?.count)")
        delegate?.dataSourceWillChangeContent(self)
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
//        println("Fetched Rows: \(controller.fetchedObjects?.count)")
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
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        println("Fetched Rows: \(controller.fetchedObjects?.count)")
        delegate?.dataSourceDidChangeContent(self)
    }
}

