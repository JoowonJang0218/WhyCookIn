//
//  PrivacyViewController.swift
//  Why-Cook_In (외쿸인)
//

import UIKit

class PrivacyViewController: UIViewController {
    
    private let visibilitySwitch: UISwitch = {
        let sw = UISwitch()
        return sw
    }()
    
    private let visibilityLabel: UILabel = {
        let lbl = UILabel()
        return lbl
    }()
    
    private var user: User {
        // Assume current user is available from AuthenticationService
        return AuthenticationService.shared.getCurrentUser()!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        
        view.addSubview(visibilityLabel)
        view.addSubview(visibilitySwitch)
        
        visibilitySwitch.addTarget(self, action: #selector(didToggleVisibility), for: .valueChanged)
        
        updateText()
        
        // Load current visibility
        visibilitySwitch.isOn = DatabaseManager.shared.isUserVisible(user: user)
    }
    
    @objc private func updateText() {
        title = LanguageManager.shared.string(forKey: "privacy_button")
        visibilityLabel.text = LanguageManager.shared.string(forKey: "visibility_toggle")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        visibilityLabel.frame = CGRect(x: padding,
                                       y: view.safeAreaInsets.top + 100,
                                       width: view.frame.size.width - padding*2,
                                       height: 30)
        visibilitySwitch.frame = CGRect(x: padding,
                                        y: visibilityLabel.frame.maxY + 10,
                                        width: 50,
                                        height: 30)
    }
    
    @objc private func didToggleVisibility() {
        DatabaseManager.shared.setUserVisibility(user: user, visible: visibilitySwitch.isOn)
    }
}
