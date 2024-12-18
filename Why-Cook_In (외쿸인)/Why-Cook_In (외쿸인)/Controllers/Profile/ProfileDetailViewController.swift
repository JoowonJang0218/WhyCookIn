//
//  ProfileDetailViewController.swift
//  Why-Cook_In (외쿸인)
//

import UIKit

class ProfileDetailViewController: UIViewController {
    
    private let user: User
    private var profile: UserProfile?
    private var didShowSwipe = false // A flag to avoid showing swipe multiple times
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 50
        iv.layer.masksToBounds = true
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
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

        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        
        view.addSubview(imageView)
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh the profile each time the screen appears
        profile = DatabaseManager.shared.getUserProfile(user: user)
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If we have a profile and haven't shown the swipe yet, show it
        if profile != nil && !didShowSwipe {
            didShowSwipe = true
            
            // Present or push the SwipeMatchViewController
            let swipeVC = SwipeMatchViewController()
            swipeVC.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(swipeVC, animated: true)
        }
    }
    
    @objc private func updateText() {
        title = LanguageManager.shared.string(forKey: "profile_title")
        displayProfileData()
    }
    
    private func updateUI() {
        // If no profile, present the ProfileViewController modally
        if profile == nil {
            let vc = ProfileViewController()
            vc.isEditingProfile = false
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
            return
        }
        
        // If we have a profile, show edit button and data
        navigationItem.hidesBackButton = true
        let editItem = UIBarButtonItem(title: LanguageManager.shared.string(forKey: "edit_button"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(didTapEdit))
        navigationItem.rightBarButtonItem = editItem
        
        displayProfileData()
        setupConstraints()
    }
    
    private func displayProfileData() {
        // Remove old labels
        for lbl in labels {
            lbl.removeFromSuperview()
        }
        labels.removeAll()
        
        guard let profile = profile else { return }
        let lm = LanguageManager.shared
        imageView.image = profile.photo
        
        func makeLabel(key: String, value: String) {
            guard !value.isEmpty else { return }
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.text = "\(lm.string(forKey: key)): \(value)"
            view.addSubview(lbl)
            labels.append(lbl)
        }
        
        makeLabel(key: "profile_nationality", value: profile.nationality)
        makeLabel(key: "profile_sex", value: profile.sex)
        let age = calculateAge(from: profile.birthday)
        if age > 0 {
            makeLabel(key: "profile_age", value: "\(age)")
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
    
    private func calculateAge(from birthday: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year], from: birthday, to: now)
        return components.year ?? 0
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
        let vc = ProfileViewController()
        vc.isEditingProfile = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
