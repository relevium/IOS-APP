//
//  UserImageView.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/15/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class UserImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFill
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = #colorLiteral(red: 0.168627451, green: 0.262745098, blue: 0.3254901961, alpha: 1)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
