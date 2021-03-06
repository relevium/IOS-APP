//
//  EntryViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/16/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import SwiftyJSON

class EntryViewController: UITabBarController {

    var senderID: String?
    var senderName: String?
    var receiverID: String?
    var receiverName: String?
    var message: String?
    var chatWith: String?
    
    private  let verfication = Verification()
    private let center = UNUserNotificationCenter.current()
    
    deinit {
        print("-------------entry point deinitialized------------")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNotificationOnChange()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notificationToChat" {
            if let vc = segue.destination as? ChatViewController {
                vc.delegate = self
                vc.senderID = self.senderID
                vc.senderName = self.senderName
                vc.receiverID = self.receiverID
                vc.receiverName = self.receiverName
                
            }
        }
    }
}

//MARK: - Chat with delegate methods
extension EntryViewController: ChatWith {
    func didChatWith(receiverID: String) {
        chatWith = receiverID
        print("chat is set")
    }
}

//MARK: - UserNodificationCenter Delegate methods
extension EntryViewController: UNUserNotificationCenterDelegate {
    
    // allow local notification to present while app is in foreground becasue by default it only work while app in background
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    // what to do when user tap on alert notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "acceptCall" {
            performSegue(withIdentifier: "notificationToChat", sender: self)
        }
        else if response.actionIdentifier == "rejectCall" {
            print("user rejected to answer the call")
        }
        completionHandler()
    }
    
    
    func makeNotificationOnChange(){
        makeNotificationOnMessage(event: .childChanged)
    }
    
    func makeNotificationOnAdd(){
        makeNotificationOnMessage(event: .childAdded)
    }
    
    private func makeNotification(message:String,from: String) {
        center.delegate = self
        makeActions(message: message, from: from)
    }
    
    private func makeActions(message:String,from:String){
        let acceptAction = UNNotificationAction(identifier: "acceptCall", title: "Do you want to Accept the incomming message?", options: [])
        let rejectAction = UNNotificationAction(identifier: "rejectCall", title: "Reject message", options: [])
        let category = UNNotificationCategory(identifier: "newMessageCategory", actions: [acceptAction,rejectAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "you have %u incomming messages", options: [])
        center.setNotificationCategories([category])
        scheduleNotification(showMessage: message, from: from)
    }
    
    private func scheduleNotification(showMessage:String,from: String){
        let content = UNMutableNotificationContent()
        content.title = "New Incomming Message \(from)"
        content.body = showMessage
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "newMessageCategory"
        makeRequest(content: content)
        
    }
    
    private func makeRequest(content:UNMutableNotificationContent){
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "newMessage", content: content, trigger: trigger)
        center.removeAllPendingNotificationRequests()
        center.add(request) { (err) in
            if err != nil {
                print("failed to add request")
            }
        }
    }
    
    private func makeNotificationOnMessage(event: DataEventType){
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("failed to get current user id")
            return
        }
        let ref = Database.database().reference().child("Messages").child(uid)
        ref.observe(event) {[weak self] (snapshot) in
            guard let self = self else {
                print("read self in entry after deinitialized")
                return
            }
            guard let value = snapshot.value else {
                print("failed to get onchange snap shot")
                return
            }
            let json = JSON(value)
            self.setPrepareMessage(json: json, uid: uid)
            //Check if the sender is other user, if current user is receiver perform alert
            if let rid = self.receiverID {
                if rid == uid {
                    //perform notification here
                    guard let message = self.message else {
                        print("failed to get message")
                        return
                    }
                    // in chat controller the user is always the sender and receiver is always the other user
                    // so we have to swap them because we trigger this notification iff the receiver is the user in the incomming json file
                    // but after we check it up we have to return the data to normal state according to the APP 
                    self.receiverID = self.senderID
                    (self.senderName,self.receiverName) = (self.receiverName, self.senderName)
                    self.senderID = uid
                    
                    if self.chatWith != nil {
                        if self.chatWith != self.receiverID {
                            self.makeNotification(message: message, from: self.receiverName ?? "")
                        }
                    } else {
                        self.makeNotification(message: message, from: self.receiverName ?? "")
                    }
                }
                else {
                    print("user just saving message")
                }
            }
            else {
                print("failed to get the receiver id")
            }
        }
    }
    
    private func setPrepareMessage(json: JSON,uid: String){
        guard var largestDate = self.verfication.getDateFromString(date: "16 Jun 1990", time: "6:11:00 AM") else {
            print("test date failed")
            return
        }
        for (_,sub):(String,JSON) in json {
            
            guard let date = self.verfication.getDateFromString(date: sub["date"].stringValue, time: sub["time"].stringValue) else {
                print("failed to get date")
                return
            }
            
            if largestDate < date {
                largestDate = date
                self.receiverID = sub["to"].string
                self.senderID = sub["from"].string
                self.senderName = sub["fromName"].string
                self.receiverName = sub["toName"].string
                self.message = sub["message"].string
            }
        }
    }
}
