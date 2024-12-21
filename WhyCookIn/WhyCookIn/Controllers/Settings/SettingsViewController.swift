//
//  SettingsViewController.swift
//  Why-Cook_In (외쿸인)
//

import UIKit

class SettingsViewController: UIViewController {
    private let authService = AuthenticationService.shared
    
    private let languageButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let privacyButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    #if DEBUG
    private let allUsersButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemTeal
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.setTitle("All Users (Debug)", for: .normal)
        return button
    }()
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        
        view.addSubview(languageButton)
        view.addSubview(logoutButton)
        view.addSubview(deleteAccountButton)
        view.addSubview(privacyButton)
        
        languageButton.addTarget(self, action: #selector(didTapChangeLanguage), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(didTapDeleteAccount), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
        
        #if DEBUG
        view.addSubview(allUsersButton)
        allUsersButton.addTarget(self, action: #selector(didTapAllUsers), for: .touchUpInside)
        #endif
        
        updateText()
    }
    
    @objc private func updateText() {
        let lm = LanguageManager.shared
        title = lm.string(forKey: "settings_title")
        languageButton.setTitle(lm.string(forKey: "language_button"), for: .normal)
        logoutButton.setTitle(lm.string(forKey: "logout_button"), for: .normal)
        deleteAccountButton.setTitle(lm.string(forKey: "delete_account_button"), for: .normal)
        privacyButton.setTitle(lm.string(forKey: "privacy_button"), for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        
        languageButton.frame = CGRect(x: padding,
                                      y: view.safeAreaInsets.top + 100,
                                      width: view.frame.size.width - padding*2,
                                      height: 44)
        
        privacyButton.frame = CGRect(x: padding,
                                     y: languageButton.frame.maxY + 20,
                                     width: view.frame.size.width - padding*2,
                                     height: 44)
        
        logoutButton.frame = CGRect(x: padding,
                                    y: privacyButton.frame.maxY + 20,
                                    width: view.frame.size.width - padding*2,
                                    height: 44)
        
        deleteAccountButton.frame = CGRect(x: padding,
                                           y: logoutButton.frame.maxY + 20,
                                           width: view.frame.size.width - padding*2,
                                           height: 44)
        
        #if DEBUG
        allUsersButton.frame = CGRect(x: padding,
                                      y: deleteAccountButton.frame.maxY + 20,
                                      width: view.frame.size.width - padding*2,
                                      height: 44)
        #endif
    }
    
    @objc private func didTapChangeLanguage() {
        presentLanguageSelection(from: self)
    }
    
    @objc private func didTapLogout() {
        authService.logout()
        
        let loginVC = LoginViewController()
        let nav = BaseNavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc private func didTapDeleteAccount() {
        guard let currentUser = authService.getCurrentUser() else { return }
        
        authService.logout()
        DatabaseManager.shared.deleteUser(email: currentUser.email)
        
        let lm = LanguageManager.shared
        let alert = UIAlertController(title: lm.string(forKey: "account_deleted_title"),
                                      message: lm.string(forKey: "account_deleted_message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let loginVC = LoginViewController()
            let nav = BaseNavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        })
        present(alert, animated: true)
    }
    
    @objc private func didTapPrivacy() {
        let vc = PrivacyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    #if DEBUG
    @objc private func didTapAllUsers() {
        let vc = AllUsersViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    #endif
}
