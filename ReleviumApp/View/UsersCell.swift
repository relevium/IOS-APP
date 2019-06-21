//
//  UsersCell.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/21/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class UsersCell: UICollectionViewCell {
    
    
    //MARK: - Message Content handling
    var message:Message? {
        didSet{
            guard let newMessage = message else {return}
            friendLabel.text = newMessage.getToName()
            profilePictureView.image = newMessage.getFriendImage()
            lastSeen.text = newMessage.getLastSeen()
            
        }
    }
    
    //MARK: - Profile Picture
    private let profilePictureView :UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "userImage")
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    //MARK: - TextContainer
    private let textContainerView: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.white
        return container
    }()
    
    //MARK: - Friend label
    private let friendLabel: UILabel = {
        let label = UILabel()
        label.text = "Friend Name"
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    //MARK: - Time label
    private let lastSeen: UILabel = {
        let label = UILabel()
        label.text = "HH.MM PM"
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        profilePictureViewSetup()
        textContainerSetup()
        textSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Profile Picture Setup
    private func profilePictureViewSetup(){
        addSubview(profilePictureView)
        profilePictureView.layer.cornerRadius = frame.size.height / 2.5
        profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        profilePictureView.heightAnchor.constraint(equalToConstant: frame.size.height - 20).isActive = true
        profilePictureView.widthAnchor.constraint(equalToConstant: frame.size.height - 20).isActive = true
        profilePictureView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        profilePictureView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
    }
    
    //MARK: - text Container Setup
    private func textContainerSetup(){
        addSubview(textContainerView)
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        textContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        textContainerView.leadingAnchor.constraint(equalTo: profilePictureView.trailingAnchor, constant: 10).isActive = true
        textContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    }
    private func textSetup(){
        textContainerView.addSubview(friendLabel)
        textContainerView.addSubview(lastSeen)
        friendLabel.translatesAutoresizingMaskIntoConstraints = false
        lastSeen.translatesAutoresizingMaskIntoConstraints = false
        
        friendLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor).isActive = true
        friendLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor).isActive = true
        friendLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor).isActive = true
        
        lastSeen.topAnchor.constraint(equalTo: friendLabel.bottomAnchor,constant: 2).isActive = true
        lastSeen.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor).isActive = true
        lastSeen.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor).isActive = true
    }
    
    //MARK: - Cell view Setup
    private func setupViews(){
        backgroundColor = UIColor.white
    }
}
