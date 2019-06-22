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
import FirebaseStorage
import UserNotifications

class ProfileViewController: UIViewController{

    
    @IBOutlet weak var profilePicture: ProfilePicture!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var bloodTypePicker: UIPickerView!
    @IBOutlet weak var anonymitySwitch: UISwitch!
    @IBOutlet weak var dieseaseSwitch: UISwitch!
    
    private let imagePicker = UIImagePickerController()
    private let verification = Verification()
    private let bloodType = BloodType()
    private var profilePictureURL: String?
    private var bloodTypeValue = "A+"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.image = UIImage(named: "userImage")
        bloodTypePicker.dataSource = self
        bloodTypePicker.delegate = self
        imagePicker.delegate = self
        nameTextField.delegate = self
        lastNameTextField.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        retriveUserData()
        downloadUserImage()
        profilePicture.isUserInteractionEnabled = true
        let takeImagetapGesture = UITapGestureRecognizer(target: self, action: #selector(takeImage))
        profilePicture.addGestureRecognizer(takeImagetapGesture)
        
    }
    
    @IBAction func saveButtonPressed(_ sender: ButtonLayout) {
        let uid = Auth.auth().currentUser?.uid
        let userRef = Database.database().reference().child("Users").child(uid!)
        
        let anonymity = anonymitySwitch.isOn
        let dieases = dieseaseSwitch.isOn
        let firstName = nameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let value = ["AnonymityPreference":anonymity,"BloodType":bloodTypeValue,
                     "ContagiousDisease":dieases,"mFirstName":firstName,"mLastName":lastName] as [String : Any]
        userRef.updateChildValues(value) { (err, ref) in
            if err != nil {
                self.verification.makeAlert(title: "Edit Profile", message: "Network connection error failed to save data", mainView: self)
                print("error update new user info")
            }
        }
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
                self.bloodTypePicker.selectRow(self.bloodType.getBloodTypeIndex(type: bloodType), inComponent: 0, animated: false)
                self.anonymitySwitch.setOn(anonymity, animated: true)
                self.dieseaseSwitch.setOn(dieases, animated: true)
            }
            else {
                print("cant retrive user info in profile")
            }
        }
    }
    
    private func downloadUserImage() {
        let uid = Auth.auth().currentUser?.uid
        let userRef = Database.database().reference().child("Users").child(uid!)
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value {
                let json = JSON(value)
                if let imageURL = json["image"].string {
                    let storgeRef = Storage.storage().reference(forURL: imageURL)
                    storgeRef.getData(maxSize: 1 * 4000 * 4000, completion: { (data, err) in
                        if err != nil {
                            print("failed to download user image in profile \(err.debugDescription)")
                            return
                        }
                        self.profilePicture.image = UIImage(data: data!)
                    })
                } else {
                    print("failed to get imageURL from the datebase")
                }
                
            }
        }
    }
    
    @objc private func takeImage(){
        print("---------------Take profile picture----------------")
        profilePicture.flash()
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signoutButtonPressed(_ sender: UIBarButtonItem) {
        let uid = Auth.auth().currentUser?.uid
        let userRef = Database.database().reference().child("Users").child(uid!)
        
        let date = verification.getDate()
        let time = verification.getTime()
        let value = ["date":date,"time":time,"state":"offline"]
        userRef.updateChildValues(["userState":value]) { (err, ref) in
            if err != nil {
                print("failed to upate state while signout")
                return
            }
            do{
                try Auth.auth().signOut()
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                UIApplication.shared.unregisterForRemoteNotifications()
                UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                self.dismiss(animated: true, completion: nil)
            }
            catch {
                print("Signout failed")
            }
        }
    }

}

//MARK: ImagePicker Delegate methods

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            let uid = Auth.auth().currentUser?.uid
            let userRef = Database.database().reference().child("Users").child(uid!)
            let storge = Storage.storage().reference().child("Profile Images/\(uid!).jpg")
            
            storge.putFile(from: imageURL, metadata: nil) { metadata, err in
                
                if metadata != nil{
                    storge.downloadURL(completion: { (url, _) in
                        if let imageStorgeURL = url {
                            print(imageURL.absoluteString)
                            userRef.updateChildValues(["image":imageStorgeURL.absoluteString], withCompletionBlock: { (err, ref) in
                                if err != nil {
                                    print("error while setting user profile picture in database")
                                }
                            })
                        } else {
                            print("failed to get image URL after uploading")
                        }
                    })
                } else {
                    print("Error uploading the image")
                }
            }
        } else {
            print("failed to get image URL")
            return
        }
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profilePicture.image = image
            
        } else {
            print("image type casting failed")
        }
        imagePicker.dismiss(animated: true, completion: nil)
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
        bloodTypeValue = bloodType.getTypeAtIndex(index: row)
    }
}

extension ProfileViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

