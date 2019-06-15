//
//  ChatViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/15/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageSendBoxConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    var messages:[ChatEntity] = []
    let cellId = "ChatViewCell"
    var tempText = ""
    var receiverID:String?
    
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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sender.flash()
        print("Sned Message")
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func getUserId() -> String?{
        if let userId = Auth.auth().currentUser?.uid{
            return "\(userId)"
        }
        else {
            return nil
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
        messageTextField.resignFirstResponder()
        return true
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
