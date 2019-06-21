//
//  ChatViewCell.swift
//  ReleviumApp
//
//  Created by Ahmed Samir on 6/13/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class ChatViewCell: UICollectionViewCell {
    
    var chatItem: ChatEntity?{
        didSet{
            guard let item = chatItem else { return }
            if item.isUser() {
                
                createQueryCell(query: item.getMessage(), date: item.getDate())
            }
            else {
              
                CreateResponseCell(response: item.getMessage(), date: item.getDate())
            }
        }
    }
    
    private let parentView = UIView()
    private var dateLabel = UILabel()
    private let messagelabel: UILabel = {
       
        let view = UILabel()
        view.numberOfLines = 0
        view.font = UIFont.systemFont(ofSize: 18)
        return view
    }()
    
    private let logo :UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "logo without bg-2")
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func createQueryCell(query:String, date:String){
        
        parentView.removeFromSuperview()
        logo.removeFromSuperview()
        parentView.layer.cornerRadius = 30
        messagelabel.text = query
        messagelabel.textAlignment = .right
        messagelabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        dateLabel.text = date
        dateLabel.textAlignment = .right
        dateLabel.textColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
        addSubview(parentView)
        parentView.addSubview(messagelabel)
        parentView.addSubview(dateLabel)
        parentView.backgroundColor = #colorLiteral(red: 0.1254901961, green: 0.8235294118, blue: 0.8, alpha: 0.75)
        
        parentView.frame = CGRect(x: frame.width * 0.2, y: 5, width: frame.width - frame.width * 0.2 - 5, height: frame.height - 10)
        configureSubView()
        
    }
    
    private func CreateResponseCell(response: String, date: String){
        
        parentView.removeFromSuperview()
        logo.removeFromSuperview()
        parentView.layer.cornerRadius = 30
        messagelabel.text = response
        messagelabel.textAlignment = .left
        messagelabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        dateLabel.text = date
        dateLabel.textAlignment = .left
        dateLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        addSubview(parentView)
        addSubview(logo)
        parentView.addSubview(messagelabel)
        parentView.addSubview(dateLabel)
        parentView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
       parentView.frame = CGRect(x: 5, y: 5, width: frame.width - frame.width * 0.2, height: frame.height - 10)
        
        configureSubView()

        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.layer.cornerRadius = 20 / 2.5

        logo.heightAnchor.constraint(equalToConstant: 30).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 30).isActive = true
        logo.topAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        logo.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 5).isActive = true
        
    }
    
    private func configureSubView(){
        messagelabel.translatesAutoresizingMaskIntoConstraints = false
        messagelabel.topAnchor.constraint(equalTo: parentView.topAnchor,constant: 20).isActive = true
        messagelabel.leadingAnchor.constraint(equalTo: parentView.leadingAnchor,constant: 8).isActive = true
        messagelabel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor,constant: -8).isActive = true
        messagelabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor,constant: -3).isActive = true
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.bottomAnchor.constraint(equalTo: parentView.bottomAnchor,constant: -5).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: parentView.leadingAnchor,constant: 35).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor,constant: -35).isActive = true
    }
    
}
