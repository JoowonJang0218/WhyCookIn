//
//  MessageCell.swift
//  WhyCookIn (외쿸인)
//
//  Created by Joowon Jang on 12/21/24.
//

import Foundation
import UIKit
import CoreData

class MessageCell: UITableViewCell {
    let messageLabel = UILabel()
    let bubbleBackgroundView = UIView()
    let profileImageView = UIImageView()

    var isIncoming: Bool = false {
        didSet {
            bubbleBackgroundView.backgroundColor = isIncoming ? UIColor(white: 0.9, alpha: 1) : .systemBlue
            messageLabel.textColor = isIncoming ? .black : .white
            setupConstraints()
        }
    }

    var profileImage: UIImage? {
        didSet {
            profileImageView.image = profileImage
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        messageLabel.numberOfLines = 0
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 15
        profileImageView.layer.masksToBounds = true

        bubbleBackgroundView.layer.cornerRadius = 15
        bubbleBackgroundView.clipsToBounds = true

        contentView.addSubview(profileImageView)
        contentView.addSubview(bubbleBackgroundView)
        bubbleBackgroundView.addSubview(messageLabel)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupConstraints() {
        // Remove all existing constraints for a clean re-layout
        bubbleBackgroundView.removeConstraints(bubbleBackgroundView.constraints)
        profileImageView.removeConstraints(profileImageView.constraints)

        // Common constraints for messageLabel within bubble
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -12)
        ])

        if isIncoming {
            // Incoming message: show profileImageView on the left
            profileImageView.isHidden = false
            NSLayoutConstraint.activate([
                profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                profileImageView.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 30),
                profileImageView.heightAnchor.constraint(equalToConstant: 30),

                bubbleBackgroundView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
                bubbleBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                bubbleBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                bubbleBackgroundView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -80)
            ])
        } else {
            // Outgoing message: align bubble to the right, no profile image
            profileImageView.isHidden = true
            NSLayoutConstraint.activate([
                bubbleBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                bubbleBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                bubbleBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                bubbleBackgroundView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 80)
            ])
        }
    }
}
