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
    
    
}
