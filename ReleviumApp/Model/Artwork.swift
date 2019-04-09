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
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.title = title
        super.init()
    }
}
