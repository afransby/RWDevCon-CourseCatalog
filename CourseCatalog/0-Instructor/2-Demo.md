
#Core Data Threading Demo Instructions

The goal of these steps is to demonstrate how to take a main thread based Core Data app and make all import and saving operations occur on a background queue.

# 0) Setup Project
In your course materials, copy the contents of the files in 1-Starter and paste them somewhere easy, like your Desktop

* Open CourseCatalog.xcproject
* Build and Run. You should see the app, a simple table view with a Load Courses button at the top.
* Quick overview of project
 * Simple storyboard
 * CoreDataStack object
 * CoreDataStack+Additions

# 1) Construct CoreData Stack
Open CoreDataStack+Additions.swift

**Setup the NSManagedObjectContext**
 
	private lazy var context : NSManagedObjectContext = {
       	let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		context.persistentStoreCoordinator = self.coordinator //<--- uncomment this line
		return context
	}()

**Add context computed property**
	
    internal var mainContext : NSManagedObjectContext {
        return context
    }
    
##2) Fill in Save method

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
    
* Quickly explain logger variable

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

---

* Right click on **CatalogDataSource**
* Connect the stack property to the **CoreDataStack** property
* In the CatalogDataSource class, change the type of the delegate property to AnyObject
* Connect the delegate property to the **CatalogTableViewDataSource** property
* Back in the CatalogDataSource class, change the type back to the **CatalogDataSourceDelegate** protocol

---

* Right click on the *CatalogTableViewDataSource** property
* connect the catalogDataSource property to the **CatalogDataSource** object

---

* Right click on the UITableView in *CourseListViewController*
* connect the dataSource property to the **CatalogTableViewDataSource** object

##4) Load Courses

* Open Storyboard
* Connect *Load Courses* button to **loadCourses** action on **CatalogDataSource**

In CatalogDataSource.swift

	let importer = CourseImporter(stack: stack)
    importer.importJSONDataInResourceNamed("Courses.json")
    
##5) Build and Run

- Press Load Courses button
- Courses are now importing using the main thread

##6) Add Background Context

* Setting up using NSNotifications
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

##7) Set up Notifications

* open CoreDataStack.swift 
* add helper function in **NSManagedObjectContext** extension to setup watching for notifications

---
 
	extension NSManagedObjectContext {
    	private func watchSavesToContext(context:NSManagedObjectContext)
	    {
    	    let notificationCenter = NSNotificationCenter.defaultCenter()
        
        	let selector = Selector("mergeChangesFromContextDidSaveNotification:")
	        notificationCenter.addObserver(self, selector: selector, name: NSManagedObjectContextDidSaveNotification, object: context)
    	}
	}

##7) Start using backgroundContext

* open **CoreDataStack+Additions.swift**

**For create**

	public func create<T : NSManagedObject>(type:T.Type) -> T? {
        return create(type, inContext: backgroundContext)
    }
    
**For save**

    public func save() {
        saveUsing(Context: backgroundContext)
    }
    
