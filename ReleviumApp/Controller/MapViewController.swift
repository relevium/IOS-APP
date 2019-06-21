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
import SwiftyJSON


class MapViewController: UIViewController {

    private let locationManager = CLLocationManager()
    private let regionInMeters:Double = 1000
    private var isButtonVisible = false
    private var receiverID:String?
    private var receiverName: String?
    private var senderID: String?
    private var senderName: String?
    private var usersArtwork: [String : Artwork] = [:]
    @IBOutlet weak var fireLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var fireButton: UIButton! // SOS
    @IBOutlet weak var locationButton: UIButton! // Warning
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem.imageInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
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
                    let artwork = Artwork(title: title, coordinate: coordinate,uid: "",state: "")
                    self.mapView.addAnnotation(artwork)
                }
            })
        }
    }
    
    func getTitle(tag: Int) -> String{
        switch tag {
        case 1:
            return "User in Danger!"
        case 2:
            return "Shelter"
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
    
    //MARK: - Setting Info on Chat View
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat" {
            if let vc = segue.destination as? ChatViewController {
                vc.senderID = self.senderID
                vc.senderName = self.senderName
                vc.receiverID = self.receiverID
                vc.receiverName = self.receiverName
                if let parentView = self.parent as? EntryViewController {
                    vc.delegate = parentView
                }
            }
        }
    }
    
}

