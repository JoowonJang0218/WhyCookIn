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
    private let nationalityLabel = UILabel()
    private let ethnicityLabel = UILabel()
    private let optionalLabel = UILabel() // For witty lines about ethnicity/home
    
    private let spacing: CGFloat = 8
    
    init(profile: UserProfile, frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.3
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 10
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        if let photo = profile.photo {
            imageView.image = photo
        } else {
            imageView.backgroundColor = .lightGray
        }
        
        mainLabel.font = .boldSystemFont(ofSize: 30)
        mainLabel.textAlignment = .center
        mainLabel.numberOfLines = 1
        
        nationalityLabel.numberOfLines = 0
        nationalityLabel.font = .systemFont(ofSize: 15)
        nationalityLabel.textAlignment = .center
        
        ethnicityLabel.numberOfLines = 0
        ethnicityLabel.font = .systemFont(ofSize: 15)
        ethnicityLabel.textAlignment = .center
        
        optionalLabel.numberOfLines = 0
        optionalLabel.textAlignment = .center
        optionalLabel.font = .systemFont(ofSize: 15)
        optionalLabel.textColor = .darkGray
        
        addSubview(imageView)
        addSubview(mainLabel)
        addSubview(nationalityLabel)
        addSubview(ethnicityLabel)
        addSubview(optionalLabel)
        
        // Construct main info text
        let age = calculateAge(from: profile.birthday)
        let nameString = "\(profile.firstName), \(age)"
        mainLabel.text = nameString
        
        let nationalityString: String = {
            if !profile.multipleNationalities.isEmpty {
                return profile.multipleNationalities.joined(separator: ", ")
            } else {
                return profile.nationality // single fallback
            }
        }()
        nationalityLabel.text = "Nationality: \(nationalityString)"
        
        let ethnicityString: String = {
            if !profile.multipleEthnicities.isEmpty {
                return profile.multipleEthnicities.joined(separator: ", ")
            } else {
                return profile.ethnicity
            }
        }()
        if ethnicityString.isEmpty {
            ethnicityLabel.isHidden = true
        } else {
            ethnicityLabel.isHidden = false
            ethnicityLabel.text = "Ethnicity: \(ethnicityString)"
        }
        
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
            optionalText += "I feel more at home in \(profile.homeCountry).\n"
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
        
        let cardWidth = bounds.width
        //let cardHeight = bounds.height
        
        let imageHeight = bounds.height * 0.6
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: imageHeight)
        
        let labelWidth = cardWidth - spacing*2
        var currentY = imageView.frame.maxY + spacing
        
        mainLabel.frame = CGRect(x: spacing, y: currentY, width: labelWidth, height: 22)
        currentY += 22 + spacing
        
        nationalityLabel.frame = CGRect(x: spacing, y: currentY, width: labelWidth, height: 0)
        nationalityLabel.sizeToFit()
        nationalityLabel.frame.origin.x = (cardWidth - nationalityLabel.frame.width)/2
        nationalityLabel.frame.origin.y = currentY
        currentY += nationalityLabel.frame.height + spacing
        
        ethnicityLabel.frame = CGRect(x: spacing, y: currentY, width: labelWidth, height: 0)
        ethnicityLabel.sizeToFit()
        ethnicityLabel.frame.origin.x = (cardWidth - ethnicityLabel.frame.width)/2
        ethnicityLabel.frame.origin.y = currentY
        currentY += ethnicityLabel.frame.height + spacing
        
        optionalLabel.frame = CGRect(x: spacing, y: currentY, width: labelWidth, height: 0)
        optionalLabel.sizeToFit()
        optionalLabel.frame.origin.x = (cardWidth - optionalLabel.frame.width)/2
        optionalLabel.frame.origin.y = currentY
        currentY += optionalLabel.frame.height + spacing
    }
}

