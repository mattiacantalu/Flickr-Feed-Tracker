import XCTest
@testable import FlickrFeedTracker

class MockedFunctions {
    var counterFunctionInputString: Int = 0
    var counterFunctionDefault: Int = 0
    var counterFunctionFilterReturningFalse: Int = 0
    var counterFunctionFilterReturningTrue: Int = 0

    func getFiveIfInputIsTest(_ input: String) -> Int {
        if input == "test" {
            return 5
        }
        return 42
    }

    func getFour() -> Int {
        4
    }

    func functionInputString(_ some: String) {
        counterFunctionInputString += 1
    }

    func functionDefault() {
        counterFunctionDefault += 1
    }

    func functionFilterReturningFalse(_: String) -> Bool {
        counterFunctionFilterReturningFalse += 1
        return false
    }

    func functionFilterReturningTrue(_: String) -> Bool {
        counterFunctionFilterReturningTrue += 1
        return true
    }
}
