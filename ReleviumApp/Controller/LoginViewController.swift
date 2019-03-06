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
import Toast_Swift

class LoginViewController: UIViewController{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonPressed(_ sender: ButtonLayout) {
        if let email = emailTextField.text, let password =  passwordTextField.text {
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: email, password: password) { (results, error) in
                if error != nil{
                    SVProgressHUD.dismiss()
                    self.view.makeToast("an error has occured, cheack email and password", duration: 0.5, position: .top)
                    
                }
                else {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "loginToAgent", sender: self)
                }
            }
        }
        else{
            self.view.makeToast("Please enter your email and password", duration: 0.5, position: .top)
        }
    }
}
