//
//  CoreDataStack.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/7/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import CoreData

public class CoreDataStack
{
    let storeName : String?
    private lazy var storeURL : NSURL? = {
        let searchPaths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        let searchPath : String = searchPaths.first? as String
        let storeURL = NSURL(fileURLWithPath: searchPath)!

        if let storeName = self.storeName {
            return storeURL.URLByAppendingPathComponent(storeName)
        }
        return nil
    }()

    func description() -> String
    {
        return "CoreDataStack:\n" +
            "Context: \(context)\n" +
            "Model: \(model)\n" +
            "Coordinator: \(coordinator)"
    }

    public init()
    {
    }

    init(storeName:String)
    {
        self.storeName = storeName
    }

    init(url:NSURL) {
        self.storeName = url.lastPathComponent!
        self.storeURL = url
    }

    var mainContext : NSManagedObjectContext {
        return context
    }

    var backgroundContext : NSManagedObjectContext {
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
        switch (storeURL) {
        case .Some(let storeURL):
            coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: nil)
        case .None:
            coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
        }
//        println("Loaded Coordinator: \(coordinator)")
//        println("-- Stores: \(coordinator.persistentStores)")
    }

    private lazy var model : NSManagedObjectModel = {
        let bundle = NSBundle(forClass: CoreDataStack.self)
        let model = NSManagedObjectModel.mergedModelFromBundles([bundle])!
//        println("Loaded Model: \(model.entityVersionHashesByName)")
//        println("-- from Bundle: \(bundle)")
//        println("-- Model: \(model.entities)")
        return model
    }()
}

extension CoreDataStack
{   //CRUD
    public func create<T : NSManagedObject>(type:T.Type) -> T? {
        return create(type, inContext: context)
    }

    func create<T : NSManagedObject>(type:T.Type, inContext context:NSManagedObjectContext) -> T? {
        if let entityName = NSStringFromClass(type).componentsSeparatedByString(".").last
        {
            if let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context) {
                let entity = T(entity: entityDescription, insertIntoManagedObjectContext: context) as T
                return .Some(entity)
            }
        }
        return .None
    }
}
