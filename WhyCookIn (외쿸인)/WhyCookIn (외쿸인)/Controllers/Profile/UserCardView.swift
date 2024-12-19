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
    private let mainLabel = UILabel() // For main info: nationality, age
    private let optionalLabel = UILabel() // For witty lines about ethnicity/home
    
    init(profile: UserProfile, frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 10
        backgroundColor = .white
        clipsToBounds = true
        
        addSubview(imageView)
        addSubview(mainLabel)
        addSubview(optionalLabel)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        if let photo = profile.photo {
            imageView.image = photo
        } else {
            imageView.backgroundColor = .lightGray
        }
        
        mainLabel.numberOfLines = 0
        mainLabel.textAlignment = .center
        
        optionalLabel.numberOfLines = 0
        optionalLabel.textAlignment = .center
        optionalLabel.textColor = .darkGray
        
        // Construct main info text
        let age = calculateAge(from: profile.birthday)
        let mainText = "\(profile.firstName), \(profile.nationality), \(age) years old"
        mainLabel.text = mainText
        
        
        // Construct optional lines
        var optionalText = ""
        if !profile.ethnicity.isEmpty {
            // Witty line for ethnicity:
            // e.g.: "I've got roots that trace back to \(profile.ethnicity)."
            optionalText += "I've got roots that trace back to \(profile.ethnicity).\n"
        }
        if !profile.homeCountry.isEmpty {
            // Witty line for home country:
            // e.g.: "My passport may say \(profile.nationality), but my heart feels at home in \(profile.homeCountry)."
            optionalText += "My passport says \(profile.nationality), but I feel more at home in \(profile.homeCountry).\n"
        }
        if !profile.childhoodCountry.isEmpty {
            // Another witty line:
            // e.g.: "I spent my childhood days running around the fields of \(profile.childhoodCountry)."
            optionalText += "I spent my childhood days in \(profile.childhoodCountry)."
        }
        
        optionalLabel.text = optionalText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 10
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1 // Add a border to visually distinguish the card
        backgroundColor = .white
        clipsToBounds = true
    }
    
    private func calculateAge(from birthday: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year], from: birthday, to: now)
        return components.year ?? 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageHeight = bounds.height * 0.6
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: imageHeight)
        
        let labelPadding: CGFloat = 10
        // Layout mainLabel below image
        let maxLabelWidth = bounds.width - labelPadding*2
        mainLabel.frame = CGRect(x: labelPadding,
                                 y: imageView.frame.maxY + labelPadding,
                                 width: maxLabelWidth,
                                 height: 0)
        mainLabel.sizeToFit()
        mainLabel.frame.origin.x = (bounds.width - mainLabel.frame.width)/2
        
        optionalLabel.frame = CGRect(x: labelPadding,
                                     y: mainLabel.frame.maxY + 5,
                                     width: maxLabelWidth,
                                     height: 0)
        optionalLabel.sizeToFit()
        optionalLabel.frame.origin.x = (bounds.width - optionalLabel.frame.width)/2
    }
}

