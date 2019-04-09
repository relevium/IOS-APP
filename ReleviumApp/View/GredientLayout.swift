//
//  LaunchScreenLayout.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 3/8/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class GredientLayout: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setGredientScreen()
    }
    
    func setGredientScreen(){
        let gl = CAGradientLayer()
        gl.frame = bounds
        gl.locations = [0.0,1.0]
        gl.startPoint = CGPoint(x: 1.0, y: 1.0)
        gl.endPoint = CGPoint(x: 0.0, y: 0.0)
        let topColor: UIColor = .black
        let botColor: UIColor = .red
        gl.colors = [topColor.cgColor,botColor.cgColor]
        
        layer.insertSublayer(gl, at: 0)
        
    }
    
}


