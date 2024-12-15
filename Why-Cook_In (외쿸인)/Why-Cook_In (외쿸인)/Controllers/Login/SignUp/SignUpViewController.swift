//
//  SignUpViewController.swift
//  Why-Cook_In (외쿸인)
//

import UIKit

class SignUpViewController: UIViewController {
    
    var completion: (() -> Void)?
    
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        return field
    }()
    
    private let userIDField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.keyboardType = .emailAddress
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        field.autocapitalizationType = .none
        return field
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let authService = AuthenticationService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        
        view.addSubview(firstNameField)
        view.addSubview(lastNameField)
        view.addSubview(userIDField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        
        updateText()
    }
    
    @objc private func updateText() {
        let lm = LanguageManager.shared
        title = lm.string(forKey: "sign_up_title")
        firstNameField.placeholder = lm.string(forKey: "first_name_placeholder")
        lastNameField.placeholder = lm.string(forKey: "last_name_placeholder")
        userIDField.placeholder = lm.string(forKey: "user_id_placeholder")
        emailField.placeholder = lm.string(forKey: "email_placeholder")
        passwordField.placeholder = lm.string(forKey: "password_placeholder")
        signUpButton.setTitle(lm.string(forKey: "sign_up_button"), for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 44
        
        firstNameField.frame = CGRect(x: padding,
                                      y: view.safeAreaInsets.top + 100,
                                      width: view.frame.size.width - padding*2,
                                      height: fieldHeight)
        
        lastNameField.frame = CGRect(x: padding,
                                     y: firstNameField.frame.maxY + 10,
                                     width: view.frame.size.width - padding*2,
                                     height: fieldHeight)
        
        userIDField.frame = CGRect(x: padding,
                                   y: lastNameField.frame.maxY + 10,
                                   width: view.frame.size.width - padding*2,
                                   height: fieldHeight)
        
        emailField.frame = CGRect(x: padding,
                                  y: userIDField.frame.maxY + 10,
                                  width: view.frame.size.width - padding*2,
                                  height: fieldHeight)
        
        passwordField.frame = CGRect(x: padding,
                                     y: emailField.frame.maxY + 10,
                                     width: view.frame.size.width - padding*2,
                                     height: fieldHeight)
        
        signUpButton.frame = CGRect(x: padding,
                                    y: passwordField.frame.maxY + 20,
                                    width: view.frame.size.width - padding*2,
                                    height: fieldHeight)
    }
    
    @objc private func didTapSignUp() {
        let lm = LanguageManager.shared
        guard let firstName = firstNameField.text, !firstName.isEmpty,
              let lastName = lastNameField.text, !lastName.isEmpty,
              let userID = userIDField.text, !userID.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: lm.string(forKey: "error_title"),
                      message: lm.string(forKey: "missing_required_fields"))
            return
        }
        
        // Validate email and password and show exact problems:
        if !isValidEmail(email) {
            showAlert(title: lm.string(forKey: "error_title"),
                      message: lm.string(forKey: "email_requirements"))
            return
        }
        
        if !isValidPassword(password) {
            showAlert(title: lm.string(forKey: "error_title"),
                      message: lm.string(forKey: "password_requirements"))
            return
        }
        
        let fullName = "\(firstName) \(lastName)"
        
        authService.signUp(email: email, password: password, name: fullName, userID: userID) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.completion?()
                } else {
                    let alert = UIAlertController(title: lm.string(forKey: "error_title"),
                                                  message: lm.string(forKey: "login_error_message"),
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
        return password.count >= 8 && hasDigit
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
