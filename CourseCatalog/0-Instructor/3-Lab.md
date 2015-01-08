
#Lab
The goal of these steps of the lab exercise is to demonstrate adding background saving of Core Data objects using data from a network call.


When you tap on a Course in the Course Catalog View, you'll be presented with a Course Detail View. The Coursera API provides many pieces of data for each course. We don't want to download all the course details at once as that could mean lots of unnecessary network downloads. The flow will basically be:

1. A learner taps on a course
2. The app presents a new screen with what information is already present
3. The detail view requests an update from the Course web service for updated data
4. We download the data, and import it into Core Data
5. We merge the saved data into the main thread
6. Update the Main UI

# Requesting Network data

Just as there is a CatalogDataSource to handle the loading and requests for the CourseCatalog, we're going to put our requests in a CourseDataSource.


Open the CourseDataSource.swift file, and you'll see a simple class. 

We're going to need a CoreDataStack in order to perform data operations, so add a new property:


	private let stack : CoreDataStack
	
and in the initializer, set the CoreDataStack to something useful:

    init(course:Course) {
    	self.stack = CoreDataStack()
        self.course = course
        super.init()
    }

Next, you're going to need a way to start the update process. Create a simple method called updateCourseDetails:

	func updateCourseDatails(completion:(Course?) -> ()) {
	}
	
Because we want to work asynchronously, we'll need call a completion block when the update is actually done.

The URL you'll be using to fetch course details is nearly the same one used to fetch the course catalog:

        https://api.coursera.org/api/catalog.v1/courses?id=\(id)&fields=largeIcon,smallIcon,shortDescription,aboutTheCourse
        
This API will return JSON data for which the app is ready to parse. You'll just have to set it up. Let's get to it!


Accompanying the CourseDataSource.swift file is another file named Networking.swift. In this file is a small set of network functions to help with the task of sending a network request out and handling data. The function you'll use is called *apiRequest*. The apiRequest function also incorporates the idea of typing the resource at the end of a request. So, if we're asking for JSON data, we'll need to request a JSON Resource. The function for creating a jsonResource looks like:

	func jsonResource<A>(path: String, method: Method, requestParameters: JSONValue, parse: JSONValue -> A?) -> Resource<A> 

The last parameter can be tricky to understand. When this method gets the "resource", it'll run that result through the parse parameter, which happens to be a function. Here's a parse function to use in the CourseDataSource:

    func parseJSON(json:JSONValue) -> Course?
    {
        return json										//1
                >>- _Course.decodeObjects				//2
                >>- mapSome								//3
                >>- { $0.first }						//4
                >>- CourseAdapter(stack: stack).adapt	//5
    }
    
This entire parse function is simply performing a series of data transformations. Let's start at the top. Line 1 is the JSON parameter. The >>- operator is syntactic shorthand for the bind operation. It means "take the item on the left side, and if it's not nil, then pass it as a parameter to the function on the right." The \_Course.decodeObjects function takes a single parameter, and that is the json variable. The result of line 2 is passed into mapSome. Since decodeObjects returns [\_Course?]?, you'll want to remove any optionals from the result. mapSome does just that and returns a [\_Course]. Line 4 will take that nice filtered array, and return the first item in that array. Since we're expecting only 1 result from our API, this should always return an element. And finally, line 5 takes that single first element and coverts it to a Core Data object using the existing CourseAdapter class.


Time to get back to requesting course data. Add this function to the CourseDataSource class

    func requestCourse(id:Int, completion: (Course) -> ()) {

		let courseResource = jsonResource("courses", .GET, .JSONNull, parseJSON)
	}
	
The last parameter is the parseJSON function you just added. Since functions are first class citizens in swift, we can pass them around like this. This function will be used to convert the json to a Course Core Data object.

Next we'll need that API URL and start to fill that in. Add this to the requestCourse function.

    let baseURL = "https://api.coursera.org/api/catalog.v1/courses"
    let queryString = "id=\(id)&fields=largeIcon,smallIcon,shortDescription,aboutTheCourse"
	let courseURL = NSURL(string:"\(baseURL)?\(queryString)")!	

The id from the parameter will be used to query the proper course.
Finally, add this as the final line in the function:

	apiRequest({ _ in }, courseURL, courseResource, defaultFailureHandler) { course in
    	completion(Result(course))
	}

Data will now load from the network asyncronously. But we need to call this from somewhere with the proper course ID. Create this updateCourseDetails function in the CourseDataSource:

	func updateCourseDetails(completion:(Course?) -> ()) {
        let courseID = course?.remoteID.integerValue ?? 0
        let context = stack.mainContext
        requestCourse(courseID) { course in
            context.performBlock {
                completion(course)
            }
        }
    }

This function will grab the courseID from the course that was passed in as a parameter. After the course  has been downloaded, we can then call the completion block with the course. How does this get back to the UI?

Back in the CourseViewController, add a property for the courseDataSource.

	var courseDataSource : CourseDataSource?
	
Now, in the course property, we can connect the data source.

Change the course property to look like this:

	var course: Course? {
        didSet {
            if let course = course {
                courseDataSource = CourseDataSource(course:course)
                courseDataSource?.updateCourseDetails(configureView)
            }
        }
    }
    
Now, the configureView parameter is a reference to another function. This function matches the completion handler signature for the updateCourseDetails callback parameter, so this is allowed. Let's see what that function looks like:

    func configureView(course:Course?) {
        courseNameLabel?.text = course?.shortName
        courseDescriptionLabel?.text = course?.name
    }

Add this to the CourseDetailsViewController.

---
