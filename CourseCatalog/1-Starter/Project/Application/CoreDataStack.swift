//
//  CoreDataStack.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/7/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import CoreData
import Swell

public class CoreDataStack
{
    internal lazy var logger : Logger = Swell.getLogger("CoreDataStack")
    
    let storeName : String?
    private lazy var storeURL : NSURL? = {
        let searchPaths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        let searchPath : String = searchPaths.first? as String
        let storeURL = NSURL(fileURLWithPath: searchPath)!
        if !storeURL.checkResourceIsReachableAndReturnError(nil) {
            NSFileManager.defaultManager().createDirectoryAtURL(storeURL, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        if let storeName = self.storeName {
            return storeURL.URLByAppendingPathComponent(storeName)
        }
        return nil
    }()

    func description() -> String
    {
        return "CoreDataStack:\n" +
            "Context: \(context)\n" +
            "Model: \(model.entitiesByName)\n" +
            "Coordinator: \(coordinator)"
    }

    public init()
    {
    }

    init(storeName:String)
    {
        self.storeName = storeName
    }

    init(url:NSURL)
    {
        self.storeName = url.lastPathComponent!
        self.storeURL = url
    }

    internal var mainContext : NSManagedObjectContext {
        return context
    }

    internal var backgroundContext : NSManagedObjectContext {
        return savingContext
    }

    private lazy var context : NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.coordinator
        return context
    }()

    private lazy var savingContext : NSManagedObjectContext = {
        let savingContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        savingContext.parentContext = self.context
        return savingContext
    }()

    private lazy var coordinator : NSPersistentStoreCoordinator = {
        let coordinator : NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        self.configureCoordinator(coordinator)
        return coordinator
    }()

    private func configureCoordinator(coordinator:NSPersistentStoreCoordinator) {
        var error : NSError?
        var store : NSPersistentStore?
        switch (storeURL) {
        case .Some(let storeURL):
            let options = [NSSQLitePragmasOption : ["journal_mode": "DELETE"]]
            store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error)
        case .None:
            store = coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: &error)
        }
        logger.debug("Loaded Coordinator: \(coordinator)")
        if let store = store
        {
            logger.debug("-- Added Store: \(store)")
        }
        if let error = error {
            logger.error("\(error)")
        }
    }

    private lazy var model : NSManagedObjectModel = {
        let bundle = NSBundle(forClass: CoreDataStack.self)
        let model = NSManagedObjectModel.mergedModelFromBundles([bundle])!
        
        let logger = self.logger
        logger.debug("Loaded Model: \(model.entityVersionHashesByName)")
        logger.debug("-- from Bundle: \(bundle)")
        logger.debug("-- Model: \(model.entities)")
        return model
    }()
}

