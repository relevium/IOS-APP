//
//  ProfileViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/11/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    let verification = Verification()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func signoutButtonPressed(_ sender: UIBarButtonItem) {
        
        do{
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        }
        catch {
            verification.makeAlert(title: "Signout", message: "Connection Error failed to signout", mainView: self)
        }
        
    }

}
