//
//  Verification.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/12/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class Verification {
    
    func makeAlert(title: String,message: String, mainView: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let acttion = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(acttion)
        mainView.present(alert, animated: true, completion: nil)
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    func validatePassword(candidate: String) -> Bool {
        // password should has at least 8 characters with at least one uppercase, one lowercase, one digit, and one special character @#$&*
        let passwordRegex = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: candidate)
    }
}
