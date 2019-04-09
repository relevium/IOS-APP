//
//  ButtonLayout.swift
//  ReleviumApp
//
//  Created by Ahmed Ahmed on 2/27/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class ButtonLayout: UIButton{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton(){
        
        backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        titleLabel?.font = UIFont(name: "avenirNextCondensedDemiBold", size: 14)
        layer.cornerRadius = frame.size.height / 3
        setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
    }
    
}


