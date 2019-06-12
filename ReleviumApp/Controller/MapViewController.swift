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

    private let locationManager = CLLocationManager()
    private let regionInMeters:Double = 1000
    private var isButtonVisible = false
    private var usersArtwork: [String : Artwork] = [:]
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var fireLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var emergencyButton: UIButton!
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonsInitialPositions()
        checkLocationService()
        downloadPins()
    }
    
    //MARK: - ADD Emergency Pin to map
    @IBAction func addToMapButtonPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            //make some cool animation
            if isButtonVisible == true {
                UIView.animate(withDuration: 0.4) {
                    self.setButtonAtStartLocation()
                }
                isButtonVisible = false
            }
            else {
                UIView.animate(withDuration: 0.4){
                    self.setButtonEndLocation()
                }
                isButtonVisible = true
            }
            
        }
        else {
            let glyphtitle = getTitle(tag: sender.tag)
            let glyphlocation = mapView.centerCoordinate
            let glyphId = UUID.init().uuidString
            let userId = Auth.auth().currentUser?.uid ?? ""
            uploadGeoLocation(location: CLLocation(latitude: glyphlocation.latitude, longitude: glyphlocation.longitude),
                              id: glyphId, child: "GeoFirePingLocations")
            uploadPinDetails(glyphId: glyphId, userId: userId, tag: sender.tag, glyphTitle: glyphtitle)
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
        
        pinqDetails.observe(.childAdded) { [unowned self] (snapshot) in
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
        @unknown default:
            SVProgressHUD.showError(withStatus: "Location Authrization Error")
            SVProgressHUD.dismiss(withDelay: 0.5)
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
            
            self.addUserToMap(key: key, location: location)
        }
    }
    
    private func getUserId() -> String{
        if let userId = Auth.auth().currentUser?.uid{
            return "\(userId)"
        }
        else {
            return "ID unavailable"
        }
    }
    
    private func addUserToMap(key: String, location: CLLocation) {
        let artwork = Artwork(title: key, coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        
        if let oldArtwork = usersArtwork[key] {
            // user found -- user already added to map -> update user location on map
            if isLocationChanged(location: location, artwork: oldArtwork) {
                
                usersArtwork.updateValue(artwork, forKey: key)
                mapView.removeAnnotation(oldArtwork)
                mapView.addAnnotation(artwork)
                print("location updated for user with Key: \(key) | location: \(location)")
            }
        }
        else {
           // user not found -- user not added to map -> Add user location on map
            usersArtwork.updateValue(artwork, forKey: key)
            mapView.addAnnotation(artwork)
            print("new user add to map with Key: \(key) | location: \(location)")
        }
    }
    private func isLocationChanged(location: CLLocation, artwork: Artwork) -> Bool {
        let oldLocation = CLLocation(latitude: artwork.coordinate.latitude, longitude: artwork.coordinate.longitude)
        return location != oldLocation ? true : false
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
