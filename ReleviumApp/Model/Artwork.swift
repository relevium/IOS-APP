//
//  Artwork.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 3/14/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import MapKit

class Artwork: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    let title: String?
    let uid: String?
    let image: UIImage?
    let state: String?
    let anonymity: Bool?
    
    init(title: String, coordinate: CLLocationCoordinate2D,uid: String,image: UIImage,state:String,anonymity:Bool) {
        self.coordinate = coordinate
        self.title = title
        self.uid = uid
        self.image = image
        self.state = state
        self.anonymity = anonymity
        super.init()
    }
}