//MARK: - CoreLocation Delegate Extension
extension MapViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{ return }
        guard let userID = getUserId() else { return }
        print("=============location changed.......")
        uploadGeoLocation(location: location, id: userID,child: "User-Location")
        showOtherUsersWithinRadius(center: location, radius: 100.0)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func uploadGeoLocation(location: CLLocation, id:String, child: String){
        let geofireRef = Database.database().reference().child(child)
        let geoFire = GeoFire(firebaseRef: geofireRef)
        
        geoFire.setLocation(location, forKey: id)
    }
    
    func showOtherUsersWithinRadius(center:CLLocation, radius: Double){
        let geofireRef = Database.database().reference().child("User-Location")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        let queryCircle = geoFire.query(at: center, withRadius: radius)
        
        queryCircle.observe(.keyEntered) { [unowned self] (key, location) in
            
            self.addUserToMap(key: key, location: location)
        }
    }
    
    private func getUserId() -> String? {
        if let userId = Auth.auth().currentUser?.uid{
            return "\(userId)"
        }
        else {
            return nil
        }
    }
    
    private func addUserToMap(key: String, location: CLLocation) {
        
        let ref = Database.database().reference().child("Users")
        ref.child(key).observeSingleEvent(of: .value) { (snapshot) in
            
            if let value = snapshot.value {
                let json = JSON(value)
                // check if user has all info
                if let firstname = json["mFirstName"].string, let secondName = json["mLastName"].string, let state = json["userState"]["state"].string {
                    let name = "\(firstname) \(secondName)"
                    self.createArtwork(title: name, location: location,userId: key,state: state)
                }
                else{
                    // insuffcient user information
                    print("user info not complete ")
                }
            }
            else {
                // user not registered in user collection "garbage user"
                print("User dose not exist in Users *invalid user*")
            }
            
        }
    }
    
    private func createArtwork(title: String, location: CLLocation,userId: String, state: String) {
        
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let artwork = Artwork(title: title, coordinate: coordinate, uid: userId, state: state)
        
        if let oldArtwork = usersArtwork[userId] {
            // user found -- user already added to map -> update user location on map
            if isLocationChanged(location: location, artwork: oldArtwork) {
                
                usersArtwork.updateValue(artwork, forKey: userId)
                mapView.removeAnnotation(oldArtwork)
                mapView.addAnnotation(artwork)
            }
        }
        else {
            // user not found -- user not added to map -> Add user location on map
            usersArtwork.updateValue(artwork, forKey: userId)
            mapView.addAnnotation(artwork)
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
        guard let annotationUnwraped = annotation as? Artwork else { return nil }
        var annotationView: MKAnnotationView
        let identifier = "marker"
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){
            dequeuedView.removeFromSuperview()
            let newAnnotation = MKAnnotationView(annotation: annotationUnwraped, reuseIdentifier: identifier)
            newAnnotation.annotation = annotationUnwraped
            addImageToAnnotationView(annatotationView: newAnnotation, artwork: annotationUnwraped)
            annotationView = newAnnotation
            
        }
            
        else{
            annotationView = MKAnnotationView(annotation: annotationUnwraped, reuseIdentifier: identifier)
            addImageToAnnotationView(annatotationView: annotationView, artwork: annotationUnwraped)
            annotationView.centerOffset = CGPoint(x: 0, y: -50)
            
        }
        return annotationView
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        let latitute = mapView.centerCoordinate.latitude
        let longtitute = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitute, longitude: longtitute)
    }
    
    //MARK: - AnnotationView Helping Methods
   private func getGlyph(title: String) -> UIImage?{
        switch title {
        case "Warning!":
            return UIImage(named: "icons8-warning-shield-48")
        case "User in Danger!":
            return UIImage(named: "icons8-safety-float-64")
        case "Shelter":
            return UIImage(named: "icons8-tent-48")
        default:
            return nil
        }
    }
    
    private func addImageToAnnotationView(annatotationView:MKAnnotationView, artwork: Artwork) {
        
        guard let title = artwork.title else{ return }
        guard let state = artwork.state else{ return }
        guard let uid = artwork.uid else { return }
        annatotationView.canShowCallout = true

        
        if  state == "online" && uid != getUserId() {
            addUserImage(annatotationView: annatotationView, name: title, state: state,uid: uid)
        } else {
            if let glyph = getGlyph(title: title){
                annatotationView.image = glyph
            }
        }
    }
    
    private func addUserImage(annatotationView: MKAnnotationView,name: String,state:String, uid: String) {
            guard let currentUser = getUserId() else {
                print("failed to get current user")
                return
            }
            guard let currenUserArtwork = usersArtwork[currentUser] else {
                print("failed to get current user artwork")
                return
            }
        
            let button = UserOnMapButton(type: UIButton.ButtonType.system)
            //Adding call info to button....
            button.currentUserID = currenUserArtwork.uid
            button.currentUserName = currenUserArtwork.title
            button.receiverID = uid
            button.receivername = name
            button.sizeThatFits(CGSize(width: 10, height: 10))
            button.translatesAutoresizingMaskIntoConstraints = false
            let image = UIImage(named: "icons8-send-email-48")
            button.imageRect(forContentRect: CGRect(x: 0, y: 0, width: 5, height: 5))
            button.setImage(image, for: .normal)
            button.setTitle("\t message: \(name)", for: .normal)
            button.addTarget(self, action: #selector(goToChat(sender:)), for: .touchUpInside)
            
            annatotationView.layer.cornerRadius = annatotationView.layer.frame.height / 3
            annatotationView.contentMode = .scaleToFill
            annatotationView.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
            annatotationView.image = UIImage(named: "icons8-user-20")
            annatotationView.conteiner(arrangedSubviews: [button])
    }
    
    @objc private func goToChat(sender: UserOnMapButton){
        guard let senderName = sender.currentUserName else { return }
        guard let senderId = sender.currentUserID else { return }
        guard let receiverName = sender.receivername else { return }
        guard let receiverId = sender.receiverID else { return }
        
        self.senderID = senderId
        self.senderName = senderName
        self.receiverID = receiverId
        self.receiverName = receiverName
        performSegue(withIdentifier: "goToChat", sender: self)
       
    }
    
}

// Annotation View StackView Extension
extension MKAnnotationView {
    
    func conteiner(arrangedSubviews: [UIView]) {
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 3
        stackView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.detailCalloutAccessoryView = stackView
    }
}
