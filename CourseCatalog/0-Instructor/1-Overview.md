
* Setup Starter Project
* Build/Run. See no data
* Quickly Construct CoreData Stack
* Add Catalog DataSource to Storyboard
* Add Catalog TableView DataSource to Storyboard
* Add JSON parsing
* Add unit tests
* Add Course Object Adapter
* Add Course CoreData Objects
* Make data importing functional (side note)
* --Importing data is now on main thread
* Show importing slowness
 * Slow UI
 * Instruments/Profiling
* Add backgroundContext to stack
* Modify importer to use background context when creating new Course CoreData objects
* --Importing data is now on background thread


**Lab**:

* Data isn't saved to store
 * Add recursive save call
* Show course detail view
 * Have single course detail download/update in background using the CoreDataStack object (without {the evil} singleton pattern!)



**Challenge**:

* push/pop detail view to show how to launch a single update command without re-requesting the same information all the time


* Can you make a progress bar and show the import process updating?
