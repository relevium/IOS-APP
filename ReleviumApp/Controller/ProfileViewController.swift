//
//  ProfileViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/11/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import UserNotifications

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var profilePicture: ProfilePicture!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: DesignableTextField!
    @IBOutlet weak var bloodTypePicker: UIPickerView!
    @IBOutlet weak var anonymitySwitch: UISwitch!
    @IBOutlet weak var dieseaseSwitch: UISwitch!
    
    let verification = Verification()
    let bloodType = BloodType()
    var profilePictureURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bloodTypePicker.dataSource = self
        bloodTypePicker.delegate = self
        retriveUserData()
    }
    
    @IBAction func saveButtonPressed(_ sender: ButtonLayout) {
        sender.flash()
        
    }
    
    private func retriveUserData(){
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("Users").child(uid!)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value {
                let json = JSON(value)
                
                let anonymity = json["AnonymityPreference"].boolValue
                let bloodType = json["BloodType"].stringValue
                let dieases = json["ContagiousDisease"].boolValue
                self.profilePictureURL = json["image"].stringValue
                self.nameTextField.text = json["mFirstName"].stringValue
                self.lastNameTextField.text = json["mLastName"].stringValue
                self.emailTextField.text = json["mEmail"].stringValue
                self.bloodTypePicker.selectRow(self.bloodType.getBloodTypeIndex(type: bloodType), inComponent: 0, animated: false)
                self.anonymitySwitch.setOn(anonymity, animated: true)
                self.dieseaseSwitch.setOn(dieases, animated: true)
            }
            else {
                print("cant retrive user info in profile")
            }
        }
    }
    
    @IBAction func signoutButtonPressed(_ sender: UIBarButtonItem) {
        
        do{
            try Auth.auth().signOut()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UIApplication.shared.unregisterForRemoteNotifications()
            dismiss(animated: true, completion: nil)
        }
        catch {
            print("Signout failed")
        }
        
    }

}

//MARK: Blood Type UIPickerView delegate methods
extension ProfileViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bloodType.getNumberOfTypes()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bloodType.getTypeAtIndex(index: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row)
    }
}

