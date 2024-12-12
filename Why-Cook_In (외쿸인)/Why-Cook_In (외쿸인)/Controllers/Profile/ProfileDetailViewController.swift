//
//  ProfileDetailViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import UIKit

class ProfileDetailViewController: UIViewController {
    
    private let user: User
    private var profile: UserProfile?
    private let authService = AuthenticationService.shared
    
    // UI Elements to display profile info
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 50
        iv.layer.masksToBounds = true
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private let nationalityLabel = UILabel()
    private let ethnicityLabel = UILabel()
    private let homeCountryLabel = UILabel()
    private let childhoodCountryLabel = UILabel()
    private let sexLabel = UILabel()
    private let ageLabel = UILabel()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
        // Fetch user profile from DatabaseManager
        profile = DatabaseManager.shared.getUserProfile(user: user)
    }
    
    required init?(coder: NSCoder) {
        fatalError("ProfileDetailViewController must be initialized with a User")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        
        [imageView, nationalityLabel, ethnicityLabel, homeCountryLabel, childhoodCountryLabel, sexLabel, ageLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        updateText()
        displayProfileData()
        setupConstraints()
    }
    
    @objc private func updateText() {
        let lm = LanguageManager.shared
        title = lm.string(forKey: "profile_title")
        
        // You might label each field. For example:
        // Nationality: <value>
        // If you prefer adding static text + value, define more keys like "profile_nationality_colon" = "Nationality:"
        // For simplicity, I'll just show the value. If you want labels, add keys in LanguageManager.
        
        // If you want to show for example:
        // nationalityLabel.text = lm.string(forKey: "profile_nationality") + ": " + (profile?.nationality ?? "")
        // We'll do that below in displayProfileData().
        
        displayProfileData()
    }
    
    private func displayProfileData() {
        let lm = LanguageManager.shared
        guard let profile = profile else {
            nationalityLabel.text = "\(lm.string(forKey: "profile_nationality")): -"
            ethnicityLabel.text = "\(lm.string(forKey: "profile_ethnicity")): -"
            homeCountryLabel.text = "\(lm.string(forKey: "profile_home_country")): -"
            childhoodCountryLabel.text = "\(lm.string(forKey: "profile_childhood_country")): -"
            sexLabel.text = "\(lm.string(forKey: "profile_sex")): -"
            ageLabel.text = "\(lm.string(forKey: "profile_age")): -"
            return
        }

        nationalityLabel.text = "\(lm.string(forKey: "profile_nationality")): \(profile.nationality)"
        ethnicityLabel.text = "\(lm.string(forKey: "profile_ethnicity")): \(profile.ethnicity)"
        homeCountryLabel.text = "\(lm.string(forKey: "profile_home_country")): \(profile.homeCountry)"
        childhoodCountryLabel.text = "\(lm.string(forKey: "profile_childhood_country")): \(profile.childhoodCountry)"
        sexLabel.text = "\(lm.string(forKey: "profile_sex")): \(profile.sex)"
        ageLabel.text = "\(lm.string(forKey: "profile_age")): \(profile.age > 0 ? "\(profile.age)" : "-")"

        imageView.image = profile.photo
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            nationalityLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: padding),
            nationalityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            nationalityLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            ethnicityLabel.topAnchor.constraint(equalTo: nationalityLabel.bottomAnchor, constant: 10),
            ethnicityLabel.leadingAnchor.constraint(equalTo: nationalityLabel.leadingAnchor),
            ethnicityLabel.trailingAnchor.constraint(equalTo: nationalityLabel.trailingAnchor),
            
            homeCountryLabel.topAnchor.constraint(equalTo: ethnicityLabel.bottomAnchor, constant: 10),
            homeCountryLabel.leadingAnchor.constraint(equalTo: nationalityLabel.leadingAnchor),
            homeCountryLabel.trailingAnchor.constraint(equalTo: nationalityLabel.trailingAnchor),
            
            childhoodCountryLabel.topAnchor.constraint(equalTo: homeCountryLabel.bottomAnchor, constant: 10),
            childhoodCountryLabel.leadingAnchor.constraint(equalTo: nationalityLabel.leadingAnchor),
            childhoodCountryLabel.trailingAnchor.constraint(equalTo: nationalityLabel.trailingAnchor),
            
            sexLabel.topAnchor.constraint(equalTo: childhoodCountryLabel.bottomAnchor, constant: 10),
            sexLabel.leadingAnchor.constraint(equalTo: nationalityLabel.leadingAnchor),
            sexLabel.trailingAnchor.constraint(equalTo: nationalityLabel.trailingAnchor),
            
            ageLabel.topAnchor.constraint(equalTo: sexLabel.bottomAnchor, constant: 10),
            ageLabel.leadingAnchor.constraint(equalTo: nationalityLabel.leadingAnchor),
            ageLabel.trailingAnchor.constraint(equalTo: nationalityLabel.trailingAnchor)
        ])
    }
}
