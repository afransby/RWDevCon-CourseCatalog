import Quick
import Nimble
import CourseCatalog

class CatalogDataSourceSpecs: QuickSpec {
    override func spec() {

        describe("importing") {

            
            beforeSuite {
                let testContent = Fixtures().jsonContent(Named: "Courses.json")
            }
        }
    }
}

struct Fixtures
{
    func jsonContent(Named fileName:String) -> NSDictionary? {

        let bundle = NSBundle(identifier: "com.magicalpanda.CourseCatalogTests")
        let fileURL = bundle?.URLForResource(fileName.stringByDeletingPathExtension, withExtension: fileName.pathExtension)
        let inputStream = NSInputStream(URL: fileURL!)!
        return NSJSONSerialization.JSONObjectWithStream(inputStream, options: nil, error: nil) as NSDictionary?
    }
}