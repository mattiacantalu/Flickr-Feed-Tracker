import XCTest
@testable import FlickrFeedTracker

class FilterTests: XCTestCase {
    func test_filter_withOptionalSome_andPredicateTrue_shouldReturnOptionalSome() {
        let optional: String? = "optional"
        let functions = MockedFunctions()
        
        let result = optional.filter(functions.functionFilterReturningTrue)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(functions.counterFunctionFilterReturningTrue, 1)
    }
    
    func test_filter_withOptionalSome_andPredicateFalse_shouldReturnOptionalNone() {
        let optional: String? = "optional"
        let functions = MockedFunctions()
        
        let result = optional.filter(functions.functionFilterReturningFalse)
        
        XCTAssertNil(result)
        XCTAssertEqual(functions.counterFunctionFilterReturningFalse, 1)
    }
    
    func test_filter_withOptionalNone_andPredicateTrue_shouldReturnOptionalNone() {
        let optional: String? = nil
        let functions = MockedFunctions()
        
        let result = optional.filter(functions.functionFilterReturningTrue)
        
        XCTAssertNil(result)
        XCTAssertEqual(functions.counterFunctionFilterReturningTrue, 0)
    }
    
    func test_filter_withOptionalNone_andPredicateFalse_shouldReturnOptionalNone() {
        let optional: String? = nil
        let functions = MockedFunctions()
        
        let result = optional.filter(functions.functionFilterReturningFalse)
        
        XCTAssertNil(result)
        XCTAssertEqual(functions.counterFunctionFilterReturningFalse, 0)
    }
}
