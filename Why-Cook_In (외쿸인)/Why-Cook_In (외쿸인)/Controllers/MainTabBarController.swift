//
//  MainTabBarController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let communityViewModel = CommunityViewModel()
        let communityVC = CommunityViewController(viewModel: communityViewModel)
        let communityNav = BaseNavigationController(rootViewController: communityVC)
        communityNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("community_title", comment: ""),
            image: UIImage(systemName: "person.3.fill"),
            tag: 0
        )
        
        let profileVC = ProfileViewController()
        let profileNav = BaseNavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("profile_title", comment: ""),
            image: UIImage(systemName: "person.circle.fill"),
            tag: 1
        )
        
        let settingsVC = SettingsViewController()
        let settingsNav = BaseNavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("settings_title", comment: ""),
            image: UIImage(systemName: "gear"),
            tag: 2
        )
        
        viewControllers = [communityNav, profileNav, settingsNav]
    }
}
