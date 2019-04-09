//
//  MapViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 3/9/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import GeoFire
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    let locationManager = CLLocationManager()
    let regionInMeters:Double = 1000
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationService()
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationService(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }
        else{
            SVProgressHUD.showError(withStatus: "please Allow location Service from setting")
            SVProgressHUD.dismiss(withDelay: 0.5)
        }
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            centerViewOnUserLocation()
            break
        case .denied:
            SVProgressHUD.showError(withStatus: "Access denied")
            SVProgressHUD.dismiss(withDelay: 0.5)
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            SVProgressHUD.showError(withStatus: "Access restricted")
            SVProgressHUD.dismiss(withDelay: 0.5)
            break
        case .authorizedAlways:
            break
        }
    }
    
    func getUserName() -> String{
        if let userId = Auth.auth().currentUser?.email{
            print(userId)
            return "userName: \(userId.dropLast(5))"
        }
        else {
            return "username: unavailable"
        }
    }
    

}

extension MapViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{ return }
        uploadUserLocation(location: location, userName: getUserName())
        showOtherUsersWithinRadius(center: location, radius: 5.0)
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func uploadUserLocation(location: CLLocation, userName:String){
        let geofireRef = Database.database().reference().child("users-location")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        
        geoFire.setLocation(location, forKey: userName)
    }
    
    func showOtherUsersWithinRadius(center:CLLocation,radius: Double){
        let geofireRef = Database.database().reference().child("users-location")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        let queryCircle = geoFire.query(at: center, withRadius: radius)
        
        queryCircle.observe(.keyEntered) { (key, location) in
            let artwork = Artwork(title: key, coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            self.mapView.addAnnotation(artwork)
            print("Key: \(key) | location: \(location)")
            
        }
    }
}

extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotationUnwraped = annotation as? Artwork else{return nil}
        var annotationView: MKMarkerAnnotationView
        let identifier = "marker"
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView{
            dequeuedView.annotation = annotationUnwraped
            annotationView = dequeuedView
        }
        else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            annotationView.calloutOffset = CGPoint(x: -5, y: 5)
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return annotationView
    }
}
