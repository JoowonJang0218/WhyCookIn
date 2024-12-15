//
//  ProfileViewController.swift
//  Why-Cook_In (외쿸인)
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let authService = AuthenticationService.shared
    private var chosenImage: UIImage?
    var isEditingProfile = false // Set this when pushing this VC for editing
    
    private var currentUser: User {
        return authService.getCurrentUser()!
    }
    
    private var nationalityList = LanguageManager.shared.nationalities
    private var ethnicityList = LanguageManager.shared.ethnicities
    private var countryList = LanguageManager.shared.countries // now from list-of-countries.txt
    private let sexOptions = ["Male", "Female", "Other"]
    
    private let nationalityField = UITextField()
    private let ethnicityField = UITextField() // Optional
    private let homeCountryField = UITextField() // Optional
    private let childhoodCountryField = UITextField() // Optional
    private let sexField = UITextField()
    private let ageField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.autocapitalizationType = .none
        return tf
    }()
    
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
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNotifications()
        setupFields()
        
        photoButton.addTarget(self, action: #selector(didTapPhoto), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(didTapPhoto))
        imageView.addGestureRecognizer(imageTap)
        
        view.addSubview(imageView)
        view.addSubview(photoButton)
        view.addSubview(saveButton)
        
        // If editing profile, load existing profile data
        if isEditingProfile, let profile = DatabaseManager.shared.getUserProfile(user: currentUser) {
            nationalityField.text = profile.nationality
            ethnicityField.text = profile.ethnicity.isEmpty ? "" : profile.ethnicity
            homeCountryField.text = profile.homeCountry.isEmpty ? "" : profile.homeCountry
            childhoodCountryField.text = profile.childhoodCountry.isEmpty ? "" : profile.childhoodCountry
            sexField.text = profile.sex
            ageField.text = profile.age > 0 ? "\(profile.age)" : ""
            if let photo = profile.photo {
                chosenImage = photo
                imageView.image = photo
            }
        }
        
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
        
        nationalityField.addTarget(self, action: #selector(didTapNationality), for: .editingDidBegin)
        ethnicityField.addTarget(self, action: #selector(didTapEthnicity), for: .editingDidBegin)
        homeCountryField.addTarget(self, action: #selector(didTapHomeCountry), for: .editingDidBegin)
        childhoodCountryField.addTarget(self, action: #selector(didTapChildhoodCountry), for: .editingDidBegin)
        sexField.addTarget(self, action: #selector(didTapSex), for: .editingDidBegin)
        
        nationalityField.inputView = UIView()
        ethnicityField.inputView = UIView()
        homeCountryField.inputView = UIView()
        childhoodCountryField.inputView = UIView()
        sexField.inputView = UIView()
    }
    
    @objc private func updateText() {
        let lm = LanguageManager.shared
        title = lm.string(forKey: "profile_title")
        
        nationalityField.placeholder = lm.string(forKey: "profile_nationality") // Required
        ethnicityField.placeholder = lm.string(forKey: "profile_ethnicity") // Optional
        homeCountryField.placeholder = lm.string(forKey: "profile_home_country") // Optional
        childhoodCountryField.placeholder = lm.string(forKey: "profile_childhood_country") // Optional
        sexField.placeholder = lm.string(forKey: "profile_sex") // Required
        ageField.placeholder = lm.string(forKey: "profile_age") // Required
        
        photoButton.setTitle(lm.string(forKey: "profile_photo"), for: .normal)
        saveButton.setTitle(lm.string(forKey: "profile_save"), for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 44
        var y = view.safeAreaInsets.top + 20
        
        imageView.frame = CGRect(x: padding, y: y, width: 100, height: 100)
        y += 120
        
        nationalityField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        sexField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        ageField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 20
        
        ethnicityField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        homeCountryField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        childhoodCountryField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
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
        let lm = LanguageManager.shared
        let alert = UIAlertController(title: lm.string(forKey: "profile_sex"),
                                      message: nil, preferredStyle: .actionSheet)
        for option in sexOptions {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: { [weak self] _ in
                self?.sexField.text = option
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
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
        let lm = LanguageManager.shared
        guard let currentUser = authService.getCurrentUser() else { return }
        
        let nationality = nationalityField.text ?? ""
        let sex = sexField.text ?? ""
        let age = Int(ageField.text ?? "0") ?? 0
        
        // Required fields: nationality, sex, age > 0, chosenImage != nil
        if nationality.isEmpty || sex.isEmpty || age <= 0 || chosenImage == nil {
            showAlert(title: lm.string(forKey: "error_title"), message: lm.string(forKey: "missing_required_fields") + " " + (chosenImage == nil ? lm.string(forKey: "picture_required") : ""))
            return
        }
        
        let ethnicity = ethnicityField.text ?? ""
        let homeCountry = homeCountryField.text ?? ""
        let childhoodCountry = childhoodCountryField.text ?? ""
        
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
        
        let detailVC = ProfileDetailViewController(user: currentUser)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let img = info[.originalImage] as? UIImage {
            chosenImage = img
            imageView.image = img
        }
        picker.dismiss(animated: true)
    }
    
    private func showSelection(list: [String], completion: @escaping (String) -> Void) {
        let vc = ProfileSelectionViewController()
        vc.items = list
        vc.onSelect = completion
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
