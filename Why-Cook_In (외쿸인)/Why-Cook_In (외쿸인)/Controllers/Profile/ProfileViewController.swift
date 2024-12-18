//
//  ProfileViewController.swift
//  Why-Cook_In (외쿸인)
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var isEditingProfile = false
    private let authService = AuthenticationService.shared
    private var chosenImage: UIImage?
    
    private var currentUser: User {
        return authService.getCurrentUser()!
    }
    
    private let visibilitySwitch: UISwitch = {
        let sw = UISwitch()
        return sw
    }()
    
    private let visibilityLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Visible to Others"
        return lbl
    }()
    
    private var nationalityList = LanguageManager.shared.nationalities
    private var ethnicityList = LanguageManager.shared.ethnicities
    private var countryList = LanguageManager.shared.countries
    private let sexOptions = ["Male", "Female", "Other"]
    
    private let nationalityField = UITextField()
    private let ethnicityField = UITextField()
    private let homeCountryField = UITextField()
    private let childhoodCountryField = UITextField()
    private let sexField = UITextField()
    
    // Birthday field
    private let birthdayField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.placeholder = "YYYY-MM-DD"
        return tf
    }()
    
    // Remove the Add Photo button entirely
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.setTitle("Save", for: .normal)
        return btn
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 50 // Will update in layout for a circle
        iv.layer.masksToBounds = true
        return iv
    }()
    
    // A small transparent button or label on top of imageView to indicate editing photo
    private let editPhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Edit Photo", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = isEditingProfile ? "Edit Profile" : "Set Profile"
        
        setupNotifications()
        setupFields()
        
        if !isEditingProfile {
            navigationItem.hidesBackButton = true
        }
        
        if let profile = DatabaseManager.shared.getUserProfile(user: currentUser) {
            visibilitySwitch.isOn = profile.isVisible
            nationalityField.text = profile.nationality
            ethnicityField.text = profile.ethnicity
            homeCountryField.text = profile.homeCountry
            childhoodCountryField.text = profile.childhoodCountry
            sexField.text = profile.sex
            chosenImage = profile.photo
            if let photo = profile.photo {
                imageView.image = photo
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            birthdayField.text = formatter.string(from: profile.birthday)
        } else {
            visibilitySwitch.isOn = true
        }
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(didTapPhoto))
        imageView.addGestureRecognizer(imageTap)
        
        editPhotoButton.addTarget(self, action: #selector(didTapPhoto), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        
        view.addSubview(visibilityLabel)
        view.addSubview(visibilitySwitch)
        view.addSubview(imageView)
        view.addSubview(editPhotoButton)
        view.addSubview(saveButton)
        
        updateText()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    private func setupFields() {
        [nationalityField, ethnicityField, homeCountryField, childhoodCountryField, sexField, birthdayField].forEach {
            $0.borderStyle = .roundedRect
            $0.autocapitalizationType = .none
            view.addSubview($0)
        }
        
        nationalityField.inputView = UIView()
        ethnicityField.inputView = UIView()
        homeCountryField.inputView = UIView()
        childhoodCountryField.inputView = UIView()
        sexField.inputView = UIView()
        
        nationalityField.addTarget(self, action: #selector(didTapNationality), for: .editingDidBegin)
        ethnicityField.addTarget(self, action: #selector(didTapEthnicity), for: .editingDidBegin)
        homeCountryField.addTarget(self, action: #selector(didTapHomeCountry), for: .editingDidBegin)
        childhoodCountryField.addTarget(self, action: #selector(didTapChildhoodCountry), for: .editingDidBegin)
        sexField.addTarget(self, action: #selector(didTapSex), for: .editingDidBegin)
    }
    
    @objc private func updateText() {
        let lm = LanguageManager.shared
        title = lm.string(forKey: "profile_title")
        
        nationalityField.placeholder = lm.string(forKey: "profile_nationality")
        ethnicityField.placeholder = lm.string(forKey: "profile_ethnicity")
        homeCountryField.placeholder = lm.string(forKey: "profile_home_country")
        childhoodCountryField.placeholder = lm.string(forKey: "profile_childhood_country")
        sexField.placeholder = lm.string(forKey: "profile_sex")
        
        saveButton.setTitle(lm.string(forKey: "profile_save"), for: .normal)
        // "Edit Photo" text is already set, you can localize if you want
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 44
        var y = view.safeAreaInsets.top + 20
        
        visibilityLabel.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: 30)
        y += 40
        visibilitySwitch.frame = CGRect(x: padding, y: y, width: 50, height: 30)
        y += 60
        
        // Make the image circle: let's pick a size for the image
        let imageSize: CGFloat = 100
        imageView.layer.cornerRadius = imageSize / 2
        imageView.frame = CGRect(x: (view.frame.size.width - imageSize)/2, y: y, width: imageSize, height: imageSize)
        
        // Position editPhotoButton on top of the imageView
        let editPhotoButtonSize = CGSize(width: 80, height: 24)
        editPhotoButton.frame = CGRect(
            x: imageView.frame.midX - editPhotoButtonSize.width/2,
            y: imageView.frame.maxY - editPhotoButtonSize.height - 5,
            width: editPhotoButtonSize.width,
            height: editPhotoButtonSize.height
        )
        
        y += imageSize + 20
        
        nationalityField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        sexField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        birthdayField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 20
        
        ethnicityField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        homeCountryField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        childhoodCountryField.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 20
        
        saveButton.frame = CGRect(x: padding, y: y, width: view.frame.size.width - padding*2, height: fieldHeight)
    }
    
    @objc private func didTapNationality() {
        nationalityField.resignFirstResponder()
        showSelection(list: nationalityList) { [weak self] selected in
            self?.nationalityField.text = selected
        }
    }
    
    @objc private func didTapEthnicity() {
        ethnicityField.resignFirstResponder()
        showSelection(list: ethnicityList) { [weak self] selected in
            self?.ethnicityField.text = selected
        }
    }
    
    @objc private func didTapHomeCountry() {
        homeCountryField.resignFirstResponder()
        showSelection(list: countryList) { [weak self] selected in
            self?.homeCountryField.text = selected
        }
    }
    
    @objc private func didTapChildhoodCountry() {
        childhoodCountryField.resignFirstResponder()
        showSelection(list: countryList) { [weak self] selected in
            self?.childhoodCountryField.text = selected
        }
    }
    
    @objc private func didTapSex() {
        sexField.resignFirstResponder()
        
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
        let ethnicity = ethnicityField.text ?? ""
        let homeCountry = homeCountryField.text ?? ""
        let childhoodCountry = childhoodCountryField.text ?? ""
        if nationality.isEmpty || sex.isEmpty || chosenImage == nil {
            showAlert(title: lm.string(forKey: "error_title"),
                      message: lm.string(forKey: "missing_required_fields") + " " + (chosenImage == nil ? lm.string(forKey: "picture_required") : ""))
            return
        }
        
        
        guard let birthdayString = birthdayField.text, !birthdayString.isEmpty else {
            showAlert(title: lm.string(forKey: "error_title"),
                      message: "Please enter your birthday in YYYY-MM-DD format.")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let birthday = formatter.date(from: birthdayString) else {
            showAlert(title: lm.string(forKey: "error_title"),
                      message: "Invalid date format. Use YYYY-MM-DD.")
            return
        }
        
        DatabaseManager.shared.updateUserProfile(
            user: currentUser,
            nationality: nationality,
            birthday: birthday,
            sex: sex,
            ethnicity: ethnicity,
            homeCountry: homeCountry,
            childhoodCountry: childhoodCountry,
            photo: chosenImage
        )
        
        DatabaseManager.shared.updateUserVisibility(user: currentUser, visible: visibilitySwitch.isOn)
        
        if isEditingProfile {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
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
