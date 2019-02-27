//
//  ChatEntity.swift
//  ReleviumApp
//
//  Created by Ahmed Ahmed on 2/24/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation

struct ChatEntity{
    private var message:String = ""
    private var user: Bool = true
    
    init(message: String,isUser: Bool){
        self.message = message
        self.user = isUser
    }
    
    func getMessage() -> String{
        return message
    }
    func isUser() -> Bool {
        return user
    }
}
