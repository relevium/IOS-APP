//
//  LoginViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 3/2/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    private let verification = Verification()
    
    deinit{
        print("---------login deinitialized--------")
    }
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
            DispatchQueue.global().async {
                Auth.auth().signIn(withEmail: email, password: password) { [weak self](results, error) in
                    guard let self = self else {
                        print("call self in login after view deinitialized")
                        return
                    }
                    
                    if error != nil {
                        self.verification.makeAlert(title: "Login Failed", message: "Wrong email or password", mainView: self)
                    }
                        
                    else {
                        // login success
                        self.verification.changeUserState(state: "online", completion: { (res) in
                            switch res {
                            case .failure(_):
                                self.verification.makeAlert(title: "Connection", message: "please check you connection", mainView: self)
                                try! Auth.auth().signOut()
                            case .success(_):
                                self.performSegue(withIdentifier: "loginToMain", sender: self)
                            }
                        })
                        
                    }
                }
            }
            
        }
    }
}


