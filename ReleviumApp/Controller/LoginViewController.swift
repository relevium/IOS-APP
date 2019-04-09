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


class LoginViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: email, password: password) { (results, error) in
                if error != nil{
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: "invalid email or password")
                    SVProgressHUD.dismiss(withDelay: 0.5)
                    
                }
                else {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "loginToMain", sender: self)
                }
            }
        }
    }
    
}
