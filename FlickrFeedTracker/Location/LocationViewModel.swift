import Foundation
import CoreLocation

class LocationViewModel: NSObject {
    private let service: LocationProvider
    private(set) var lastLocation: CLLocation?

    var onLocationUpdate: (CLLocation) -> Void
    var onAuthorization: () -> Void
    var onDeny: () -> Void

    private lazy var didChangeAuthorization: [((CLAuthorizationStatus) -> Bool, () -> Void)] = [
        ({ $0 == .authorizedAlways }, { [weak self] in self?.onAuthorization() }),
        ({ $0 == .authorizedWhenInUse }, { [weak self] in self?.onAuthorization() }),
        ({ _ in true }, { [weak self] in self?.onDeny() }),
    ]
    private lazy var authorizationStatus: [(() -> Bool, () -> Void)] = [
        ({ [weak self] in self?.service.authorization == .denied }, { [weak self] in self?.onDeny() }),
        ({ true }, { [weak self] in self?.service.requestAlwaysAuthorization() }),
    ]

    init(service: LocationProvider = LocationService()) {
        self.service = service
        onLocationUpdate = { _ in }
        onAuthorization = {}
        onDeny = {}
    }

    func requestAuthorization() {
        authorizationStatus.first(where: { $0.0() })?.1()
    }

    func startTrack() {
        service.startUpdatingLocation()
    }
}

extension LocationViewModel: LocationViewModelDelegate {
    func locationService(_ location: CLLocation?, didUpdateLocations locations: [CLLocation]) {
        guard let last = lastLocation else {
            lastLocation = location
            return
        }
        
        location
            .filter { $0.distance(from: last).greaterThan100 }
            .map { onLocationUpdate($0) }
        lastLocation = location
    }

    func locationServiceDidChangeAuthorization(_ authorization: CLAuthorizationStatus) {
        didChangeAuthorization.first(where: { $0.0(authorization) })?.1()
    }
}

private extension CLLocationDistance {
    var greaterThan100: Bool {
        self > 100
    }
}
