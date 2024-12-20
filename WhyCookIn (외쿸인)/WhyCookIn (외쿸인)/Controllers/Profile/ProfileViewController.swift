//
//  ProfileViewController.swift
//  Why-Cook_In (외쿸인)
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var isEditingProfile = false
    private let authService = AuthenticationService.shared
    private var chosenImage: UIImage?
    private var currentEditingField: UITextField?
    
    private var currentUser: User {
        return authService.getCurrentUser()!
    }
    
    // Add a scrollView and contentView
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Visibility
    private let visibilitySwitch: UISwitch = {
        let sw = UISwitch()
        return sw
    }()
    
    private let visibilityLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Visible to Others"
        lbl.font = UIFont.systemFont(ofSize: 14)
        return lbl
    }()
    
    // Photo
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.layer.masksToBounds = true
        return iv
    }()
    
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
    
    // Multiple Nationalities
    private let multipleNationalityLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "I am of multiple nationalities"
        lbl.font = UIFont.systemFont(ofSize: 14)
        return lbl
    }()
    private let multipleNationalitySwitch = UISwitch()
    private let numOfNationalitiesField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Num."
        tf.keyboardType = .numberPad
        tf.font = .systemFont(ofSize: 14)
        tf.isHidden = true
        return tf
    }()
    private var multipleNationalityFields: [UITextField] = []
    
    // Multiple Ethnicities
    private let multipleEthnicityLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "I am of mixed ethnicity"
        lbl.font = UIFont.systemFont(ofSize: 14)
        return lbl
    }()
    private let multipleEthnicitySwitch = UISwitch()
    private let numOfEthnicitiesField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Num."
        tf.keyboardType = .numberPad
        tf.font = .systemFont(ofSize: 14)
        tf.isHidden = true
        return tf
    }()
    private var multipleEthnicityFields: [UITextField] = []
    
    // Other fields
    private let nationalityField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.placeholder = "Nationality"
        return tf
    }()
    
    private let ethnicityField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.placeholder = "Ethnicity (Optional)"
        return tf
    }()
    
    private let sexField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Sex"
        return tf
    }()
    
    private let birthdayField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.placeholder = "YYYY-MM-DD"
        return tf
    }()
    
    private let homeCountryField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.placeholder = "Home Country (Optional)"
        return tf
    }()
    
    private let childhoodCountryField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.placeholder = "Childhood Country (Optional)"
        return tf
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.setTitle("Save", for: .normal)
        return btn
    }()
    
    // Data lists
    private var nationalityList = LanguageManager.shared.nationalities
    private var ethnicityList = LanguageManager.shared.ethnicities
    private var countryList = LanguageManager.shared.countries
    private let sexOptions = ["Male", "Female", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = isEditingProfile ? "Edit Profile" : "Set Profile"
        
        nationalityField.delegate = self
        ethnicityField.delegate = self
        
        setupNotifications()
        setupFields()
        
        if !isEditingProfile {
            navigationItem.hidesBackButton = true
        }
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(didTapPhoto))
        imageView.addGestureRecognizer(imageTap)
        
        editPhotoButton.addTarget(self, action: #selector(didTapPhoto), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        
        multipleNationalitySwitch.addTarget(self, action: #selector(didToggleMultipleNationalities), for: .valueChanged)
        numOfNationalitiesField.addTarget(self, action: #selector(numOfNationalitiesChanged), for: .editingChanged)
        
        multipleEthnicitySwitch.addTarget(self, action: #selector(didToggleMultipleEthnicities), for: .valueChanged)
        numOfEthnicitiesField.addTarget(self, action: #selector(numOfEthnicitiesChanged), for: .editingChanged)
        
        // Add scrollView and contentView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add subviews to contentView
        [imageView, editPhotoButton,
         visibilityLabel, visibilitySwitch,
         multipleNationalityLabel, multipleNationalitySwitch, numOfNationalitiesField,
         multipleEthnicityLabel, multipleEthnicitySwitch, numOfEthnicitiesField,
         nationalityField, ethnicityField, sexField, birthdayField,
         homeCountryField, childhoodCountryField, saveButton].forEach {
            contentView.addSubview($0)
        }
        
        updateText()
        
        // Load profile if exists
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
            
            // Multiple nationalities
            if !profile.multipleNationalities.isEmpty {
                multipleNationalitySwitch.isOn = true
                numOfNationalitiesField.isHidden = false
                numOfNationalitiesField.text = "\(profile.multipleNationalities.count)"
                numOfNationalitiesChanged()
                for (i, nat) in profile.multipleNationalities.enumerated() {
                    if i < multipleNationalityFields.count {
                        multipleNationalityFields[i].text = nat
                    }
                }
                nationalityField.isHidden = true
            } else {
                multipleNationalitySwitch.isOn = false
                numOfNationalitiesField.isHidden = true
                nationalityField.isHidden = false
            }
            
            // Multiple ethnicities
            if !profile.multipleEthnicities.isEmpty {
                multipleEthnicitySwitch.isOn = true
                numOfEthnicitiesField.isHidden = false
                numOfEthnicitiesField.text = "\(profile.multipleEthnicities.count)"
                numOfEthnicitiesChanged()
                for (i, eth) in profile.multipleEthnicities.enumerated() {
                    if i < multipleEthnicityFields.count {
                        multipleEthnicityFields[i].text = eth
                    }
                }
                ethnicityField.isHidden = true
            } else {
                multipleEthnicitySwitch.isOn = false
                numOfEthnicitiesField.isHidden = true
                ethnicityField.isHidden = false
            }
        } else {
            visibilitySwitch.isOn = true
            nationalityField.isHidden = false
            numOfNationalitiesField.isHidden = true
            ethnicityField.isHidden = false
            numOfEthnicitiesField.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 1) // will adjust height after layout
        
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 44
        
        // Photo top-left
        let imageSize: CGFloat = 80
        imageView.layer.cornerRadius = imageSize/2
        imageView.frame = CGRect(x: padding, y: view.safeAreaInsets.top + padding, width: imageSize, height: imageSize)
        
        // Edit Photo Button
        let editPhotoButtonSize = CGSize(width: 80, height: 24)
        editPhotoButton.frame = CGRect(
            x: imageView.frame.midX - editPhotoButtonSize.width/2,
            y: imageView.frame.maxY - editPhotoButtonSize.height - 5,
            width: editPhotoButtonSize.width,
            height: editPhotoButtonSize.height
        )
        
        // Visibility line (aligned to the right)
        visibilityLabel.sizeToFit()
        let switchWidth = visibilitySwitch.intrinsicContentSize.width
        let labelWidth = visibilityLabel.frame.width
        let totalVisibilityWidth = labelWidth + 8 + switchWidth
        let verticalAlignY = imageView.frame.minY + (imageSize - fieldHeight)/2
        let visibilityX = contentView.frame.size.width - padding - totalVisibilityWidth
        visibilityLabel.frame = CGRect(x: visibilityX, y: verticalAlignY, width: labelWidth, height: fieldHeight)
        visibilitySwitch.frame = CGRect(x: visibilityLabel.frame.maxX + 8, y: verticalAlignY + (fieldHeight - visibilitySwitch.frame.height)/2, width: switchWidth, height: visibilitySwitch.frame.height)
        
        // Start below the image line
        var y = max(imageView.frame.maxY, visibilityLabel.frame.maxY, visibilitySwitch.frame.maxY) + padding
        
        // Multiple Nationalities line (align to right)
        multipleNationalityLabel.sizeToFit()
        multipleNationalitySwitch.sizeToFit()
        numOfNationalitiesField.sizeToFit()
        
        let natLabelWidth = multipleNationalityLabel.frame.width
        let natSwitchW = multipleNationalitySwitch.frame.width
        let natNumW: CGFloat = multipleNationalitySwitch.isOn ? 50 : 0
        let natTotalWidth = natLabelWidth + 8 + natSwitchW + (multipleNationalitySwitch.isOn ? (8 + natNumW) : 0)
        let natX = contentView.frame.size.width - padding - natTotalWidth
        
        multipleNationalityLabel.frame = CGRect(x: natX, y: y, width: natLabelWidth, height: fieldHeight)
        multipleNationalitySwitch.frame = CGRect(x: multipleNationalityLabel.frame.maxX + 8, y: y+(fieldHeight - multipleNationalitySwitch.frame.height)/2, width: natSwitchW, height: multipleNationalitySwitch.frame.height)
        if multipleNationalitySwitch.isOn {
            numOfNationalitiesField.frame = CGRect(x: multipleNationalitySwitch.frame.maxX + 8, y: y, width: 50, height: fieldHeight)
            numOfNationalitiesField.isHidden = false
        } else {
            numOfNationalitiesField.isHidden = true
        }
        
        y += fieldHeight + 10
        
        // Multiple Ethnicity line (align to right)
        multipleEthnicityLabel.sizeToFit()
        multipleEthnicitySwitch.sizeToFit()
        numOfEthnicitiesField.sizeToFit()
        
        let ethLabelW = multipleEthnicityLabel.frame.width
        let ethSwitchW = multipleEthnicitySwitch.frame.width
        let ethNumW: CGFloat = multipleEthnicitySwitch.isOn ? 50 : 0
        let ethTotalW = ethLabelW + 8 + ethSwitchW + (multipleEthnicitySwitch.isOn ? (8+ethNumW) : 0)
        let ethX = contentView.frame.size.width - padding - ethTotalW
        
        multipleEthnicityLabel.frame = CGRect(x: ethX, y: y, width: ethLabelW, height: fieldHeight)
        multipleEthnicitySwitch.frame = CGRect(x: multipleEthnicityLabel.frame.maxX + 8, y: y+(fieldHeight - multipleEthnicitySwitch.frame.height)/2, width: ethSwitchW, height: multipleEthnicitySwitch.frame.height)
        if multipleEthnicitySwitch.isOn {
            numOfEthnicitiesField.frame = CGRect(x: multipleEthnicitySwitch.frame.maxX + 8, y: y, width: 50, height: fieldHeight)
            numOfEthnicitiesField.isHidden = false
        } else {
            numOfEthnicitiesField.isHidden = true
        }
        
        y += fieldHeight + 10
        
        // Now fields start
        // Nationalities:
        if multipleNationalitySwitch.isOn {
            nationalityField.isHidden = true
            for field in multipleNationalityFields {
                field.frame = CGRect(x: padding, y: y, width: contentView.frame.size.width - padding*2, height: fieldHeight)
                y += fieldHeight + 10
            }
        } else {
            nationalityField.isHidden = false
            nationalityField.frame = CGRect(x: padding, y: y, width: contentView.frame.size.width - padding*2, height: fieldHeight)
            y += fieldHeight + 10
        }
        
        // Ethnicities:
        if multipleEthnicitySwitch.isOn {
            ethnicityField.isHidden = true
            for field in multipleEthnicityFields {
                field.frame = CGRect(x: padding, y: y, width: contentView.frame.size.width - padding*2, height: fieldHeight)
                y += fieldHeight + 10
            }
        } else {
            ethnicityField.isHidden = false
            ethnicityField.frame = CGRect(x: padding, y: y, width: contentView.frame.size.width - padding*2, height: fieldHeight)
            y += fieldHeight + 10
        }
        
        // Sex
        sexField.frame = CGRect(x: padding, y: y, width: contentView.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        // Birthday
        birthdayField.frame = CGRect(x: padding, y: y, width: contentView.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        // HomeCountry
        homeCountryField.frame = CGRect(x: padding, y: y, width: contentView.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 10
        
        // ChildhoodCountry
        childhoodCountryField.frame = CGRect(x: padding, y: y, width: contentView.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 20
        
        // Save Button
        saveButton.frame = CGRect(x: padding, y: y, width: contentView.frame.size.width - padding*2, height: fieldHeight)
        y += fieldHeight + 20
        
        // Update contentView frame and scrollView contentSize
        contentView.frame.size.height = y
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: y)
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
        
        let nationality = (multipleNationalitySwitch.isOn ? "" : (nationalityField.text ?? ""))
        let sex = sexField.text ?? ""
        let ethnicity = (multipleEthnicitySwitch.isOn ? "" : (ethnicityField.text ?? ""))
        let homeCountry = homeCountryField.text ?? ""
        let childhoodCountry = childhoodCountryField.text ?? ""
        if (nationality.isEmpty && !multipleNationalitySwitch.isOn) || sex.isEmpty || chosenImage == nil {
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
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let birthdayYear = calendar.component(.year, from: birthday)
        if birthdayYear > currentYear {
            showAlert(title: "Error", message: "Birthday year cannot be in the future.")
            return
        }
        
        var multipleNationalities: [String] = []
        if multipleNationalitySwitch.isOn {
            if let text = numOfNationalitiesField.text, let num = Int(text), num > 0 {
                if num > 3 {
                    showAlert(title: "Error", message: "Max 3 nationalities allowed.")
                    return
                }
                if num <= 1 {
                    showAlert(title: "Error", message: "Min 2 nationalities allowed.")
                    return
                }
                
                for i in 0..<num {
                    if i < multipleNationalityFields.count {
                        let val = multipleNationalityFields[i].text ?? ""
                        if !val.isEmpty {
                            multipleNationalities.append(val)
                        }
                    }
                }
            }
            if multipleNationalities.isEmpty {
                showAlert(title: "Error", message: "Please enter at least one nationality.")
                return
            }
        }
        
        var multipleEthnicities: [String] = []
        if multipleEthnicitySwitch.isOn {
            if let text = numOfEthnicitiesField.text, let num = Int(text), num > 0 {
                if num > 3 {
                    showAlert(title: "Error", message: "Max 3 ethnicities allowed.")
                    return
                }
                if num <= 1 {
                    showAlert(title: "Error", message: "Min 2 ethnicities allowed.")
                    return
                }
                
                for i in 0..<num {
                    if i < multipleEthnicityFields.count {
                        let val = multipleEthnicityFields[i].text ?? ""
                        if !val.isEmpty {
                            multipleEthnicities.append(val)
                        }
                    }
                }
            }
        }
        
        DatabaseManager.shared.updateUserProfile(
            user: currentUser,
            firstName: currentUser.firstName,
            lastName: currentUser.lastName,
            nationality: nationality,
            birthday: birthday,
            sex: sex,
            ethnicity: ethnicity,
            homeCountry: homeCountry,
            childhoodCountry: childhoodCountry,
            photo: chosenImage,
            multipleNationalities: multipleNationalities,
            multipleEthnicities: multipleEthnicities
        )
        
        DatabaseManager.shared.setUserVisibility(user: currentUser, visible: visibilitySwitch.isOn)
        
        if isEditingProfile {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
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
    
    
    @objc private func didToggleMultipleNationalities() {
        let isOn = multipleNationalitySwitch.isOn
        numOfNationalitiesField.isHidden = !isOn
        
        if !isOn {
            multipleNationalityFields.forEach { $0.removeFromSuperview() }
            multipleNationalityFields.removeAll()
            nationalityField.isHidden = false
        } else {
            nationalityField.isHidden = true
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    @objc private func numOfNationalitiesChanged() {
        guard let text = numOfNationalitiesField.text, let num = Int(text) else { return }
        if num > 3 {
            let alert = UIAlertController(title: "Limit Exceeded", message: "Max 3 nationalities allowed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            numOfNationalitiesField.text = "3"
            return
        }
        if num <= 1 {
            let alert = UIAlertController(title: "Range Exceeded", message: "Min 2 nationalities allowed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            numOfNationalitiesField.text = "1"
            return
        }
        
        multipleNationalityFields.forEach { $0.removeFromSuperview() }
        multipleNationalityFields.removeAll()
        
        for i in 1...num {
            let tf = UITextField()
            tf.borderStyle = .roundedRect
            tf.placeholder = "Nationality \(i)"
            tf.autocapitalizationType = .none
            tf.delegate = self // Important: set the delegate here
            multipleNationalityFields.append(tf)
            contentView.addSubview(tf)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    @objc private func didToggleMultipleEthnicities() {
        let isOn = multipleEthnicitySwitch.isOn
        numOfEthnicitiesField.isHidden = !isOn
        if !isOn {
            multipleEthnicityFields.forEach { $0.removeFromSuperview() }
            multipleEthnicityFields.removeAll()
            ethnicityField.isHidden = false
        } else {
            ethnicityField.isHidden = true
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    @objc private func numOfEthnicitiesChanged() {
        guard let text = numOfEthnicitiesField.text, let num = Int(text) else { return }
        if num > 3 {
            let alert = UIAlertController(title: "Limit Exceeded", message: "Max 3 ethnicities allowed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            numOfEthnicitiesField.text = "3"
            return
        }
        if num <= 1 {
            let alert = UIAlertController(title: "Range Exceeded", message: "Min 2 ethnicities allowed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            numOfEthnicitiesField.text = "1"
            return
        }
        
        multipleEthnicityFields.forEach { $0.removeFromSuperview() }
        multipleEthnicityFields.removeAll()
        
        for i in 1...num {
            let tf = UITextField()
            tf.borderStyle = .roundedRect
            tf.placeholder = "Ethnicity \(i)"
            tf.autocapitalizationType = .none
            tf.delegate = self // set delegate here as well
            multipleEthnicityFields.append(tf)
            contentView.addSubview(tf)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
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
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    private func setupFields() {
        [nationalityField, ethnicityField, homeCountryField, childhoodCountryField, sexField, birthdayField].forEach {
            $0.addTarget(self, action: #selector(dismissKeyboard), for: .editingDidEndOnExit)
        }
        
        homeCountryField.addTarget(self, action: #selector(didTapHomeCountry), for: .editingDidBegin)
        childhoodCountryField.addTarget(self, action: #selector(didTapChildhoodCountry), for: .editingDidBegin)
        sexField.addTarget(self, action: #selector(didTapSex), for: .editingDidBegin)
    }
    
    @objc private func updateText() {
        let lm = LanguageManager.shared
        nationalityField.placeholder = lm.string(forKey: "profile_nationality")
        ethnicityField.placeholder = lm.string(forKey: "profile_ethnicity") + " (Optional)"
        homeCountryField.placeholder = lm.string(forKey: "profile_home_country") + " (Optional)"
        childhoodCountryField.placeholder = lm.string(forKey: "profile_childhood_country") + " (Optional)"
        sexField.placeholder = lm.string(forKey: "profile_sex")
        
        saveButton.setTitle(lm.string(forKey: "profile_save"), for: .normal)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Determine if this text field is one of the nationality or ethnicity fields
        // If it's a nationality field (either the main one or one of the multipleNationalityFields):
        if multipleNationalitySwitch.isOn, multipleNationalityFields.contains(textField) {
            // It's one of the dynamically created nationality fields
            currentEditingField = textField
            showSelection(list: nationalityList) { [weak self] selected in
                self?.currentEditingField?.text = selected
                self?.currentEditingField = nil
            }
            return false
        } else if !multipleNationalitySwitch.isOn && textField == nationalityField {
            // Single nationality field
            currentEditingField = textField
            showSelection(list: nationalityList) { [weak self] selected in
                self?.currentEditingField?.text = selected
                self?.currentEditingField = nil
            }
            return false
        }
        
        // Similarly for ethnicities
        if multipleEthnicitySwitch.isOn, multipleEthnicityFields.contains(textField) {
            currentEditingField = textField
            showSelection(list: ethnicityList) { [weak self] selected in
                self?.currentEditingField?.text = selected
                self?.currentEditingField = nil
            }
            return false
        } else if !multipleEthnicitySwitch.isOn && textField == ethnicityField {
            currentEditingField = textField
            showSelection(list: ethnicityList) { [weak self] selected in
                self?.currentEditingField?.text = selected
                self?.currentEditingField = nil
            }
            return false
        }
        
        // For other fields like homeCountryField, sexField (if they use a picker)
        // do the same or allow normal editing:
        if textField == homeCountryField {
            currentEditingField = textField
            showSelection(list: countryList) { [weak self] selected in
                self?.currentEditingField?.text = selected
                self?.currentEditingField = nil
            }
            return false
        }
        
        if textField == childhoodCountryField {
            currentEditingField = textField
            showSelection(list: countryList) { [weak self] selected in
                self?.currentEditingField?.text = selected
                self?.currentEditingField = nil
            }
            return false
        }
        
        if textField == sexField {
            // Show sex options in action sheet
            // It's simpler to just show them here and return false
            currentEditingField = textField
            let lm = LanguageManager.shared
            let alert = UIAlertController(title: lm.string(forKey: "profile_sex"),
                                          message: nil, preferredStyle: .actionSheet)
            for option in sexOptions {
                alert.addAction(UIAlertAction(title: option, style: .default, handler: { [weak self] _ in
                    self?.currentEditingField?.text = option
                    self?.currentEditingField = nil
                }))
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            if let popover = alert.popoverPresentationController {
                popover.sourceView = textField
                popover.sourceRect = textField.bounds
            }
            present(alert, animated: true)
            return false
        }
        
        // Fields like birthdayField that can be typed directly:
        // If you want normal keyboard, just return true:
        if textField == birthdayField {
            return true
        }
        
        // Default case:
        return true
    }
    
}
