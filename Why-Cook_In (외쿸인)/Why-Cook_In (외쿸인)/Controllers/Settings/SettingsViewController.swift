//
//  SettingsViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import UIKit

class SettingsViewController: UIViewController {
    private let authService = AuthenticationService.shared
    
    private let languageSwitch: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["English", "한국어"])
        seg.selectedSegmentIndex = (LanguageManager.shared.currentLanguage == .english) ? 0 : 1
        return seg
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LanguageManager.shared.string(forKey: "logout_button"), for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LanguageManager.shared.string(forKey: "delete_account_button"), for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = LanguageManager.shared.string(forKey: "settings_title")
        
        view.addSubview(languageSwitch)
        view.addSubview(logoutButton)
        view.addSubview(deleteAccountButton)
        
        languageSwitch.addTarget(self, action: #selector(didChangeLanguage), for: .valueChanged)
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(didTapDeleteAccount), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        languageSwitch.frame = CGRect(x: padding,
                                      y: view.safeAreaInsets.top + 100,
                                      width: view.frame.size.width - padding*2,
                                      height: 44)
        
        logoutButton.frame = CGRect(x: padding,
                                    y: languageSwitch.frame.maxY + 40,
                                    width: view.frame.size.width - padding*2,
                                    height: 44)
        
        deleteAccountButton.frame = CGRect(x: padding,
                                           y: logoutButton.frame.maxY + 20,
                                           width: view.frame.size.width - padding*2,
                                           height: 44)
    }
    
    @objc private func updateText() {
        title = LanguageManager.shared.string(forKey: "settings_title")
        logoutButton.setTitle(LanguageManager.shared.string(forKey: "logout_button"), for: .normal)
        deleteAccountButton.setTitle(LanguageManager.shared.string(forKey: "delete_account_button"), for: .normal)
    }
    
    @objc private func didChangeLanguage() {
        let selectedLang: AppLanguage = (languageSwitch.selectedSegmentIndex == 0) ? .english : .korean
        LanguageManager.shared.setLanguage(selectedLang)
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
