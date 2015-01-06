
#Core Data Threading Demo Instructions

The goal of these steps is to demonstrate how to take a main thread based Core Data app and make all import and saving operations occur on a background queue.

* Construct CoreData Stack

	* Add MOC
	* Add PSC
	* Add StoreURL
		- Add IBInspectibile
	* Add Course CoreData Objects

* Add Catalog DataSource to Storyboard
* Add Catalog TableView DataSource to Storyboard


* --Importing data is now on main thread
* Show importing slowness
 * Slow UI
 * Instruments/Profiling
* Add backgroundContext to stack
* Modify importer to use background context when creating new Course CoreData objects
* --Importing data is now on background thread
* Add ConcurrencyDebug flag in launch flags
* Add performBlock/performBlockAndWait around critical places


