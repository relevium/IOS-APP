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
        firstNameTextField.delegate = self
        secondNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        rePasswordTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchToEndEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func touchToEndEditing(){
        firstNameTextField.resignFirstResponder()
        secondNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        rePasswordTextField.resignFirstResponder()
    }
    
    @IBAction func registerButtonPressed(_ sender: ButtonLayout) {
        sender.flash()
        guard let firstName = firstNameTextField.text else { return }
        guard let lastName = secondNameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let password =  passwordTextField.text else { return }
        guard let rePassword = rePasswordTextField.text else { return }
        
        if verification.validateName(name: firstName) == false {
            verification.makeAlert(title: "Registration Failed", message: "please enter a valid name", mainView: self)
        }
        else if verification.validateName(name: lastName) == false {
            verification.makeAlert(title: "Registration Failed", message: "please enter a valid name", mainView: self)
        }
        else if verification.validateEmail(candidate: email) == false {
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
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (results, error) in
                guard let self = self else{
                    print("error call self in register after view deinitialized")
                    return
                }
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
                            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
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
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func createNewUser(firstName:String, lastName:String, email:String,complition: @escaping (Result<String,RegistrationError>) -> () ){
        let ref = Database.database().reference().child("Users")
        guard let userId = Auth.auth().currentUser?.uid else {
            //Failed to register
            complition(.failure(.failedToGetUserId))
            return
        }
        let date = verification.getDate()
        let time = verification.getTime()
        
        let userState = ["date":date,"state":"online","time":time]
        ref.child(userId).setValue(["mEmail":email, "mFirstName":firstName,"mLastName":lastName,"userState":userState]) { (error, reference) in
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

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        firstNameTextField.resignFirstResponder()
        secondNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        rePasswordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        firstNameTextField.resignFirstResponder()
        secondNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        rePasswordTextField.resignFirstResponder()
        return true
    }
}
