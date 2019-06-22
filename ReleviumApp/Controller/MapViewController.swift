//
//  MapViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 3/9/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
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
    private var currentLocation: CLLocationCoordinate2D?
    @IBOutlet weak var fireLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var fireButton: UIButton! // SOS
    @IBOutlet weak var locationButton: UIButton! // Warning
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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
            UIView.animate(withDuration: 0.4) {
                self.setButtonAtStartLocation()
            }
            isButtonVisible = false
            var glyphTitle:String = getTitle(tag: sender.tag)
            var describeTextField = UITextField()
            let glyphlocation = mapView.centerCoordinate
            let glyphId = UUID.init().uuidString
            guard let userId = Auth.auth().currentUser?.uid else {
                print("can not get UID while adding mark from button")
                return
            }
            let alert = UIAlertController(title: "Description", message: "set you mark desctription", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "enter description here"
                describeTextField = textField
            }
            let actionAccept = UIAlertAction(title: "Save", style: .default) { [unowned self](action) in
                if let description = describeTextField.text {
                    glyphTitle = description
                }
                self.uploadGeoLocation(location: CLLocation(latitude: glyphlocation.latitude, longitude: glyphlocation.longitude),
                                  id: glyphId, child: "GeoFirePingLocations")
                self.uploadPinDetails(glyphId: glyphId, userId: userId, tag: sender.tag, glyphTitle: glyphTitle)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(actionAccept)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
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
            if let value = snapshot.value{
                let glyphId = snapshot.key
                let json = JSON(value)
                let glyphTitle = json["mDescription"].stringValue
                let imageID = json["mImageId"].intValue
                
                geoFire.getLocationForKey(glyphId, withCallback: { [unowned self](location, error) in
                    if error == nil{
                        guard let coordinate = location?.coordinate else{ return }
                        if let glyphImage = self.getGlyph(tag: imageID){
                            let artwork = Artwork(title: glyphTitle, coordinate: coordinate,uid: glyphId,image: glyphImage,state: "glyph",anonymity: false)
                            self.mapView.addAnnotation(artwork)
                        } else {
                            print("failed to get glyph")
                        }
                    }
                })
            }
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
            return "did not set yet"
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
        print("location changed.......")
        currentLocation = location.coordinate
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
        
        let ref = Database.database().reference().child("Users").child(key)
        guard let logoImage = UIImage(named: "userImage") else{
            print("logo image do not exit on device")
            return
        }
        ref.observeSingleEvent(of: .value) { (snapshot) in
            
            if let value = snapshot.value {
                let json = JSON(value)
                // check if user has all info
                if let firstname = json["mFirstName"].string, let secondName = json["mLastName"].string, let state = json["userState"]["state"].string {
                    let name = "\(firstname) \(secondName)"
                    let anonymity = json["AnonymityPreference"].bool ?? false
                    if let imageURL = json["image"].string {
                        let storgeRef = Storage.storage().reference(forURL: imageURL)
                        storgeRef.getData(maxSize: 1 * 4000 * 4000, completion: { (data, err) in
                            if let data = data {
                                guard let userImage = UIImage(data: data) else {
                                    print("failed to generate image from data")
                                    return
                                }
                                self.createArtwork(title: name, location: location,userId: key,image: userImage,state: state,anonymity: anonymity)
                            } else {
                                print("failed to get user image from database")
                                return
                            }
                        })
                    } else {
                        // user did not set profile image yet
                        self.createArtwork(title: name, location: location,userId: key,image: logoImage,state: state,anonymity: anonymity)
                    }
                    
                } else {
                    print("invalid user info")
                }
            }
            else {
                // user not registered in user collection "garbage user"
                print("User dose not exist in Users *invalid user*")
            }
            
        }
    }
    
    private func createArtwork(title: String, location: CLLocation,userId: String, image: UIImage,state:String,anonymity:Bool) {
        
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let artwork = Artwork(title: title, coordinate: coordinate, uid: userId,image: image,state: state,anonymity: anonymity)
        
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
        guard let annotationUnwraped = annotation as? Artwork else {
            print("failed to unwwrap ARTWORK")
            return nil
        }
        var annotationView: MKAnnotationView
        let identifier = "marker"
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){
            dequeuedView.removeFromSuperview()
            let newAnnotation = MKAnnotationView(annotation: annotationUnwraped, reuseIdentifier: identifier)
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = #colorLiteral(red: 0.168627451, green: 0.262745098, blue: 0.3254901961, alpha: 0.75)
        renderer.lineWidth = 8.0
        return renderer
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        let latitute = mapView.centerCoordinate.latitude
        let longtitute = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitute, longitude: longtitute)
    }
    
    //MARK: - AnnotationView Helping Methods
   private func getGlyph(tag: Int) -> UIImage?{
        switch tag {
        case 3:
            return UIImage(named: "icons8-warning-shield-48")
        case 1:
            return UIImage(named: "icons8-safety-float-64")
        case 2:
            return UIImage(named: "icons8-tent-48")
        default:
            return nil
        }
    }
    
    private func addImageToAnnotationView(annatotationView:MKAnnotationView, artwork: Artwork) {
        
        guard let title = artwork.title else {
            print("invalid title in map")
            return
        }
        guard let uid = artwork.uid else {
            print("failed to get uid in addImageToAnnotationView")
            return
        }
        guard let image = artwork.image else {
            print("fialed to get image addImageToAnnotationView")
            return
        }
        guard let state = artwork.state else {
            print("failed to get state in addImageToAnnotationView")
            return
        }
        guard let anonymity = artwork.anonymity else {
            print("failed to get anonymity in addImageToAnnotationView")
            return
        }
        let location = artwork.coordinate
        
        annatotationView.canShowCallout = true
        if state == "glyph" {
            addGlyphToMap(annatotationView: annatotationView, name: title,uid: uid,image: image,location: location)
        }
        else if uid != getUserId() && state == "online" && anonymity == false {
            addUserImage(annatotationView: annatotationView, name: title,uid: uid,image: image,location: location)
        }
    }
    
    private func addGlyphToMap(annatotationView: MKAnnotationView,name: String, uid: String,image:UIImage, location:CLLocationCoordinate2D){
        let routeButton = UserOnMapButton(type: UIButton.ButtonType.custom)
        //Adding Route info to button....
        
        routeButton.sizeThatFits(CGSize(width: 10, height: 10))
        routeButton.translatesAutoresizingMaskIntoConstraints = false
        let imageButton = UIImage(named: "icons8-route-30")
        routeButton.imageRect(forContentRect: CGRect(x: 0, y: 0, width: 5, height: 5))
        routeButton.setImage(imageButton, for: .normal)
        routeButton.setTitle("\t Route To: \(name)", for: .normal)
        routeButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        routeButton.destinationCoordinate = location
        routeButton.addTarget(self, action: #selector(getRouteTo(sender:)), for: .touchUpInside)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.image = image
        annatotationView.layer.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        annatotationView.addSubview(imageView)
        annatotationView.layer.zPosition = 2
        annatotationView.conteiner(arrangedSubviews: [routeButton])
        
    }
    
    
    
    private func addUserImage(annatotationView: MKAnnotationView,name: String, uid: String,image:UIImage,location:CLLocationCoordinate2D) {
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
            let imageButton = UIImage(named: "icons8-send-email-48")
            button.imageRect(forContentRect: CGRect(x: 0, y: 0, width: 5, height: 5))
            button.setImage(imageButton, for: .normal)
            button.setTitle("\t message: \(name)", for: .normal)
            button.addTarget(self, action: #selector(goToChat(sender:)), for: .touchUpInside)
        
            let routeButton = UserOnMapButton(type: UIButton.ButtonType.custom)
            //Adding Route info info to button....
        
            routeButton.sizeThatFits(CGSize(width: 10, height: 10))
            routeButton.translatesAutoresizingMaskIntoConstraints = false
            routeButton.destinationCoordinate = location
            let imageRoute = UIImage(named: "icons8-route-30")
            routeButton.imageRect(forContentRect: CGRect(x: 0, y: 0, width: 5, height: 5))
            routeButton.setImage(imageRoute, for: .normal)
            routeButton.setTitle("\t Route To: \(name)", for: .normal)
            routeButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            routeButton.addTarget(self, action: #selector(getRouteTo(sender:)), for: .touchUpInside)
        
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 25
            imageView.layer.masksToBounds = true
            imageView.image = image
            annatotationView.layer.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            annatotationView.addSubview(imageView)
            annatotationView.layer.zPosition = 2
            annatotationView.conteiner(arrangedSubviews: [button,routeButton])
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
    
    @objc func getRouteTo(sender: UserOnMapButton) {
        guard let current = currentLocation else {
            print("can not retrieve current user location")
            return
        }
        guard let destination = sender.destinationCoordinate else {
            print("failed to get destination location")
            return
        }
        showRouteOnMap(pickupCoordinate: current, destinationCoordinate: destination)
        
    }
    
    private func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { [unowned self] (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
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
