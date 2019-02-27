//
//  ViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Ahmed on 2/20/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var queryViewConstraint: NSLayoutConstraint!
    var messages:[ChatEntity] = []
    var tempText: String = ""
    override func viewDidLoad() {
        
        super.viewDidLoad()
        chatTable.delegate = self
        chatTable.dataSource = self
        queryTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        chatTable.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }

    //MARK: - TableView Datasource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "queryCell", for: indexPath)
        let message = messages[indexPath.row]
        
        cell.textLabel?.text = message.getMessage()
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.textAlignment = message.isUser() ? .left : .right
        
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
        getInputFromUser()
    }
    
    //MARK: - Agent Prediction Methods
    private func getInputFromUser(){
        if let query = queryTextField.text{
            if !query.isEmpty{
                let newMessage = ChatEntity(message: query, isUser: true)
                messages.append(newMessage)
                chatTable.reloadData()
                queryTextField.text = ""
                predict(for: newMessage.getMessage())
                queryTextField.endEditing(true)
            }
        }
    }
    
    private func predict(for query: String){
        let model = TwitterSentimentClassifier()
        do{
            let result = try model.prediction(text: query)
            let agentAnswer = ChatEntity(message: result.label, isUser: false)
            messages.append(agentAnswer)
            chatTable.reloadData()
            queryTextField.endEditing(false)
        }
        catch{
            print("error predicting the query \(error)")
        }
        
    }
    
}

