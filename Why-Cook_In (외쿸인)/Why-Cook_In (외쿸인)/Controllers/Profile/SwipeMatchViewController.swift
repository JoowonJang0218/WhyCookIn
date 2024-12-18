//
//  SwipeMatchViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/13/24.
//

import Foundation
import UIKit

class SwipeMatchViewController: UIViewController {
    
    private var users: [MatchUser] = []
    private var cardViews: [UserCardView] = []
    private let topCardIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Swipe & Match"
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapEdit))
        
        // Dummy Data
        users = [
            MatchUser(name: "Alice", age: 25, photo: UIImage(named: "examplePhoto1")!),
            MatchUser(name: "Bob", age: 30, photo: UIImage(named: "examplePhoto2")!),
            MatchUser(name: "Cathy", age: 22, photo: UIImage(named: "examplePhoto3")!)
        ]
        
        setupCards()
    }
    
    @objc private func didTapEdit() {
        let editVC = ProfileViewController()
        editVC.isEditingProfile = true
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func setupCards() {
        let cardWidth = view.bounds.width * 0.8
        let cardHeight = view.bounds.height * 0.6
        let x = (view.bounds.width - cardWidth) / 2
        let y = (view.bounds.height - cardHeight) / 2
        
        // Create card views from users data
        for (i, user) in users.enumerated() {
            let frame = CGRect(x: x, y: y, width: cardWidth, height: cardHeight)
            let card = UserCardView(user: user, frame: frame)
            cardViews.append(card)
            view.addSubview(card)
            
            // Add pan gesture only to top card initially
            if i == 0 {
                addPanGesture(to: card)
            }
        }
    }
    
    private func addPanGesture(to card: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        card.addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let card = gesture.view else { return }
        
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            // Move the card with the pan
            card.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            // Rotate card slightly based on horizontal movement
            let rotationAngle = (translation.x / view.bounds.width) * 0.4
            card.transform = CGAffineTransform(rotationAngle: rotationAngle)
        case .ended, .cancelled:
            // Decide if we like or pass the card
            let velocity = gesture.velocity(in: view)
            
            // If moved far right or velocity to the right is strong
            if translation.x > 100 || velocity.x > 800 {
                // Like action
                animateCardOffScreen(card, toTheRight: true)
                handleCardLiked(card)
            } else if translation.x < -100 || velocity.x < -800 {
                // Pass action
                animateCardOffScreen(card, toTheRight: false)
                handleCardPassed(card)
            } else {
                // Not far enough, reset card position
                UIView.animate(withDuration: 0.3) {
                    card.center = self.view.center
                    card.transform = .identity
                }
            }
        default:
            break
        }
    }
    
    private func animateCardOffScreen(_ card: UIView, toTheRight: Bool) {
        let offScreenX = toTheRight ? view.bounds.width + card.bounds.width : -card.bounds.width * 2
        UIView.animate(withDuration: 0.5, animations: {
            card.center = CGPoint(x: offScreenX, y: self.view.center.y)
            card.alpha = 0
        }, completion: { _ in
            card.removeFromSuperview()
            self.showNextCard()
        })
    }
    
    private func showNextCard() {
        // Remove the first card from array
        if !cardViews.isEmpty {
            cardViews.removeFirst()
        }
        
        // If we have another card, add pan gesture to it
        if let nextCard = cardViews.first {
            addPanGesture(to: nextCard)
        } else {
            // No more cards
            let noMoreLabel = UILabel()
            noMoreLabel.text = "No more matches!"
            noMoreLabel.textAlignment = .center
            noMoreLabel.font = .boldSystemFont(ofSize: 24)
            noMoreLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 50)
            noMoreLabel.center = view.center
            view.addSubview(noMoreLabel)
        }
    }
    
    private func handleCardLiked(_ card: UIView) {
        // Implement logic for when user likes a profile
        // E.g., send "like" to server
        print("Card liked!")
    }
    
    private func handleCardPassed(_ card: UIView) {
        // Implement logic for when user passes a profile
        // E.g., send "pass" to server
        print("Card passed!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUser = AuthenticationService.shared.getCurrentUser(),
              let profile = DatabaseManager.shared.getUserProfile(user: currentUser) else { return }
        
        if !profile.isVisible {
            // User is not visible, show greyed-out overlay
            showVisibilityOverlay()
        } else {
            // User is visible, ensure overlay is removed if it exists
            removeVisibilityOverlay()
        }
    }
    private var visibilityOverlay: UIView?

    private func showVisibilityOverlay() {
        // Create a blur or semi-transparent overlay
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let messageLabel = UILabel()
        messageLabel.text = "You must be visible to see others.\nPlease turn visibility on."
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        overlay.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: overlay.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: overlay.trailingAnchor, constant: -20)
        ])
        
        view.addSubview(overlay)
        self.visibilityOverlay = overlay
        
        // Disable user interaction on underlying swiping views
        view.isUserInteractionEnabled = false
        overlay.isUserInteractionEnabled = true
    }

    private func removeVisibilityOverlay() {
        visibilityOverlay?.removeFromSuperview()
        visibilityOverlay = nil
        
        // Re-enable interaction
        view.isUserInteractionEnabled = true
    }

}

