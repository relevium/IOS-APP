//
//  DesignableTextField.swift
//  SoleekLabTask
//
//  Created by Ahmed Samir on 5/24/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

@IBDesignable

class DesignableTextField: UITextField {

    let lineView: UIView = UIView()
    
    @IBInspectable var leftImage: UIImage? {
        didSet{
            setleftImage()
        }
    }
    
    @IBInspectable var placeholderPosition: CGFloat = 0{
        didSet{

        }
    }
    
    @IBInspectable var placeholderColor: UIColor?{
        didSet{
            if let color = placeholderColor{
                attributedPlaceholder = NSAttributedString(string: placeholder != nil ? placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: color])
            }
            
        }
    }
    
    @IBInspectable var bottomLineColor: UIColor?{
        didSet{
            if let color = bottomLineColor{
                lineView.backgroundColor = color
                configureBottomBorder()
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureBottomBorder()
    }
    
    
    //MARK: - Configure the leftImage View
    private func setleftImage(){
        leftViewMode = .always
        let view = UIView()
        if let image = leftImage{
            let imageView = UIImageView(frame: CGRect(x: 0, y: frame.size.height * (-0.5), width: 25, height: 25))
            imageView.image = image
            view.addSubview(imageView)
        }
        leftView = view
        
    }
    
    //MARK: - Confiure The bottom Line for the textField
    private func configureBottomBorder(){
        addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
        lineView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

}
