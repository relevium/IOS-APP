//
//  ChatViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/15/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class ChatViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageSendBoxConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var receiverNameLabel: UILabel!
    let verification = Verification()
    var messages:[ChatEntity] = []
    let cellId = "ChatViewCell"
    var tempText = ""
    var receiverID:String?
    var receiverName: String?
    var senderID: String?
    var senderName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextField.delegate = self
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
        chatCollectionView.register(ChatViewCell.self, forCellWithReuseIdentifier: cellId)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        chatCollectionView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        receiverNameLabel.text = receiverName
        retrieveOldMessages()
        
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let message = messageTextField.text else { return }
        if message == "" { return }
        sendMessage(message: message)
        print("Sned Message")
        sender.flash()
        messageTextField.text = ""
        messageTextField.endEditing(true)

    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Message Exchange Functions
    
    /*
     Message DB contains collection for each user with userID
     each users collection contain messages collection between user and sender user
     */
    private func sendMessage(message: String){
    
        guard let receiver = receiverID else { return }
        guard let sender = senderID else { return }
        guard let name = senderName else { return }
        let messageEntity = ChatEntity(message: message, isUser: true)
        let ref = Database.database().reference().child("Messages")
        let date = verification.getDate()
        let time = verification.getTime()
        let messageID = UUID.init().uuidString
        let value = ["date":date,"from":sender,"FromName":name,"message":message,
                     "messageID":messageID,"time":time,"to":receiver,"type":"text"]
       
        //Save the message on user database
        saveMessageToUserDB(ref: ref, sender: sender,receiver: receiver, messageID: messageID, value: value, messageEntity: messageEntity)
        print("flag 1")
        sendMessageToReceiver(ref: ref, sender: sender, receiver: receiver, messageID: messageID, value: value, messageEntity: messageEntity)
        print("flag 2")
        
        
    }
    
    private func saveMessageToUserDB(ref: DatabaseReference,sender: String,receiver: String,messageID: String, value:[String:String],messageEntity:ChatEntity) {
        ref.child(sender).child(receiver).child(messageID).setValue(value) { [unowned self](error, ref) in
            if error != nil {
                print("Error Saving Message: \(error.debugDescription)")
                let errorMessage = ChatEntity(message: "failed to send message", isUser: true)
                self.messages.append(errorMessage)
                self.chatCollectionView.reloadData()
                return
            }
            else {
                print("---------saved")
            }
        }
    }
    
    private func sendMessageToReceiver(ref: DatabaseReference,sender: String,receiver: String,messageID: String, value:[String:String],messageEntity:ChatEntity) {
        
        ref.child(receiver).child(sender).child(messageID).setValue(value) { [unowned self](error, ref) in
            if error != nil {
                print("Error Sending Message: \(error.debugDescription)")
                let errorMessage = ChatEntity(message: "Receiver Failed to receive the Message", isUser: true)
                self.messages.append(errorMessage)
                self.chatCollectionView.reloadData()
                ref.child(sender).child(receiver).child(messageID).removeValue()
                return
            }
            else {
                print("-----------sent")
                // Message Sent and Received Succefully
                print("Message send Successfully")
                self.messages.append(messageEntity)
                self.chatCollectionView.reloadData()
            }
        }
    }
    
    private func retrieveOldMessages(){
        let ref = Database.database().reference().child("Messages")
        guard let currentUser = self.senderID else {
            print("failed to get current User")
            return
        }
        guard let sender = senderID else {
            print("sender not initialized")
            return
        }
        guard let receiver = receiverID else {
            print("reciever not initialized")
            return
        }
        
        ref.child(sender).child(receiver).observe(.childAdded) { (snapshot) in
            
            if let value = snapshot.value {
                let json = JSON(value)
                print(json)
                
                let message = json["message"].stringValue
                let sender = json["from"].stringValue
                print(message)
                print(sender)
                
                if sender == currentUser {
                    let messageItem = ChatEntity(message: message, isUser: true)
                    self.messages.append(messageItem)
                    self.chatCollectionView.reloadData()
                }
                else {
                    let messageItem = ChatEntity(message: message, isUser: false)
                    self.messages.append(messageItem)
                    self.chatCollectionView.reloadData()
                }
            }
            else {
                // user not registered in user collection "garbage user"
                print("error retrieving message")
            }
        }
    }
   
    //MARK: - Keyboard Handling Methods
    @objc func keyboardWillShow(notification: NSNotification){
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{return}
        UIView.animate(withDuration: 0.5) {
            self.messageSendBoxConstraint.constant = keyboardFrame.height + 5
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        UIView.animate(withDuration: 0.5) {
            self.messageSendBoxConstraint.constant = 40
        }
    }
    
    @objc func tableViewTapped(){
        messageTextField.endEditing(true)
    }
}

extension ChatViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatViewCell
        cell.chatItem = messages[indexPath.item]
        return cell
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages[indexPath.item].getMessage()
        let size = CGSize(width: view.frame.width, height: 1000)
        let attributes = [kCTFontAttributeName : UIFont.systemFont(ofSize: 18)]
        let estimateFrame = NSString(string: message).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        return CGSize(width: view.frame.width, height: estimateFrame.height + 100)
    }
}

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            messageTextField.resignFirstResponder()
            sendMessage(message: text)
            textField.text = ""
            tempText = ""
            return true
        }
        return false
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = messageTextField.text{
            tempText = text
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if tempText != "" {
            messageTextField.text = tempText
        }
    }
}
