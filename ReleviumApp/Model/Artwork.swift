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
    let state: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D,uid: String, state:String) {
        self.coordinate = coordinate
        self.title = title
        self.uid = uid
        self.state = state
        super.init()
    }
}
