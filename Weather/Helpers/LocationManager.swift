//
//  LocationManager.swift
//  Weather
//
//  Created by Jason Jacob on 8/10/23.
// Manager/Helper class to deal with location services

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate {
    // Instantiate locationManager object
       fileprivate let locationManager = CLLocationManager()
    // Published tuple property to hold coordinate value along with a status
        @Published var coordinates: (status: Bool, latitude: Double, longitude: Double)?
        // MARK: setup and enquire the user permission status for location services
        func setupManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
    }

    // MARK: Delegate method which returns the current location coordinate details
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude: Double = location.coordinate.latitude
            let longitude: Double = location.coordinate.longitude
            self.coordinates = (true, latitude, longitude)
        }
    }

    // MARK: Delegate method which gets called when coordinates cant be found
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Cant find the location") // Use for remote logging like splunk
        self.coordinates = (false, 0.0, 0.0)
    }

    // MARK: Delegate method which checks for user authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if [CLAuthorizationStatus.authorizedAlways,
        CLAuthorizationStatus.authorizedWhenInUse].contains(manager.authorizationStatus) {
            // We are requesting location data only once so making use of requestLocation method
            locationManager.requestLocation()
        } else {
            print("location preferences doesn't have always and in use permission")
            // Use for remote logging like splunk
        }
    }

    // MARK: Convinience method to check for location service authorization status
    func locationPermissionStatus() -> Bool {
    if [CLAuthorizationStatus.authorizedAlways,
        CLAuthorizationStatus.authorizedWhenInUse].contains(locationManager.authorizationStatus) {
            return true
        }
        return false
    }
}
