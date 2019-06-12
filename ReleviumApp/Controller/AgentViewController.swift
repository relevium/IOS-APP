//
//  ViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Ahmed on 2/20/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import CoreML
import Alamofire
import Firebase
import SwiftyJSON

class AgentViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var chatView: UICollectionView!
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var queryViewConstraint: NSLayoutConstraint!
    
    var messages:[ChatEntity] = []
    var tempText: String = ""
    let cellId = "ChatViewCell"
    override func viewDidLoad() {
        
        super.viewDidLoad()
        queryTextField.delegate = self
        chatView.delegate = self
        chatView.dataSource = self
        chatView.register(ChatViewCell.self, forCellWithReuseIdentifier: cellId)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        chatView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }

    //MARK: - Collection Datasource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatViewCell
        
        return cell
    }
    
    @objc func tableViewTapped(){
        queryTextField.endEditing(true)
    }
    
    //MARK: - Keyboard Handling Methods
    @objc func keyboardWillShow(notification: NSNotification){
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{return}
        UIView.animate(withDuration: 0.5) {
            self.queryViewConstraint.constant = keyboardFrame.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        UIView.animate(withDuration: 0.5) {
            self.queryViewConstraint.constant = 35
        }
    }
    
    //MARK: - TextField delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        getInputFromUser()
        queryTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = queryTextField.text{
            tempText = text
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if tempText != "" {
            queryTextField.text = tempText
        }
    }
    
    //MARK: -Perfom Query triggerd
    @IBAction func askbuttonPressed(_ sender: UIButton) {
        sender.flash()
        getInputFromUser()
    }
    
    //MARK: - Agent Prediction Methods
    private func getInputFromUser(){
        if let query = queryTextField.text{
            if !query.isEmpty{
                let newMessage = ChatEntity(message: query, isUser: true)
                messages.append(newMessage)
                chatView.reloadData()
                queryTextField.text = ""
                predict(for: newMessage.getMessage()){ res in
                    switch res {
                        case .failure(let err):
                            print("error: \(err)")
                            self.createResponse(response: "Agent not responding")
                        case .success(let res):
                            self.createResponse(response: res)
                    }
                }
                queryTextField.endEditing(true)
            }
        }
    }
    
    private func predict(for query: String, completion: @escaping (Result<String>) -> ()){
        let urlString = "http://dummy.elrwsh.me/"
        guard let url = URL(string: urlString) else {
            completion(.failure(AgentError.ServerURLFailed))
            return
        }
        let queryID = UUID.init().uuidString
        Alamofire.request(url,method: .post,parameters:[queryID:query],encoding: JSONEncoding.default).validate().responseJSON { (response) in
            switch response.result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let res):
                    let json = JSON(res)
                    let answer = json[queryID].stringValue
                    completion(.success(answer))
            }
        }
        
    }
    
    private func getUserId() -> String{
        if let userId = Auth.auth().currentUser?.uid{
            return "\(userId)"
        }
        else {
            return "ID unavailable"
        }
    }
    
    private func createResponse(response: String){
        let newMessage = ChatEntity(message: response, isUser: false)
        messages.append(newMessage)
        chatView.reloadData()
    }
    
}

