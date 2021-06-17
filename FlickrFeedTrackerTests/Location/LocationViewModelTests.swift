import XCTest
import CoreLocation
@testable import FlickrFeedTracker

class LocationViewModelTest: XCTestCase {
    private var sut: LocationViewModel?
    private var service: MockedLocationService?

    override func setUpWithError() throws {
        service = MockedLocationService()
        sut = LocationViewModel(service: try XCTUnwrap(service))
    }

    func testRequestAuthorization_withDeny_shouldReturnOnDeny() {
        service?.authorization = .denied
        sut?.onDeny = {}
        sut?.onLocationUpdate = { _ in XCTFail("Expected onDeny. Got onLocationUpdate!") }
        sut?.onAuthorization = { XCTFail("Expected onDeny. Got onAuthorization!") }
        sut?.requestAuthorization()
        XCTAssertEqual(service?.counterRequestAlwaysAuthorization, 0)
    }

    func testRequestAuthorization_withAuth_shouldReturnOnAuthorization() {
        service?.authorization = .authorizedWhenInUse
        sut?.onDeny = { XCTFail("Expected onAuthorization. Got onDeny!") }
        sut?.onLocationUpdate = { _ in XCTFail("Expected onAuthorization. Got onLocationUpdate!") }
        sut?.onAuthorization = {}
        sut?.requestAuthorization()
        XCTAssertEqual(service?.counterRequestAlwaysAuthorization, 1)
    }

    func testStartTrack() {
        sut?.startTrack()
        XCTAssertEqual(service?.counterStartUpdatingLocation, 1)
    }

    func testDidChangeAuthorization_withAuthAlways_shouldOnAuthorize() {
        sut?.onDeny = { XCTFail("Expected onAuthorization. Got onDeny!") }
        sut?.locationServiceDidChangeAuthorization(.authorizedAlways)
    }

    func testDidChangeAuthorization_withAuthWhenInUse_shouldOnAuthorize() {
        sut?.onDeny = { XCTFail("Expected onAuthorization. Got onDeny!") }
        sut?.locationServiceDidChangeAuthorization(.authorizedWhenInUse)
    }

    func testDidChangeAuthorization_withDeny_shouldOnDeny() {
        sut?.onAuthorization = { XCTFail("Expected onDeny. Got onAuthorization!") }
        sut?.locationServiceDidChangeAuthorization(.denied)
    }

    func testDidChangeAuthorization_withNotDetermined_shouldOnDeny() {
        sut?.onAuthorization = { XCTFail("Expected onDeny. Got onAuthorization!") }
        sut?.locationServiceDidChangeAuthorization(.notDetermined)
    }

    func testDidUpdateLocation_withNoLastLocation() {
        let location = CLLocation.location1
        XCTAssertNil(sut?.lastLocation)
        sut?.locationService(location,
                             didUpdateLocations: [])
        XCTAssertNotNil(sut?.lastLocation)
        XCTAssertEqual(sut?.lastLocation?.coordinate.latitude, location.coordinate.latitude)
        XCTAssertEqual(sut?.lastLocation?.coordinate.longitude, location.coordinate.longitude)
    }

    func testDidUpdateLocation_withLocationLower100m_shouldUpdateLocation() {
        let location = CLLocation.location1
        sut?.locationService(location,
                             didUpdateLocations: [])
        let newLocation = CLLocation.location2

        sut?.onLocationUpdate = { _ in
            XCTFail("Don't expected onLocationUpdate!")
        }

        sut?.locationService(newLocation,
                             didUpdateLocations: [])
        XCTAssertNotNil(sut?.lastLocation)
        XCTAssertEqual(sut?.lastLocation?.coordinate.latitude, newLocation.coordinate.latitude)
        XCTAssertEqual(sut?.lastLocation?.coordinate.longitude, newLocation.coordinate.longitude)
    }

    func testDidUpdateLocation_withLocationGreater100m_shouldUpdateLocation() {
        let location = CLLocation.location1
        sut?.locationService(location,
                             didUpdateLocations: [])
        let newLocation = CLLocation.location3

        sut?.onLocationUpdate = {
            XCTAssertEqual($0.coordinate.latitude, newLocation.coordinate.latitude)
            XCTAssertEqual($0.coordinate.longitude, newLocation.coordinate.longitude)
        }

        sut?.locationService(newLocation,
                             didUpdateLocations: [])
        XCTAssertNotNil(sut?.lastLocation)
        XCTAssertEqual(sut?.lastLocation?.coordinate.latitude, newLocation.coordinate.latitude)
        XCTAssertEqual(sut?.lastLocation?.coordinate.longitude, newLocation.coordinate.longitude)
    }
}

private extension CLLocation {
    static var location1: CLLocation {
        CLLocation.init(latitude: 41.89246, longitude: 12.48532)
    }

    static var location2: CLLocation {
        CLLocation.init(latitude: 41.89246, longitude: 12.48532)
    }

    static var location3: CLLocation {
        CLLocation.init(latitude: 41.88747, longitude: 12.48504)
    }
}
