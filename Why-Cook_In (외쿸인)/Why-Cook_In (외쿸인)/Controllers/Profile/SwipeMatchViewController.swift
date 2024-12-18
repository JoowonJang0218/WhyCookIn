//
//  SwipeMatchViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/13/24.
//

import Foundation
import UIKit

class SwipeMatchViewController: UIViewController {
    
    private var profiles: [UserProfile] = []
    private var cardViews: [UserCardView] = []
    private var visibilityOverlay: UIView?

    private let passButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Pass", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemRed
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    private let matchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Match", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Pass & Match"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Chats", style: .plain, target: self, action: #selector(didTapChats))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapEdit))
        
        guard let currentUser = AuthenticationService.shared.getCurrentUser() else {
            return
        }
        
        // Fetch other users
        profiles = DatabaseManager.shared.fetchOtherUsersProfiles(excluding: currentUser)
        
        setupCards()
        
        view.addSubview(passButton)
        view.addSubview(matchButton)
        
        passButton.addTarget(self, action: #selector(didTapPass), for: .touchUpInside)
        matchButton.addTarget(self, action: #selector(didTapMatch), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 20
        let buttonWidth: CGFloat = (view.frame.size.width - (padding * 3))/2
        let buttonHeight: CGFloat = 44
        let y = view.frame.size.height - view.safeAreaInsets.bottom - buttonHeight - 20
        
        passButton.frame = CGRect(x: padding, y: y, width: buttonWidth, height: buttonHeight)
        matchButton.frame = CGRect(x: passButton.frame.maxX + padding, y: y, width: buttonWidth, height: buttonHeight)
    }
    
    private func setupCards() {
        let cardWidth = view.bounds.width * 0.8
        let cardHeight = view.bounds.height * 0.6
        let x = (view.bounds.width - cardWidth) / 2
        let y = (view.bounds.height - cardHeight) / 2
        
        for (i, profile) in profiles.enumerated() {
            let frame = CGRect(x: x, y: y, width: cardWidth, height: cardHeight)
            let card = UserCardView(profile: profile, frame: frame)
            cardViews.append(card)
            view.addSubview(card)
            
            // Add pan gesture so the user can actually swipe
            // The top card is interactable, future cards become interactable when top card is removed
            if i == 0 {
                addPanGesture(to: card)
            }
        }
        
        updateUIForCardCount()
    }
    
    private func updateUIForCardCount() {
        if cardViews.isEmpty {
            showNoMoreMatches()
        } else {
            passButton.isHidden = false
            matchButton.isHidden = false
        }
    }
    
    private func showNoMoreMatches() {
        passButton.isHidden = true
        matchButton.isHidden = true
        
        let label = UILabel()
        label.text = "Congratulations!\nYou went though everyone!"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.frame = CGRect(x: 40, y: 0, width: view.bounds.width - 80, height: 150)
        label.center = view.center
        view.addSubview(label)
    }
    
    @objc private func didTapChats() {
        let chatsVC = UIViewController()
        chatsVC.view.backgroundColor = .systemBackground
        chatsVC.title = "Chats"
        navigationController?.pushViewController(chatsVC, animated: true)
    }
    
    @objc private func didTapEdit() {
        let editVC = ProfileViewController()
        editVC.isEditingProfile = true
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc private func didTapPass() {
        guard let topCard = cardViews.first else { return }
        // Animate card off to the left, simulating a pass
        animateCardOffScreen(topCard, toTheRight: false)
        handleCardPassed(topCard)
    }
    
    @objc private func didTapMatch() {
        guard let topCard = cardViews.first else { return }
        // Animate card off to the right
        animateCardOffScreen(topCard, toTheRight: true)
        handleCardLiked(topCard)
        
        // After the card is gone, show the match screen
        // We'll delay slightly so the user sees the card swipe first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showMatchScreen()
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
            card.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            let rotationAngle = (translation.x / view.bounds.width) * 0.4
            card.transform = CGAffineTransform(rotationAngle: rotationAngle)
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view)
            
            if translation.x > 100 || velocity.x > 800 {
                animateCardOffScreen(card, toTheRight: true)
                handleCardLiked(card)
            } else if translation.x < -100 || velocity.x < -800 {
                animateCardOffScreen(card, toTheRight: false)
                handleCardPassed(card)
            } else {
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
            if let cardView = card as? UserCardView, let index = self.cardViews.firstIndex(of: cardView) {
                self.cardViews.remove(at: index)
            }
            if let nextCard = self.cardViews.first {
                self.addPanGesture(to: nextCard)
            } else {
                self.updateUIForCardCount()
            }
        })
    }
    
    private func handleCardLiked(_ card: UIView) {
        print("Card liked!")
        // If this was a real scenario, you'd check server if there's a mutual match.
        // For now, we just show the match screen after the card is removed.
    }
    
    private func handleCardPassed(_ card: UIView) {
        print("Card passed!")
    }
    
    private func showMatchScreen() {
        let matchView = UIView(frame: view.bounds)
        matchView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let matchLabel = UILabel()
        matchLabel.text = "You got a match!"
        matchLabel.font = .boldSystemFont(ofSize: 30)
        matchLabel.textColor = .white
        matchLabel.textAlignment = .center
        
        matchView.addSubview(matchLabel)
        matchLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            matchLabel.centerXAnchor.constraint(equalTo: matchView.centerXAnchor),
            matchLabel.centerYAnchor.constraint(equalTo: matchView.centerYAnchor)
        ])
        
        view.addSubview(matchView)
        
        // Animate it away after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 0.5, animations: {
                matchView.alpha = 0
            }, completion: { _ in
                matchView.removeFromSuperview()
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUser = AuthenticationService.shared.getCurrentUser(),
              let profile = DatabaseManager.shared.getUserProfile(user: currentUser) else { return }
        
        if !profile.isVisible {
            showVisibilityOverlay()
        } else {
            removeVisibilityOverlay()
        }
    }
    
    private func showVisibilityOverlay() {
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
        visibilityOverlay = overlay
        view.isUserInteractionEnabled = false
        overlay.isUserInteractionEnabled = true
    }

    private func removeVisibilityOverlay() {
        visibilityOverlay?.removeFromSuperview()
        visibilityOverlay = nil
        view.isUserInteractionEnabled = true
    }
}
