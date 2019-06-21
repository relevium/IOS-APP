//
//  Message.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/21/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation
import UIKit
struct  Message {
    
    private var image: UIImage?
    private var lastSeen: String?
    private var receriveID:String?
    private var receiverName:String?
    
    init(image: UIImage?, lastSeen: String,to:String,toName:String) {
        self.image = image
        self.lastSeen = lastSeen
        self.receriveID = to
        self.receiverName = toName
    }
    
    func getLastSeen()-> String{
        guard let unwrapedLastSeen = lastSeen else {return "N/A"}
        return unwrapedLastSeen
    }
    
    func getFriendImage()-> UIImage{
        guard let unwrapedImage = image else {
            return UIImage(named: "userImage")!
        }
        return unwrapedImage
    }
    
    func getToId() -> String {
        return receriveID ?? "receiver ID unavailable"
    }
    
    func getToName() -> String {
        return receiverName ?? "receiver name unavailable"
    }
    
}
