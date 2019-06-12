//
//  mapViewController+buttonsExtension.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/12/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

extension MapViewController{
    
    //MARK: - button Animation location Functions
    
    internal func buttonsInitialPositions(){
        
        fireButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        emergencyButton.translatesAutoresizingMaskIntoConstraints = false
        fireButton.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor).isActive = true
        fireButton.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor).isActive = true
        locationButton.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor).isActive = true
        locationButton.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor).isActive = true
        emergencyButton.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor).isActive = true
        emergencyButton.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor).isActive = true
        
        fireButton.alpha =  0
        locationButton.alpha = 0
        emergencyButton.alpha = 0
        
        fireButton.transform = fireButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        locationButton.transform = locationButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        emergencyButton.transform = emergencyButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
    }
    internal func setButtonAtStartLocation(){
        fireButton.center = mainButton.center
        locationButton.center = mainButton.center
        emergencyButton.center = mainButton.center
        
        fireButton.alpha =  0
        locationButton.alpha = 0
        emergencyButton.alpha = 0
        
        mainButton.transform = mainButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        fireButton.transform = fireButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        locationButton.transform = locationButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        emergencyButton.transform = emergencyButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        
    }
    
    internal func setButtonEndLocation(){
        fireButton.alpha = 1
        locationButton.alpha = 1
        emergencyButton.alpha = 1
        
        mainButton.transform = mainButton.transform.rotated(by: CGFloat(Double.pi / 4.0))
        fireButton.transform = fireButton.transform.rotated(by: CGFloat(Double.pi / 4.0))
        locationButton.transform = locationButton.transform.rotated(by: CGFloat(Double.pi / 4.0))
        emergencyButton.transform = emergencyButton.transform.rotated(by: CGFloat(Double.pi / 4.0))
        
        fireButton.center.y = mainButton.center.y - 110
        locationButton.center.y = mainButton.center.y - 55
        emergencyButton.center.y = mainButton.center.y - 165
    }
}
