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
    var userOldAnnotation:MKAnnotation?
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationService()
        downloadPins()
    }
    
    //MARK: - ADD Emergency Pin to map
    @IBAction func addToMapButtonPressed(_ sender: UIButton) {
        let glyphtitle = getTitle(tag: sender.tag)
        let glyphlocation = mapView.centerCoordinate
        let glyphId = UUID.init().uuidString
        let userId = Auth.auth().currentUser?.uid ?? ""
        uploadGeoLocation(location: CLLocation(latitude: glyphlocation.latitude, longitude: glyphlocation.longitude),
                          id: glyphId, child: "GeoFirePingLocations")
        uploadPinDetails(glyphId: glyphId, userId: userId, tag: sender.tag, glyphTitle: glyphtitle)
    }
    
    func getTitle(tag: Int) -> String{
        switch tag {
        case 1:
            return "Pin Location"
        case 2:
            return "Fire!"
        case 3:
            return "Warning!"
        default:
            return "Undefined"
        }
    }
    
    func uploadPinDetails(glyphId:String, userId: String, tag: Int, glyphTitle: String){
        let pingDetails = Database.database().reference().child("Ping-Details")
        pingDetails.child(glyphId).setValue(["mDescription":glyphTitle,"mImageId":tag, "mUserID": userId])
    }
    
    func downloadPins(){
        let pinqDetails = Database.database().reference().child("Ping-Details")
        let geoFirePingLocation = Database.database().reference().child("GeoFirePingLocations")
        let geoFire = GeoFire(firebaseRef: geoFirePingLocation)
        
        pinqDetails.observe(.childAdded) { [unowned self](snapshot) in
            guard let value = snapshot.value as? NSDictionary else {return}
            let glyphId = snapshot.key
            let glyphTitle = value["mDescription"] as? String
            geoFire.getLocationForKey(glyphId, withCallback: { (location, error) in
                if error == nil{
                    guard let title = glyphTitle else {return}
                    guard let coordinate = location?.coordinate else{return}
                    let artwork = Artwork(title: title, coordinate: coordinate)
                    self.mapView.addAnnotation(artwork)
                }
            })
        }
    }
    
    //MARK: - Preparing MapView and location Services
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
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
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
}

//MARK: - CoreLocation Delegate Extension
extension MapViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{ return }
        print("location changed.......")
        uploadGeoLocation(location: location, id: getUserId(),child: "User-Location")
        showOtherUsersWithinRadius(center: location, radius: 5.0)
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func uploadGeoLocation(location: CLLocation, id:String, child: String){
        let geofireRef = Database.database().reference().child(child)
        let geoFire = GeoFire(firebaseRef: geofireRef)
        
        geoFire.setLocation(location, forKey: id)
    }
    
    func showOtherUsersWithinRadius(center:CLLocation,radius: Double){
        let geofireRef = Database.database().reference().child("User-Location")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        let queryCircle = geoFire.query(at: center, withRadius: radius)
        
        queryCircle.observe(.keyEntered) { [unowned self](key, location) in
            let artwork = Artwork(title: key, coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            if let userAnnotation = self.userOldAnnotation {
                self.mapView.removeAnnotation(userAnnotation)
            }
            self.mapView.addAnnotation(artwork)
            self.userOldAnnotation = artwork
            print("Key: \(key) | location: \(location)")
            
        }
    }
    
    func getUserId() -> String{
        if let userId = Auth.auth().currentUser?.uid{
            return "\(userId)"
        }
        else {
            return "ID unavailable"
        }
    }
    
}

//MARK: - MapKit Delegate extension
extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotationUnwraped = annotation as? Artwork else{return nil}
        var annotationView: MKAnnotationView
        let identifier = "marker"
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){
            dequeuedView.annotation = annotationUnwraped
            dequeuedView.image = getGlyph(title: annotationUnwraped.title ?? "")
            annotationView = dequeuedView
            
        }
        else{
            annotationView = MKAnnotationView(annotation: annotationUnwraped, reuseIdentifier: identifier)
            annotationView.image = getGlyph(title: annotationUnwraped.title ?? "")
            annotationView.centerOffset = CGPoint(x: 0, y: -50)
            annotationView.canShowCallout = true
            
        }
        return annotationView
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        let latitute = mapView.centerCoordinate.latitude
        let longtitute = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitute, longitude: longtitute)
    }
    
    func getGlyph(title: String) -> UIImage?{
        switch title {
        case "Warning!":
            return UIImage(named: "warning")
        case "Fire!":
            return UIImage(named: "fire")
        case "Pin Location":
            return UIImage(named: "location")
        default:
            return UIImage(named: "userOnMap")
        }
    }
}
