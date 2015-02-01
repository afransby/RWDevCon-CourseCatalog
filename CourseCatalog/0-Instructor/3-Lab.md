
#307: Core Data Threading: Lab Instructions

Even though we've set up the project with multiple contexts, we're still not quite done implementing things correctly. As it turns out, we're missing a few crucial calls that enable Core Data to properly protect access to data objects. While you may certainly be able to ship an app without performing these steps, not doing so may result in random crashes. Chances are, it's likely to happen in your apps, so let's find out how to find and resolve the improper usage of the Core Data threading API.

### 1) Update Scheme Settings

In Xcode, in the toolbar, select the CourseCatalog project, and select Edit Scheme in the pop menu.

![](./3-Lab-Images/Xcode-Edit-Scheme.png)

In the edit scheme dialog, select the **Arguments** tab.

Add a new **Argument Passed on Launch** by clicking the **+** button at the bottom. Enter the following as the complete argument value:

	-com.apple.CoreData.ConcurrencyDebug 1
	
In iOS7, the Core Data team introduced this flag to help developers find improper usages of Core Data threading support in their apps. Enabling concurrency debugging for Core Data causes your app to crash when a thread assertion has been hit inside the Core Data framework. That is, when you are improperly using the Core Data threading API, for example by accessing an object on an incorrect queue, the Concurrency Debug flag enables Core Data to detect when this is happening, and stops immediately so that you can correct the code. So, how is this 'feature' helpful? This crash isn't necessarily a crash, per se, but an assertion. And most assertions in Objective C and Core Data are thrown exceptions. That means you can simply catch all exceptions when debugging your application and the debugger will land in the exact spot where the problem is being caused. 

Now that you've enabled the debug flag, you need to make sure that you're catching all the exceptions in the debugger.

### 2) Add an Exception Breakpoint

Well, let's go ahead as make sure we're catching all exceptions in the debugger.

In Xcode, show the Breakpoint Navigator tab:

![](./3-Lab-Images/Xcode-Show-Breakpoint-Navigator.png)

The keyboard shortcut key is Cmd + 7.

At the bottom, click on the **+** button, and select **Add Exception Breakpoint**

![](./3-Lab-Images/Xcode-Add-Exception-Breakpoint.png)

This should be enough to catch all exceptions that happen in your application. However you can limit the exceptions the debugger catches by right-clicking on the new Exception break point. Then select **Edit Breakpoint...**. In the Exceptions setting, select 'Objective-C'.

![](./3-Lab-Images/Xcode-Exception-Breakpoint-Settings.png)

###3) Build and Run ... and Crash

Now, in this case, we're actually looking for crashes because of the Core Data concurrency debug flag.

Build and run the app. Press the **Load Courses** button. The app should crash, and Xcode should be pointing you to some assembly. Assembly doesn't really help most of us here, but what is important is the stack trace that is available in the Debug Navigator. You'll need to look up the debug stack, and look for the highest stack that refers to your code. This should be the place that has triggered Core Data to crash since it's not correctly using threads. As these crashes are caused by asserting thread access, the steps below may appear in a different order for you.


The first crash will appear in the find function in the CoreDataStack+Additions file. The crash is occurring on the line that executes the fetch request. To resolve this issue, wrap the line performing the fetch request like the following:

	context.performBlock {
	    var result : [T]?
	    var error : NSError?

	    let result = context.executeFetchRequest(request, error: &error) as? [T]
	    if result == nil
    	{
      		logger.error("[find] \(error)")
    	}
	    return result
	}

	
Unfortunately, this won't work as the return is inside the block. You'll need to define the result to return from the find method outside the block, and let the block set the result once the operation is complete. Your code should look like this when it's all refactored:

    var result : [T]?
    var error : NSError?
    let context = mainContext
    context.performBlock {
		result = context.executeFetchRequest(request, error: &error) as? [T]
    }
    if result == nil
    {
		logger.error("[find] \(error)")
    }
    return result

This, however isn't using the correct method. performBlock is called on a background queue internal to the NSManagedObjectContext. That means, in this case, result is not going to be valid prior to returning from find. What we need is to use performBlockAndWait instead. This lets Core Data manage threading access while still letting our simple find method block on its own thread until the result is ready. Ideally, you want to use performBlock anytime you're doing work with a NSManagedObjectContext.

Build and run and continue to find the next few crashes involving improper thread access.

In the case of the CourseCatalog app, the rule of thumb for using performBlock versus performBlock and wait is going to be the context of the function from which it is used. If  a function is like the find function, and is returning the result of the fetch as the return value, the you want to use performBlockAndWait so that the return value is filled in properly when the function exits. This will be the case when resolving issues in the **create** and **find** functions

If the function doesn't care about the value within the block, then simply use performBlock. This will be the case when the crash occurs in the **save** and **adapt** functions.
        
##4) Conclusion

	
And now you have an app that is performing its main data importing operations in the background. You're now ready to start the challenges and getting your app to  display visual progress during import.