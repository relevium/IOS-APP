//
//  BloodType.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/20/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation

struct BloodType {
    let bloodType = ["A+","A-","B+","B-","O+","O-","AB+","AB-"]
    
    func getNumberOfTypes() -> Int {
        return bloodType.count
    }
    
    func getTypeAtIndex(index: Int) -> String {
        return bloodType[index]
    }
    
    func getBloodTypeIndex(type: String) -> Int {
        var bloodIndex = 0
        
        for i in 0..<bloodType.count {
            if bloodType[i] == type {
                bloodIndex = i
                break
            }
        }
        return bloodIndex
    }
}
