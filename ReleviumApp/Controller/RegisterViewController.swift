//
//  RegisterViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 3/2/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController{
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var secondNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    let verification = Verification()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func registerButtonPressed(_ sender: ButtonLayout) {
        sender.flash()
        guard let firstName = firstNameTextField.text else { return }
        guard let lastName = secondNameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let password =  passwordTextField.text else { return }
        guard let rePassword = rePasswordTextField.text else { return }
        
        if verification.validateEmail(candidate: email) == false {
            verification.makeAlert(title: "Registration Failed", message: "Please enter a valid email", mainView: self)
            return
        }
        else if verification.validatePassword(candidate: password) == false {
            verification.makeAlert(title: "Registration Failed", message: "password should has at least 8 characters with at least one uppercase, one lowercase, one digit, and one special character @#$&*", mainView: self)
            return
        }
        else if password != rePassword {
            verification.makeAlert(title: "Registration Failed", message: "passwords dose not match", mainView: self)
            return
        }
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: email, password: password) { [unowned self] (results, error) in
                if error != nil {
                    SVProgressHUD.dismiss()
                    self.verification.makeAlert(title: "Connection", message: "Failed to Create Account please try again", mainView: self)
                    
                }
                else {
                    self.createNewUser(firstName: firstName,lastName: lastName , email: email ) { res in
                        switch res {
                            
                        case .success(let id):
                            print("Succeed to create user: \(id)")
                            SVProgressHUD.dismiss()
                            self.performSegue(withIdentifier: "registerToMain", sender: self)
                            
                        case .failure(let err):
                            Auth.auth().currentUser?.delete(completion: { (error) in
                                if error != nil {
                                    print("failed to delete user: \(error.debugDescription)")
                                }
                            })
                            SVProgressHUD.dismiss()
                            print("failed to create user: \(err)")
                        }
                    }
                }
            }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func createNewUser(firstName:String, lastName:String, email:String,complition: @escaping (Result<String,RegistrationError>) -> () ){
        let ref = Database.database().reference().child("Users")
        guard let userId = Auth.auth().currentUser?.uid else {
            //Failed to register
            complition(.failure(.failedToGetUserId))
            return
        }
        
        ref.child(userId).setValue(["mEmail":email, "mFirstName":firstName,"mLastName":lastName]) { (error, reference) in
            if error != nil {
                //Failed to register
                complition(.failure(.failedToCreateUser))
            }
            else {
                // Failed to register
                complition(.success(userId))
            }
        }
    }
    
}
