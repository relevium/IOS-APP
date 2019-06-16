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
    let verfication = Verification()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        let content = UNMutableNotificationContent()
        content.title = "New Message From ......"
        content.body = "aeh yasta el kalam"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        let request = UNNotificationRequest(identifier: "newMessage", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        makeNotificationOnAdd()
        makeNotificationOnChange()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notificationToChat" {
            if let vc = segue.destination as? ChatViewController {
                vc.senderID = self.senderID
                vc.senderName = self.senderName
                vc.receiverID = self.receiverID
                vc.receiverName = self.receiverName
            }
        }
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
        
        if response.notification.request.identifier == "newMessage" {
            performSegue(withIdentifier: "notificationToChat", sender: self)
            print("user pressed on Alert")
        }
        completionHandler()
    }
    
    
    func makeNotificationOnChange(){
        makeNotificationOnMessage(event: .childChanged)
    }
    
    func makeNotificationOnAdd(){
        makeNotificationOnMessage(event: .childAdded)
    }
    
    private func makeNotificationOnMessage(event: DataEventType){
        guard let uid = Auth.auth().currentUser?.uid else {
            print("failed to get current user id")
            return
        }
        guard var largestDate = self.verfication.getDateFromString(date: "Jun 16 1990", time: "6:11:00 AM") else {
            print("test date failed")
            return
        }
        let ref = Database.database().reference().child("Messages").child(uid)
        
        ref.observe(event) { (snapshot) in
            guard let value = snapshot.value else {
                print("failed to get onchange snap shot")
                return
            }
            
            let json = JSON(value)
            for (_,sub):(String,JSON) in json {
                
                guard let date = self.verfication.getDateFromString(date: sub["date"].stringValue, time: sub["time"].stringValue) else {
                    print("failed to get date")
                    return
                }
                //Check if the message from current User of another, if another make notification
                if self.receiverName == nil {
                    if uid != sub["to"].stringValue && sub["to"].stringValue != "" {
                        self.receiverName = sub["to"].string
                    }
                }
                
                if largestDate < date {
                    largestDate = date
                    self.senderName = sub["fromName"].string
                    self.receiverID = sub["to"].string
                    self.senderID = sub["from"].string
                
                }
            }
            
            //Check if the sender is other user, if current user is receiver perform alert
            if let rid = self.receiverID {
                if rid == uid {
                    //perform notification here
                    print(rid)
                    print(uid)
                    print("alert is going to happen")
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
    func makeNotification() {
        
    }
}
