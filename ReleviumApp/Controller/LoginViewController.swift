//
//  LoginViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 3/2/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    private let verification = Verification()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)

        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    @objc func viewTapped(){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func loginButtonPressed(_ sender: ButtonLayout) {
        sender.flash()
        if let email = emailTextField.text, let password =  passwordTextField.text {
            
            if verification.validateEmail(candidate: email) == false || verification.validatePassword(candidate: password) == false {
                verification.makeAlert(title: "Login Failed", message: "Wrong email or password", mainView: self)
                return
            }
            
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: email, password: password) { [unowned self](results, error) in
                if error != nil {
                    SVProgressHUD.dismiss()
                    self.verification.makeAlert(title: "Login Failed", message: "Wrong email or password", mainView: self)
                }
                    
                else {
                    // login success
                    self.verification.changeUserState(state: "online", completion: { (res) in
                        switch res {
                        case .failure(_):
                            self.verification.makeAlert(title: "Connection", message: "please check you connection", mainView: self)
                            SVProgressHUD.dismiss()
                           try! Auth.auth().signOut()
                        case .success(_):
                            SVProgressHUD.dismiss()
                            self.performSegue(withIdentifier: "loginToMain", sender: self)
                        }
                    })
                    
                }
            }
        }
    }
}


