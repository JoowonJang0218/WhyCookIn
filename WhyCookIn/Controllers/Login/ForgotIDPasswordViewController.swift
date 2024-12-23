//
//  ForgotIDPasswordViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import UIKit

class ForgotIDPasswordViewController: UIViewController {
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = LanguageManager.shared.string(forKey: "forgot_idpw_instructions")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = "Email"
        field.autocapitalizationType = .none
        return field
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LanguageManager.shared.string(forKey: "submit_button"), for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(instructionsLabel)
        view.addSubview(emailField)
        view.addSubview(submitButton)
        
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 20
        instructionsLabel.frame = CGRect(x: padding,
                                         y: view.safeAreaInsets.top + 100,
                                         width: view.frame.size.width - padding*2,
                                         height: 60)
        
        emailField.frame = CGRect(x: padding,
                                  y: instructionsLabel.frame.maxY + 20,
                                  width: view.frame.size.width - padding*2,
                                  height: 44)
        
        submitButton.frame = CGRect(x: padding,
                                    y: emailField.frame.maxY + 20,
                                    width: view.frame.size.width - padding*2,
                                    height: 44)
    }
    
    @objc private func didTapSubmit() {
        // In a real app, send recovery instructions
        let alert = UIAlertController(title: "Check your email",
                                      message: "If this email is associated with an account, you'll receive instructions.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}
