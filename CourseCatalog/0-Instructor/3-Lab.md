
#Lab
The goal of these steps of the lab exercise is to demonstrate adding background saving of Core Data objects using data from a network call.


When you tap on a Course in the Course Catalog View, you'll be presented with a Course Detail View. The Coursera API provides many pieces of data for each course. We don't want to download all the course details at once as that could mean lots of unnecessary network downloads. The flow will basically be:

1. A learner taps on a course
2. The app presents a new screen with what information is already present
3. The detail view requests an update from the Course web service for updated data
4. We download the data, and import it into Core Data
5. We merge the saved data into the main thread
6. Update the Main UI

//add saving context
//use notification center to merge saves

//change 

* Save using the root saving context
* merge changes to the main UI context using NSNotifications
* add a progress bar to importing

* Data isn't saved to store
 * Add recursive save call
* Show course detail view
 * Have single course detail download/update in background using the CoreDataStack object (without {the evil} singleton pattern!)
