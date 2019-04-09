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
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func registerButtonPressed(_ sender: ButtonLayout) {
        sender.flash()
        if let email = emailTextField.text, let password =  passwordTextField.text {
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: email, password: password) { (results, error) in
                if error != nil{
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: "invalid email or password")
                    SVProgressHUD.dismiss(withDelay: 0.5)
                    
                }
                else {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "registerToMain", sender: self)
                }
            }
        }
    }
}
