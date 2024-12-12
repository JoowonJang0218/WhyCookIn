//
//  ProfileViewController.swift
//  Why-Cook_In (외쿸인)
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let nationalityField = UITextField()
    private let ageField = UITextField()
    private let sexField = UITextField()
    private let ethnicityField = UITextField()
    private let homeCountryField = UITextField()
    private let childhoodCountryField = UITextField()
    
    private let photoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(LanguageManager.shared.string(forKey: "profile_photo"), for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(LanguageManager.shared.string(forKey: "profile_save"), for: .normal)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    private var chosenImage: UIImage?
    private let authService = AuthenticationService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = LanguageManager.shared.string(forKey: "profile_title")
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        
        setupFields()
        
        view.addSubview(photoButton)
        view.addSubview(saveButton)
        
        photoButton.addTarget(self, action: #selector(didTapPhoto), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
    }
    
    private func setupFields() {
        nationalityField.borderStyle = .roundedRect
        nationalityField.placeholder = LanguageManager.shared.string(forKey: "profile_nationality")
        
        ageField.borderStyle = .roundedRect
        ageField.keyboardType = .numberPad
        ageField.placeholder = LanguageManager.shared.string(forKey: "profile_age")
        
        sexField.borderStyle = .roundedRect
        sexField.placeholder = LanguageManager.shared.string(forKey: "profile_sex")
        
        ethnicityField.borderStyle = .roundedRect
        ethnicityField.placeholder = LanguageManager.shared.string(forKey: "profile_ethnicity")
        
        homeCountryField.borderStyle = .roundedRect
        homeCountryField.placeholder = LanguageManager.shared.string(forKey: "profile_home_country")
        
        childhoodCountryField.borderStyle = .roundedRect
        childhoodCountryField.placeholder = LanguageManager.shared.string(forKey: "profile_childhood_country")
        
        [nationalityField, ageField, sexField, ethnicityField, homeCountryField, childhoodCountryField].forEach { view.addSubview($0) }
    }
    
    @objc private func updateText() {
        title = LanguageManager.shared.string(forKey: "profile_title")
        nationalityField.placeholder = LanguageManager.shared.string(forKey: "profile_nationality")
        ageField.placeholder = LanguageManager.shared.string(forKey: "profile_age")
        sexField.placeholder = LanguageManager.shared.string(forKey: "profile_sex")
        ethnicityField.placeholder = LanguageManager.shared.string(forKey: "profile_ethnicity")
        homeCountryField.placeholder = LanguageManager.shared.string(forKey: "profile_home_country")
        childhoodCountryField.placeholder = LanguageManager.shared.string(forKey: "profile_childhood_country")
        photoButton.setTitle(LanguageManager.shared.string(forKey: "profile_photo"), for: .normal)
        saveButton.setTitle(LanguageManager.shared.string(forKey: "profile_save"), for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 44
        let startY = view.safeAreaInsets.top + 100
        
        nationalityField.frame = CGRect(x: padding, y: startY, width: view.frame.size.width - padding*2, height: fieldHeight)
        ageField.frame = CGRect(x: padding, y: nationalityField.frame.maxY + 10, width: view.frame.size.width - padding*2, height: fieldHeight)
        sexField.frame = CGRect(x: padding, y: ageField.frame.maxY + 10, width: view.frame.size.width - padding*2, height: fieldHeight)
        ethnicityField.frame = CGRect(x: padding, y: sexField.frame.maxY + 10, width: view.frame.size.width - padding*2, height: fieldHeight)
        homeCountryField.frame = CGRect(x: padding, y: ethnicityField.frame.maxY + 10, width: view.frame.size.width - padding*2, height: fieldHeight)
        childhoodCountryField.frame = CGRect(x: padding, y: homeCountryField.frame.maxY + 10, width: view.frame.size.width - padding*2, height: fieldHeight)
        
        photoButton.frame = CGRect(x: padding, y: childhoodCountryField.frame.maxY + 20, width: view.frame.size.width - padding*2, height: fieldHeight)
        saveButton.frame = CGRect(x: padding, y: photoButton.frame.maxY + 20, width: view.frame.size.width - padding*2, height: fieldHeight)
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
        let age = Int(ageField.text ?? "0") ?? 0
        let sex = sexField.text ?? ""
        let ethnicity = ethnicityField.text ?? ""
        let homeCountry = homeCountryField.text ?? ""
        let childhoodCountry = childhoodCountryField.text ?? ""
        
        DatabaseManager.shared.updateUserProfile(user: currentUser, nationality: nationality, age: age, sex: sex, ethnicity: ethnicity, homeCountry: homeCountry, childhoodCountry: childhoodCountry, photo: chosenImage)
        
        let alert = UIAlertController(title: "Saved", message: "Profile updated!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let img = info[.originalImage] as? UIImage {
            chosenImage = img
        }
        picker.dismiss(animated: true)
    }
}
