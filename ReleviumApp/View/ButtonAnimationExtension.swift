//
//  ButtonAnimationExtension.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 4/9/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation
import UIKit

extension UIButton{
    
    func flash(){
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.1
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.autoreverses = true
        flash.repeatCount = 1
        
        layer.add(flash, forKey: nil)
    }
    
}
