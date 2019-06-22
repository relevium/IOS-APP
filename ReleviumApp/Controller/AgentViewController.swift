//
//  ViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Ahmed on 2/20/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import Speech
import Alamofire
import SwiftyJSON

class AgentViewController: UIViewController,UICollectionViewDataSource{
    
    @IBOutlet weak var chatView: UICollectionView!
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var queryViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var speechRecognitionButton: UIButton!
    
    let audioEngine = AVAudioEngine()
    var request: SFSpeechAudioBufferRecognitionRequest?
    let speechRecognizer:SFSpeechRecognizer? = SFSpeechRecognizer()
    var recognitionTask:SFSpeechRecognitionTask?
    var isRecording = false
    let verification = Verification()
    var messages:[ChatEntity] = []
    var tempText: String = ""
    let cellId = "ChatViewCell"
    override func viewDidLoad() {
        
        super.viewDidLoad()
        requestSpeechAuthorization()
        tabBarItem.imageInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
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

    //MARK: - Keyboard Handling Methods
    @objc func keyboardWillShow(notification: NSNotification){
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{return}
        UIView.animate(withDuration: 0.5) {
            self.queryViewConstraint.constant = keyboardFrame.height - 45
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        UIView.animate(withDuration: 0.5) {
            self.queryViewConstraint.constant = 40
        }
    }
    
    
    //MARK: -Perfom Query triggerd
    @IBAction func askbuttonPressed(_ sender: UIButton) {
        sender.flash()
        getInputFromUser()
    }
    
    @IBAction func recognitionButtonPressed(_ sender: UIButton) {
        if isRecording == false {
            recordAndRecognize()
            isRecording = true
            let alert = UIAlertController(title: "", message: "start recording", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            alert.dismiss(animated: true, completion: nil)
            } else {
            let alert = UIAlertController(title: "", message: "finish recording", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            alert.dismiss(animated: true, completion: nil)
            stopRecoding()
            isRecording = false
        }
        
    }
    
    private func recordAndRecognize(){
        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = false
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, time) in
            self.request?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            verification.makeAlert(title: "Voice Recognition", message: "voice recognition is not support for your IOS version", mainView: self)
            return
        }
        if !myRecognizer.isAvailable {
            verification.makeAlert(title: "Voice Recognition", message: "voice recognition is not available right now", mainView: self)
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request!,resultHandler: { result, err in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                let entity = ChatEntity(message: bestString, isUser: true)
                self.messages.append(entity)
                self.chatView.reloadData()
                self.predict(for: bestString, completion: { (res) in
                    switch res {
                    case .failure(let err):
                        print(err.localizedDescription)
                        self.createResponse(response: "Agent not responding")
                        self.speechSynthize(response: "Agent not responding")
                    case .success(let val):
                        self.speechSynthize(response: val)
                        self.createResponse(response: val)
                    }
                })
            } else {
                print(err.debugDescription)
            }
        })
        
    }
    
    private func stopRecoding(){
        request?.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func speechSynthize(response: String){
        let speechSynthesizer = AVSpeechSynthesizer()
        let speechUtterace = AVSpeechUtterance(string: response)
        speechUtterace.rate = AVSpeechUtteranceDefaultSpeechRate
        speechUtterace.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterace)
    }
    
    private func requestSpeechAuthorization(){
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    print("SP granted")
                case .denied:
                    self.speechRecognitionButton.isEnabled = false
                    self.verification.makeAlert(title: "Speech Recognition", message: "you have denied speech recognition permissoin", mainView: self)
                case .notDetermined:
                    self.speechRecognitionButton.isEnabled = false
                    self.verification.makeAlert(title: "Speech Recognition", message: "you have not determined speech recognition permissoin yet", mainView: self)
                case .restricted:
                    self.speechRecognitionButton.isEnabled = false
                    self.verification.makeAlert(title: "Speech Recognition", message: "speech recognition permissoin restricted", mainView: self)
                @unknown default:
                    print("unknown status")
                }
            }
        }
    }
    
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
    
    //MARK: - Agent Prediction Methods
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
    
    
    private func createResponse(response: String){
        let newMessage = ChatEntity(message: response, isUser: false)
        messages.append(newMessage)
        chatView.reloadData()
    }
    
}

//MARK: - Collection View 'Chat view ' delegate  methods
extension AgentViewController: UICollectionViewDelegate {
    
    //MARK: - Collection Datasource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatViewCell
        cell.chatItem = messages[indexPath.item]
        return cell
    }
    
    @objc func tableViewTapped(){
        queryTextField.endEditing(true)
    }
}

//MARK: - CollectionView Flow Delegate Methods

extension AgentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages[indexPath.item].getMessage()
        let size = CGSize(width: view.frame.width, height: 1000)
        let attributes = [kCTFontAttributeName : UIFont.systemFont(ofSize: 18)]
        let estimateFrame = NSString(string: message).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        return CGSize(width: view.frame.width, height: estimateFrame.height + 100)
    }
}

 //MARK: - TextField delegate Methods
extension AgentViewController: UITextFieldDelegate{
   
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
}

