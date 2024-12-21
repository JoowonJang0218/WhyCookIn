//
//  SceneDelegate.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
                   willConnectTo session: UISceneSession,
                   options connectionOptions: UIScene.ConnectionOptions) {
            
            guard let windowScene = scene as? UIWindowScene else { return }

            let window = UIWindow(windowScene: windowScene)
            
            let isLoggedIn = AuthenticationService.shared.isUserLoggedIn()
            
            if isLoggedIn {
                // Show main tab bar if user is logged in
                let tabBarController = MainTabBarController()
                window.rootViewController = tabBarController
            } else {
                // Show login if user is not logged in
                let loginVC = LoginViewController()
                // If you prefer a navigation controller for a nice title bar:
                let navVC = BaseNavigationController(rootViewController: loginVC)
                window.rootViewController = navVC
            }
            
            window.makeKeyAndVisible()
            self.window = window
        }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Clean up resources if needed
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restart tasks if needed
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Pause ongoing tasks if needed
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Undo background changes if needed
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save data, release shared resources
    }
}
