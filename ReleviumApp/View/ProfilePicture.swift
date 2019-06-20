//
//  ProfilePicture.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/19/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

@IBDesignable
class ProfilePicture: UIImageView {
    
    @IBInspectable var corner: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = corner
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func flash(){
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.3
        animation.fromValue = 1
        animation.toValue = 0.3
        animation.repeatCount = 1
        animation.autoreverses = true
        layer.add(animation, forKey: nil)
        
    }
    
    
}
