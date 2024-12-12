//
//  ProfileViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let authService = AuthenticationService.shared
    private var chosenImage: UIImage?
    
    // We’ll assume you have a currentUser from auth
    private var currentUser: User {
        // In a real scenario, handle if user is nil.
        return authService.getCurrentUser()!
    }
    
    // Lists: from LanguageManager. For home country and childhood country,
    // if you have separate files, load them into separate arrays.
    // For demonstration, we'll reuse nationalities for them.
    private var nationalityList = LanguageManager.shared.nationalities
    private var ethnicityList = LanguageManager.shared.ethnicities
    private var countryList = LanguageManager.shared.nationalities // Placeholder for home/childhood
    private let sexOptions = ["Male", "Female", "Other"]
    
    private let nationalityField = UITextField()
    private let ethnicityField = UITextField()
    private let homeCountryField = UITextField()
    private let childhoodCountryField = UITextField()
    private let sexField = UITextField()
    
    private let photoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    private let ageField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.autocapitalizationType = .none
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNotifications()
        setupFields()
        
        view.addSubview(photoButton)
        view.addSubview(saveButton)
        
        photoButton.addTarget(self, action: #selector(didTapPhoto), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        
        updateText()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    private func setupFields() {
        [nationalityField, ethnicityField, homeCountryField, childhoodCountryField, sexField, ageField].forEach {
            $0.borderStyle = .roundedRect
            $0.autocapitalizationType = .none
            view.addSubview($0)
        }
        
        // Add targets or gestures to open selection
        nationalityField.addTarget(self, action: #selector(didTapNationality), for: .editingDidBegin)
        ethnicityField.addTarget(self, action: #selector(didTapEthnicity), for: .editingDidBegin)
        homeCountryField.addTarget(self, action: #selector(didTapHomeCountry), for: .editingDidBegin)
        childhoodCountryField.addTarget(self, action: #selector(didTapChildhoodCountry), for: .editingDidBegin)
        sexField.addTarget(self, action: #selector(didTapSex), for: .editingDidBegin)
        
        // Prevent keyboard from showing just by tapping
        nationalityField.inputView = UIView()
        ethnicityField.inputView = UIView()
        homeCountryField.inputView = UIView()
        childhoodCountryField.inputView = UIView()
        sexField.inputView = UIView()
    }
    
    @objc private func updateText() {
        let lm = LanguageManager.shared
        title = lm.string(forKey: "profile_title")
        
        nationalityField.placeholder = lm.string(forKey: "profile_nationality")
        ethnicityField.placeholder = lm.string(forKey: "profile_ethnicity")
        homeCountryField.placeholder = lm.string(forKey: "profile_home_country")
        childhoodCountryField.placeholder = lm.string(forKey: "profile_childhood_country")
        sexField.placeholder = lm.string(forKey: "profile_sex")
        ageField.placeholder = lm.string(forKey: "profile_age")
        
        photoButton.setTitle(lm.string(forKey: "profile_photo"), for: .normal)
        saveButton.setTitle(lm.string(forKey: "profile_save"), for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 44
        var y = view.safeAreaInsets.top + 100
        
        nationalityField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        ethnicityField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        homeCountryField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        childhoodCountryField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        sexField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        ageField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 20
        
        photoButton.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 20
        
        saveButton.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
    }
    
    @objc private func didTapNationality() {
        showSelection(list: nationalityList) { [weak self] selected in
            self?.nationalityField.text = selected
        }
    }
    
    @objc private func didTapEthnicity() {
        showSelection(list: ethnicityList) { [weak self] selected in
            self?.ethnicityField.text = selected
        }
    }
    
    @objc private func didTapHomeCountry() {
        showSelection(list: countryList) { [weak self] selected in
            self?.homeCountryField.text = selected
        }
    }
    
    @objc private func didTapChildhoodCountry() {
        showSelection(list: countryList) { [weak self] selected in
            self?.childhoodCountryField.text = selected
        }
    }
    
    @objc private func didTapSex() {
        // Simple action sheet since only a few options
        let alert = UIAlertController(title: LanguageManager.shared.string(forKey: "profile_sex"),
                                      message: nil, preferredStyle: .actionSheet)
        for option in sexOptions {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: { [weak self] _ in
                self?.sexField.text = option
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sexField
            popover.sourceRect = sexField.bounds
        }
        present(alert, animated: true)
    }
    
    @objc private func didTapPhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func didTapSave() {
        guard let currentUser = authService.getCurrentUser() else { return }
        
        let nationality = nationalityField.text ?? ""
        let ethnicity = ethnicityField.text ?? ""
        let homeCountry = homeCountryField.text ?? ""
        let childhoodCountry = childhoodCountryField.text ?? ""
        let sex = sexField.text ?? ""
        let age = Int(ageField.text ?? "0") ?? 0
        
        DatabaseManager.shared.updateUserProfile(
            user: currentUser,
            nationality: nationality,
            age: age,
            sex: sex,
            ethnicity: ethnicity,
            homeCountry: homeCountry,
            childhoodCountry: childhoodCountry,
            photo: chosenImage
        )
        
        // Show profile detail
        let detailVC = ProfileDetailViewController(user: currentUser)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let img = info[.originalImage] as? UIImage {
            chosenImage = img
        }
        picker.dismiss(animated: true)
    }
    
    private func showSelection(list: [String], completion: @escaping (String) -> Void) {
        let vc = ProfileSelectionViewController()
        vc.items = list
        vc.onSelect = completion
        navigationController?.pushViewController(vc, animated: true)
    }
}
