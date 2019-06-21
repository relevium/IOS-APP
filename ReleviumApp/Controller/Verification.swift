//
//  Verification.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/12/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class Verification {
    
    func makeAlert(title: String,message: String, mainView: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let acttion = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(acttion)
        mainView.present(alert, animated: true, completion: nil)
    }
    
    func validateName(name: String) -> Bool{
        let nameRegex = "^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$"
        return NSPredicate(format: "SELF MATCHES %@",nameRegex).evaluate(with: name)
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    func validatePassword(candidate: String) -> Bool {
        // password should has at least 8 characters with at least one uppercase, one lowercase, one digit, and one special character @#$&*
        let passwordRegex = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,64}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: candidate)
    }
    
    func getDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy a"
        return formatter.string(from: date)
    }
    
    func getTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        return formatter.string(from: date)
    }
    
    func getDateFromString(date:String, time:String) -> Date?{
        let dateString = "\(date) \(time)"
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy h:mm:ss a"
        return formatter.date(from: dateString)
    }
    
    func changeUserState(state: String,completion: @escaping (Result<String,RegistrationError>) -> ()){
        guard  let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("Users")
        let date = getDate()
        let time = getTime()
        
        let userState = ["date":date,"state":state,"time":time]
        ref.child(userId).child("userState").setValue(userState) { (error, reference) in
            if error != nil {
                completion(.failure(.failedToGetUserId))
            }
            else {
                completion(.success(time))
            }
        }
    }
}
