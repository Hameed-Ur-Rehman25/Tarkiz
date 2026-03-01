import Foundation
import CoreLocation
import SwiftUI
import Combine
import MapKit

/// Manages location permissions, GPS coordinates, and reverse geocoding.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var fetchedCity: String?
    @Published var fetchedCountry: String?
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var isFetching: Bool = false

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// Requests "When In Use" location authorization and starts fetching location.
    func requestPermission() {
        isFetching = true
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()

        // Publish raw coordinates immediately
        DispatchQueue.main.async {
            self.latitude  = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }

        // Reverse geocode
        if let request = MKReverseGeocodingRequest(location: location) {
            request.getMapItems { [weak self] mapItems, _ in
                DispatchQueue.main.async {
                    self?.isFetching = false
                    if let placemark = mapItems?.first?.placemark {
                        self?.fetchedCity    = placemark.locality
                                           ?? placemark.subAdministrativeArea
                                           ?? placemark.administrativeArea
                                           ?? "Unknown City"
                        self?.fetchedCountry = placemark.country ?? "Unknown Country"
                    }
                }
            }
        } else {
            DispatchQueue.main.async { self.isFetching = false }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { self.isFetching = false }
    }
}
