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
    private var date: Date
    
    init(message: String,isUser: Bool){
        self.message = message
        self.user = isUser
        date = Date()
    }
    
    func getMessage() -> String{
        return message
    }
    
    func isUser() -> Bool {
        return user
    }
    
    func getDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy' - 'h:mm:ss a"
        return dateFormatter.string(from: date)
    }
    
}
