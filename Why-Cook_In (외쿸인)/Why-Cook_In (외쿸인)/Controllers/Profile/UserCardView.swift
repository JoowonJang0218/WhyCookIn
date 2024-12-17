//
//  UserCardView.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/15/24.
//

import Foundation
import UIKit

class UserCardView: UIView {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let ageLabel = UILabel()
    
    init(user: MatchUser, frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 10
        backgroundColor = .white
        clipsToBounds = true
        
        imageView.image = user.photo
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        nameLabel.text = user.name
        nameLabel.font = .boldSystemFont(ofSize: 24)
        
        ageLabel.text = "\(user.age)"
        ageLabel.font = .systemFont(ofSize: 18)
        ageLabel.textColor = .secondaryLabel
        
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(ageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.7)
        nameLabel.frame = CGRect(x: 10, y: imageView.frame.maxY + 10, width: bounds.width - 20, height: 30)
        ageLabel.frame = CGRect(x: 10, y: nameLabel.frame.maxY + 5, width: bounds.width - 20, height: 25)
    }
}
