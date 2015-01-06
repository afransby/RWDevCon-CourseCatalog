
#Core Data Threading Demo Instructions

The goal of these steps is to demonstrate how to take a main thread based Core Data app and make all import and saving operations occur on a background queue.

# 1) Construct CoreData Stack
Open CoreDataStack+Additions.swift

**Add NSManagedObjectContext**
 
	private lazy var context : NSManagedObjectContext = {
       	let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		context.persistentStoreCoordinator = self.coordinator
		return context
	}()

**Add context computed property**
	
    internal var mainContext : NSManagedObjectContext {
        return context
    }
    
##2) Write Create, Find and Save methods

**Create**

    func create<T : NSManagedObject>(type:T.Type, inContext context:NSManagedObjectContext) -> T?
    {
		let entityName = entityNameFromType(type)
		let entity = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as NSManagedObject
		return cast(entity)
    }
        
**Find**

    func find<T : NSManagedObject>(type:T.Type, orderedBy: [NSSortDescriptor]? = nil, predicate:NSPredicate? = nil, inContext context:NSManagedObjectContext) -> [T]?
    {
        let request = NSFetchRequest(entityName: entityNameFromType(type))
        request.predicate = predicate
        request.sortDescriptors = orderedBy
        
        var error : NSError?
        let result = context.executeFetchRequest(request, error: &error) as? [T]
        if result == nil {
            logger.error("[find] \(error)")
        }
        return result
    }    

**Save**

    func saveUsing(Context context:NSManagedObjectContext)
    {
        let logger = self.logger
        var error : NSError?
        
        if context.hasChanges {
            let saved = context.save(&error)
            if !saved {
                logger.error("Error saving: \(error)")
            }
            else {
                logger.debug("Saved context successfully")
            }
        }
        else {
            logger.warn("No changes to save")
        }
    }
    
	* Add Course CoreData Objects

##3) Add objects to main.storyboard

**Add CoreDataStack**

* Navigate to *Course List Scene*
* Open object browser in bottom right of Utilities Pane
* Look for NSObject
* Drag to *Course List Scene*
* Click on new object, open Identity Inspector, set Class to **CoreDataStack**

**Add Catalog DataSource**
	
* Repeat previous steps
* set class of new object to **CatalogDataSource**
	
**Add Catalog TableView DataSource**

* Repeat previous steps
* set class of new object to **CatalogTableViewDataSource**

**Wire up Objects**

* Right click on the **CourseListViewController**
* Connect the dataSource property to the **CatalogDataSource**
* Right click on **CatalogDataSource**
* Connect the stack property to the **CoreDataStack** property
* Connect the delegate property to the **CatalogTableViewDataSource** property
* Right click on the *CatalogTableViewDataSource** property
* connect the catalogDataSource property to the **CatalogDataSource** object
* Right click on the UITableView in *CourseListViewController*
* connect the dataSource property to the **CatalogTableViewDataSource** object

##4) Load Courses

	let importer = CourseImporter(stack: stack)
    importer.importJSONDataInResourceNamed("Courses.json")
    
##5) Build and Run

- Courses are now importing using the main thread

##6) Add Background Context


* Open CoreDataStack.swift

**Add lazy background Context property**

    internal var backgroundContext : NSManagedObjectContext {
        return savingContext
    }

	private lazy var savingContext : NSManagedObjectContext = {
		let savingContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		savingContext.persistentStoreCoordinator = self.coordinator
		return savingContext
	}()

**Also, you need to change the mainContext a little**

    private lazy var context : NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = self.savingContext
        return context
    }()

* open **CoreDataStack+Additions.swift**
*Change the context to backgroundContext

**For create**

	public func create<T : NSManagedObject>(type:T.Type) -> T? {
        return create(type, inContext: backgroundContext)
    }
    
**For save**

    public func save() {
        saveUsing(Context: backgroundContext)
    }
    
but we also need to push the changes to the store. In the saveUsing function, add

    if let parentContext = context.parentContext {
        self.saveUsing(Context: parentContext)
    }
    else {
        logger.debug("Saved context successfully")
    }



##7) Set ConcurrencyDebug to find Queue violations

* Open CourseCatalog scheme
* Switch to Arguments tab
* add new argument: **-com.apple.CoreData.ConcurrencyDebug 1**

##8) Need to add *performBlock* and *performBlockAndWait*

**In find, add**

	context.performBlockAndWait {
	}
        
**In create, add**

	context.performBlockAndWait {
	}
	
**In save, add**

	context.performBlock {
	}
	
**In adapt function, add**

	context.performBlockAndWait {
	}
	
## Build and Run
* Importing and saving now happens on the background



