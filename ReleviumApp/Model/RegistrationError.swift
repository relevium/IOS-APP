//
//  ConnectionError.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/12/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation

enum RegistrationError: Error {
    case failedToCreateUser
    case failedToConnectToFB
    case failedToGetUserId
}
