
#Challenge

Much of the work we do with CoreData is purely behind the scenes. Users only notice that data is being loaded or manipulated when you show them. So let's do that!


##Progress Bar
In this challenge, you'll need to add a progress bar to the UI to show the progress in loading the Courses as the app launches (since that data is local).

One way to know when updates have occured is to watch the proper NSManagedObjectContext for NSManagedObjectContextObjectsDidChangeNotification notifications. This happens when an object has changes to report. But this notification isn't always sent, and it's not sent prior to every save. 


##More Parallel Stack
While a single PSC is usually all you'll need. Having a second one around may make sense in some cases. Can you add a second PSC to the stack and have one be a read only PSC and the other be write only?