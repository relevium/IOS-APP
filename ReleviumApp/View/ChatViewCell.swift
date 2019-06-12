//
//  ChatViewCell.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/13/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class ChatViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
