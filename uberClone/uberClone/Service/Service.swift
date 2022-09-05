//
//  Service.swift
//  uberClone
//
//  Created by Михаил Щербаков on 04.04.2022.
//

import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let USERS_REF = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
let REF_TRIPS = DB_REF.child("trips")


//MARK: DriverService


struct DriverService {
    
    static let shared = DriverService()
    
    func observeTrips(completion: @escaping(Trip) -> Void) {
        REF_TRIPS.observe(.childAdded) { snapshot in
            guard let dict = snapshot.value as? [String:Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dict: dict)
            completion(trip)
        }
    }
    
    func observeTripCancelled(trip: Trip, completion: @escaping() -> Void) {
        REF_TRIPS.child(trip.passengerUid).observe(.childRemoved) { _ in
            completion()
        }
    }
    
    func acceptTrip(trip: Trip, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = ["driverUid": uid,
                      "state": TripState.accepted.rawValue] as [String : Any]
        
        REF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func updateTripState(trip: Trip, state: TripState, completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_TRIPS.child(trip.passengerUid).child("state").setValue(state.rawValue, withCompletionBlock: completion)
        
        if state == .completed {
            REF_TRIPS.child(trip.passengerUid).removeAllObservers()
        }
    }
    
    func updateDriverLocation(location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        geoFire.setLocation(location, forKey: uid)
    }
}

//MARK: PassengerService

struct PassengerService {
    
    static let shared = PassengerService()
    
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                Service.shared.fetchUserData(uid: uid) { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    
    func uploadTrip(_ pickupCoordinate: CLLocationCoordinate2D,
                    _ destinationCoordinate: CLLocationCoordinate2D,
                    completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let pickupArray = [pickupCoordinate.latitude, pickupCoordinate.longitude]
        let destinationArray = [destinationCoordinate.latitude, destinationCoordinate.longitude]
        
        let values = ["pickupCoordinates":  pickupArray,
                      "destinationCoordinates": destinationArray,
                      "state": TripState.requested.rawValue] as [String : Any]
        
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func observeCurrentTrip(completion: @escaping(Trip) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_TRIPS.child(uid).observe(.value) { (snap) in
            guard let dict = snap.value as? [String: Any] else { return }
            let trip = Trip(passengerUid: uid, dict: dict)
            completion(trip)
        }
    }
    
    func deleteTrip(completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_TRIPS.child(uid).removeValue(completionBlock: completion)
    }
    
    func saveLocation(locationString: String, type: LocationType, completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let key: String = type == .home ? "homeLocation" : "workLocation"
        USERS_REF.child(uid).child(key).setValue(locationString, withCompletionBlock: completion)
    }
}

//MARK: SharedService

struct Service {
    
    static let shared = Service()
    
    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        USERS_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String:Any] else { return }
            let uid = snapshot.key
            let user = User(uid: uid,dict: dict)
            print(user.email)
            completion(user)
        }
    }
    
    
    
}
