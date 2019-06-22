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
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private let verification = Verification()
    
    deinit{
        print("---------login deinitialized--------")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                                                                name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "isUserLoggedIn") == true {
            print("enter user defaults")
            verification.changeUserState(state: "online") { (result) in
                switch result {
                case .failure(let failure):
                    print(failure)
                    UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                case .success(let val):
                    print(val)
                    self.performSegue(withIdentifier: "loginToMain", sender: self)
                }
            }
        }
    }
    
    //MARK: - Keyboard Handling Methods
    @objc func keyboardWillShow(notification: NSNotification){
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{return}
        UIView.animate(withDuration: 0.5) {
            self.bottomConstraint.constant = keyboardFrame.height - 80
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        UIView.animate(withDuration: 0.5) {
            self.bottomConstraint.constant = 80
        }
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
                                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                                self.performSegue(withIdentifier: "loginToMain", sender: self)
                            }
                        })
                        
                    }
                }
            }
            
        }
    }
}


