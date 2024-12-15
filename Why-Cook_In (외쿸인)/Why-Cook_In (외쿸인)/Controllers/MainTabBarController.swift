//
//  MainTabBarController.swift
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        
        let lm = LanguageManager.shared
        
        // Create each view controller in the desired order:
        // 1. Profile
        let profileVC = ProfileDetailViewController(user: AuthenticationService.shared.getCurrentUser()!)
        let profileNav = BaseNavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: lm.string(forKey: "profile_title"),
            image: UIImage(systemName: "person.circle.fill"),
            tag: 0
        )

        // 2. Community
        let communityVM = CommunityViewModel()
        let communityVC = CommunityViewController(viewModel: communityVM)
        let communityNav = BaseNavigationController(rootViewController: communityVC)
        communityNav.tabBarItem = UITabBarItem(
            title: lm.string(forKey: "community_title"),
            image: UIImage(systemName: "person.3.fill"),
            tag: 1
        )

        // 3. Restaurants
        let restaurantVC = RestaurantSearchViewController() // Make sure this VC exists
        let restaurantNav = BaseNavigationController(rootViewController: restaurantVC)
        // localize if desired by adding keys or keep English
        restaurantNav.tabBarItem = UITabBarItem(
            title: "Restaurants",
            image: UIImage(systemName: "fork.knife"),
            tag: 2
        )

        // 4. Korean Practice
        let koreanVC = KoreanPracticeViewController() // Make sure this VC exists
        let koreanNav = BaseNavigationController(rootViewController: koreanVC)
        koreanNav.tabBarItem = UITabBarItem(
            title: "Korean Practice",
            image: UIImage(systemName: "character.book.closed.fill"),
            tag: 3
        )

        // 5. Clubs
        let clubsVC = ClubsViewController() // Make sure this VC exists
        let clubsNav = BaseNavigationController(rootViewController: clubsVC)
        clubsNav.tabBarItem = UITabBarItem(
            title: "Clubs",
            image: UIImage(systemName: "person.2.circle.fill"),
            tag: 4
        )
        
        // 6. Immigration
        let immigrationVC = UIViewController() // Replace with a real ImmigrationViewController
        immigrationVC.view.backgroundColor = .systemBackground
        immigrationVC.title = "Immigration"
        let immigrationNav = BaseNavigationController(rootViewController: immigrationVC)
        immigrationNav.tabBarItem = UITabBarItem(
            title: "Immigration",
            image: UIImage(systemName: "airplane"),
            tag: 5
        )

        // 7. Banking
        let bankingVC = UIViewController() // Replace with a real BankingViewController
        bankingVC.view.backgroundColor = .systemBackground
        bankingVC.title = "Banking"
        let bankingNav = BaseNavigationController(rootViewController: bankingVC)
        bankingNav.tabBarItem = UITabBarItem(
            title: "Banking",
            image: UIImage(systemName: "banknote"),
            tag: 6
        )

        // 8. Settings (always last)
        let settingsVC = SettingsViewController()
        let settingsNav = BaseNavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: lm.string(forKey: "settings_title"),
            image: UIImage(systemName: "gear"),
            tag: 7
        )

        // Set the view controllers in the desired order
        viewControllers = [
            profileNav,
            communityNav,
            restaurantNav,
            koreanNav,
            clubsNav,
            immigrationNav,
            bankingNav,
            settingsNav
        ]

        // Now, because we have more than 5 view controllers,
        // the first 5 (Profile, Community, Restaurants, Korean Practice, Clubs)
        // appear as main tabs, and the rest (Immigration, Banking, Settings)
        // go under "More" tab automatically.

        updateText()
    }

    @objc private func updateText() {
        let lm = LanguageManager.shared
        // Update the first 5 tab titles if keys available
        if let vcs = viewControllers, vcs.count >= 5 {
            let profileNav = vcs[0] as! UINavigationController
            profileNav.tabBarItem.title = lm.string(forKey: "profile_title")

            let communityNav = vcs[1] as! UINavigationController
            communityNav.tabBarItem.title = lm.string(forKey: "community_title")

            // For Restaurants, Korean Practice, Clubs, Immigration, Banking, Settings:
            // If you want them localized, add keys in LanguageManager and update similarly.
            // If not, leave them as is.
        }
    }
}
