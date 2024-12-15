//
//  ProfileDetailViewController.swift
//  Why-Cook_In (외쿸인)
//

import UIKit

class ProfileDetailViewController: UIViewController {
    
    private let user: User
    private var profile: UserProfile?
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 50
        iv.layer.masksToBounds = true
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    // We'll use optional labels array to handle optional fields dynamically
    private var labels: [UILabel] = []
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        profile = DatabaseManager.shared.getUserProfile(user: user)
    }
    
    required init?(coder: NSCoder) {
        fatalError("ProfileDetailViewController must be initialized with a User")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationItem.hidesBackButton = true
        let editItem = UIBarButtonItem(title: LanguageManager.shared.string(forKey: "edit_button"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(didTapEdit))
        navigationItem.rightBarButtonItem = editItem
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        
        view.addSubview(imageView)
        
        updateText()
        displayProfileData()
        setupConstraints()
    }
    
    @objc private func updateText() {
        title = LanguageManager.shared.string(forKey: "profile_title")
        displayProfileData()
    }
    
    private func displayProfileData() {
        // Remove old labels
        for lbl in labels {
            lbl.removeFromSuperview()
        }
        labels.removeAll()
        
        let lm = LanguageManager.shared
        guard let profile = profile else { return }
        
        imageView.image = profile.photo
        
        func makeLabel(key: String, value: String) {
            guard !value.isEmpty else { return } // Don't show if empty
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.text = "\(lm.string(forKey: key)): \(value)"
            view.addSubview(lbl)
            labels.append(lbl)
        }
        
        makeLabel(key: "profile_nationality", value: profile.nationality)
        makeLabel(key: "profile_sex", value: profile.sex)
        if profile.age > 0 {
            makeLabel(key: "profile_age", value: "\(profile.age)")
        }
        if !profile.ethnicity.isEmpty {
            makeLabel(key: "profile_ethnicity", value: profile.ethnicity)
        }
        if !profile.homeCountry.isEmpty {
            makeLabel(key: "profile_home_country", value: profile.homeCountry)
        }
        if !profile.childhoodCountry.isEmpty {
            makeLabel(key: "profile_childhood_country", value: profile.childhoodCountry)
        }
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        imageView.frame = CGRect(x: (view.frame.size.width - 100)/2,
                                 y: view.safeAreaInsets.top + 20,
                                 width: 100,
                                 height: 100)
        
        var lastY = imageView.frame.maxY + 20
        for lbl in labels {
            lbl.frame = CGRect(x: padding,
                               y: lastY,
                               width: view.frame.size.width - padding*2,
                               height: 30)
            lastY += 40
        }
    }
    
    @objc private func didTapEdit() {
        // Go back to ProfileViewController in edit mode
        let vc = ProfileViewController()
        vc.isEditingProfile = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
