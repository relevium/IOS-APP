//
//  ChatHistoryViewController.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/21/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SwiftyJSON

private let reuseIdentifier = "Cell"

class ChatHistoryViewController: UICollectionViewController {

    private let cellId = "UsersCell"
    private var messages:[Message] = []
    private var receiverID:String?
    private var receiverName: String?
    private var senderID: String?
    private var senderName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.alwaysBounceVertical = true
        collectionView.register(UsersCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        getCurrentUserDetailts()
        retriveMessages()

    }

    //MARK: - Collection View Delegate Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(messages.count)
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UsersCell
        cell.message = messages[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = messages[indexPath.item]
        self.receiverID = message.getToId()
        self.receiverName = message.getToName()
        performSegue(withIdentifier: "historyToChat", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "historyToChat" {
            if let vc = segue.destination as? ChatViewController {
                vc.senderID = self.senderID
                vc.senderName = self.senderName
                vc.receiverID = self.receiverID
                vc.receiverName = self.receiverName
                if let parentView = self.parent as? EntryViewController {
                    vc.delegate = parentView
                }
            }
        }
    }
    //MARK: - Helping Function
    
    private func retriveMessages(){
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("Messages").child(uid!)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value {
                let json = JSON(value)
                
                for (id,_):(String,JSON) in json {
                    self.getUserDetails(uid: id)
                }
            } else {
                print("failed to retrieve message history")
            }
            
        })
    }
    
    private func getUserDetails(uid: String){
        let ref = Database.database().reference().child("Users").child(uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value {
                let json = JSON(value)
                let firstName = json["mFirstName"].stringValue
                let lastName = json["mLastName"].stringValue
                let name = "\(firstName) \(lastName)"
                var seen = "online"
                let userState = json["userState"]["state"].stringValue
                
                if userState == "offline" {
                    let date = json["userState"]["date"].stringValue
                    let time = json["userState"]["time"].stringValue
                    seen = "Last Seen \(date) \(time)"
                }
                
                ref.observeSingleEvent(of: .value) { (snapshot) in
                    if let value = snapshot.value {
                        let json = JSON(value)
                        if let imageURL = json["image"].string {
                            let storgeRef = Storage.storage().reference(forURL: imageURL)
                            storgeRef.getData(maxSize: 1 * 4000 * 4000, completion: { (data, err) in
                                if err != nil {
                                    print("failed to download user image in profile \(err.debugDescription)")
                                    return
                                }
                                let image = UIImage(data: data!)
                                self.messages.append(Message(image: image, lastSeen: seen, to: uid, toName: name))
                                self.collectionView.reloadData()
                            })
                        } else {
                            print("failed to get imageURL from the datebase")
                        }
                        
                    }
                }
                
            } else {
                print("can not retrieve user data")
            }
        }
    }
    
    private func getCurrentUserDetailts(){
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("Users").child(uid!)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value {
                let json = JSON(value)
                let firstName = json["mFirstName"].stringValue
                let lastName = json["mLastName"].stringValue
                self.senderName = "\(firstName) \(lastName)"
                self.senderID = uid
            } else {
                print("can not retrieve current user data")
            }
        }
    }
    
}

extension ChatHistoryViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}
