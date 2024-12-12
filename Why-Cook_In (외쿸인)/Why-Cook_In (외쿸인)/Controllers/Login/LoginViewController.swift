//
//  LoginViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        field.autocapitalizationType = .none
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private let authService = AuthenticationService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNotifications()
        
        view.addSubview(titleLabel)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        
        updateText()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 44
        
        titleLabel.frame = CGRect(x: padding,
                                  y: view.safeAreaInsets.top + 100,
                                  width: view.frame.size.width - padding*2,
                                  height: 30)
        
        emailField.frame = CGRect(x: padding,
                                  y: titleLabel.frame.maxY + 40,
                                  width: view.frame.size.width - padding*2,
                                  height: fieldHeight)
        
        passwordField.frame = CGRect(x: padding,
                                     y: emailField.frame.maxY + 10,
                                     width: view.frame.size.width - padding*2,
                                     height: fieldHeight)
        
        loginButton.frame = CGRect(x: padding,
                                   y: passwordField.frame.maxY + 20,
                                   width: view.frame.size.width - padding*2,
                                   height: fieldHeight)
        
        signUpButton.frame = CGRect(x: padding,
                                    y: loginButton.frame.maxY + 20,
                                    width: view.frame.size.width - padding*2,
                                    height: fieldHeight)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    @objc private func updateText() {
        title = LanguageManager.shared.string(forKey: "login_title")
        titleLabel.text = LanguageManager.shared.string(forKey: "welcome_message")
        emailField.placeholder = LanguageManager.shared.string(forKey: "email_placeholder")
        passwordField.placeholder = LanguageManager.shared.string(forKey: "password_placeholder")
        loginButton.setTitle(LanguageManager.shared.string(forKey: "login_title"), for: .normal)
        signUpButton.setTitle(LanguageManager.shared.string(forKey: "sign_up_button"), for: .normal)
    }
    
    @objc private func didTapLogin() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: LanguageManager.shared.string(forKey: "error_title"),
                      message: LanguageManager.shared.string(forKey: "empty_fields_error"))
            return
        }
        
        authService.login(email: email, password: password) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    let tabBarVC = MainTabBarController()
                    tabBarVC.modalPresentationStyle = .fullScreen
                    self?.present(tabBarVC, animated: true)
                } else {
                    self?.showLoginErrorAlert()
                }
            }
        }
    }
    
    private func showLoginErrorAlert() {
        let alert = UIAlertController(title: LanguageManager.shared.string(forKey: "login_error_title"),
                                      message: LanguageManager.shared.string(forKey: "login_error_message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LanguageManager.shared.string(forKey: "forgot_id_password"), style: .default, handler: { [weak self] _ in
            let vc = ForgotIDPasswordViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .formSheet
            self?.present(nav, animated: true)
        }))
        alert.addAction(UIAlertAction(title: LanguageManager.shared.string(forKey: "join_us"), style: .default, handler: { [weak self] _ in
            self?.didTapSignUp()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func didTapSignUp() {
        let signUpVC = SignUpViewController()
        signUpVC.completion = { [weak self] in
            let tabBarVC = MainTabBarController()
            tabBarVC.modalPresentationStyle = .fullScreen
            self?.present(tabBarVC, animated: true)
        }
        navigationController?.pushViewController(signUpVC, animated: true)
    }
}
