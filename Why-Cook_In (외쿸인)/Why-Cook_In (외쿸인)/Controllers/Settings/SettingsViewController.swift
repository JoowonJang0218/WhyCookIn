//
//  SettingsViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Observe language changes
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        
        view.addSubview(languageButton)
        view.addSubview(logoutButton)
        view.addSubview(deleteAccountButton)
        
        languageButton.addTarget(self, action: #selector(didTapChangeLanguage), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(didTapDeleteAccount), for: .touchUpInside)
        
        updateText()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        
        languageButton.frame = CGRect(x: padding,
                                      y: view.safeAreaInsets.top + 100,
                                      width: view.frame.size.width - padding*2,
                                      height: 44)
        
        logoutButton.frame = CGRect(x: padding,
                                    y: languageButton.frame.maxY + 20,
                                    width: view.frame.size.width - padding*2,
                                    height: 44)
        
        deleteAccountButton.frame = CGRect(x: padding,
                                           y: logoutButton.frame.maxY + 20,
                                           width: view.frame.size.width - padding*2,
                                           height: 44)
    }
    
    @objc private func updateText() {
        let lm = LanguageManager.shared
        title = lm.string(forKey: "settings_title")
        languageButton.setTitle(lm.string(forKey: "language_button"), for: .normal)
        logoutButton.setTitle(lm.string(forKey: "logout_button"), for: .normal)
        deleteAccountButton.setTitle(lm.string(forKey: "delete_account_button"), for: .normal)
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
        if authService.getCurrentUser() != nil {
            authService.logout()
            let alert = UIAlertController(title: LanguageManager.shared.string(forKey: "account_deleted_title"),
                                          message: LanguageManager.shared.string(forKey: "account_deleted_message"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                let loginVC = LoginViewController()
                let nav = BaseNavigationController(rootViewController: loginVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            })
            present(alert, animated: true)
        }
    }
}
