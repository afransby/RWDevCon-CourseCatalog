##Core Data Threading Demo Instructions
---
In this demo, you will be adding some import functionality to download more data for the Course Catalog. Along the way, we will be adding support for downloading and importing in the background, as well as looking at how to unit test our Core Data importing code.

---

## Open the CourseCatalog.xcworkspace file
You'll see that this project uses Argo and Swell, and they are missing. We need to download those dependencies. (TODO: add these into the repo/solution if hotel interwebs are bad)

## Setup Project
This project uses the lightweight dependency management tool Carthage. A Cartfile with the proper dependencies is 

	carthage bootstrap
	
## Run project
We'll see that this UI is there, but there is no data

## Add data
Launch the data importing from local sample data

## make data import on background thread

## Make data not re-import on every launch