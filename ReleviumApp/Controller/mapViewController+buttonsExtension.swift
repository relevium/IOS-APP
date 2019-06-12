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
        
        mainButton.translatesAutoresizingMaskIntoConstraints = false
        fireButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        emergencyButton.translatesAutoresizingMaskIntoConstraints = false
        
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        fireLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting buttons constraints
        mainButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20).isActive = true
        mainButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20).isActive = true
        mainButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        mainButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        fireButton.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor).isActive = true
        fireButton.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor).isActive = true
        fireButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        fireButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        locationButton.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor).isActive = true
        locationButton.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        locationButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        emergencyButton.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor).isActive = true
        emergencyButton.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor).isActive = true
        emergencyButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        emergencyButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        //setting label constraints
        mainLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        mainLabel.widthAnchor.constraint(equalToConstant: 140).isActive = true
        mainLabel.trailingAnchor.constraint(equalTo: mainButton.leadingAnchor, constant: -10).isActive = true
        mainLabel.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor).isActive = true

        fireLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        fireLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        fireLabel.trailingAnchor.constraint(equalTo: fireButton.leadingAnchor, constant: -10).isActive = true
        fireLabel.centerYAnchor.constraint(equalTo: fireButton.centerYAnchor).isActive = true

        warningLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        warningLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        warningLabel.trailingAnchor.constraint(equalTo: emergencyButton.leadingAnchor, constant: -10).isActive = true
        warningLabel.centerYAnchor.constraint(equalTo: emergencyButton.centerYAnchor).isActive = true

        locationLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        locationLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        locationLabel.trailingAnchor.constraint(equalTo: locationButton.leadingAnchor, constant: -10).isActive = true
        locationLabel.centerYAnchor.constraint(equalTo: locationButton.centerYAnchor).isActive = true

        fireButton.alpha =  0
        locationButton.alpha = 0
        emergencyButton.alpha = 0
        
        mainLabel.alpha = 0
        fireLabel.alpha = 0
        locationLabel.alpha = 0
        warningLabel.alpha = 0
        
        fireButton.transform = fireButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        locationButton.transform = locationButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        emergencyButton.transform = emergencyButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
    }
    
    internal func setButtonAtStartLocation(){
        fireButton.center = mainButton.center
        locationButton.center = mainButton.center
        emergencyButton.center = mainButton.center
        
        fireLabel.center.y = fireButton.center.y
        locationLabel.center.y = locationButton.center.y
        warningLabel.center.y = emergencyButton.center.y
        
        fireButton.alpha =  0
        locationButton.alpha = 0
        emergencyButton.alpha = 0
        
        mainLabel.alpha = 0
        fireLabel.alpha = 0
        locationLabel.alpha = 0
        warningLabel.alpha = 0
        
        mainButton.transform = mainButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        fireButton.transform = fireButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        locationButton.transform = locationButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        emergencyButton.transform = emergencyButton.transform.rotated(by: CGFloat(-Double.pi / 4.0))
        
    }
    
    internal func setButtonEndLocation(){
        fireButton.alpha = 1
        locationButton.alpha = 1
        emergencyButton.alpha = 1
        
        mainLabel.alpha = 1
        fireLabel.alpha = 1
        locationLabel.alpha = 1
        warningLabel.alpha = 1
        
        mainButton.transform = mainButton.transform.rotated(by: CGFloat(Double.pi / 4.0))
        fireButton.transform = fireButton.transform.rotated(by: CGFloat(Double.pi / 4.0))
        locationButton.transform = locationButton.transform.rotated(by: CGFloat(Double.pi / 4.0))
        emergencyButton.transform = emergencyButton.transform.rotated(by: CGFloat(Double.pi / 4.0))
        
        fireButton.center.y = mainButton.center.y - 110
        locationButton.center.y = mainButton.center.y - 55
        emergencyButton.center.y = mainButton.center.y - 165
        
        fireLabel.center.y = fireButton.center.y
        locationLabel.center.y = locationButton.center.y
        warningLabel.center.y = emergencyButton.center.y
    }
}
