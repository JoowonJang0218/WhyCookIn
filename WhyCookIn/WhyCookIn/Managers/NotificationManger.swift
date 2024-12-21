//
//  NotificationManger.swift
//  WhyCookIn (외쿸인)
//
//  Created by Joowon Jang on 12/21/24.
//

import Foundation
import UIKit
import UserNotifications
import UserNotificationsUI
import CoreData

/// A singleton manager to handle both local (in-app) notification badges
/// and push notification registration and handling.
final class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
    }
    
    // MARK: - 1. Request Notification Permission (Local + Push)
    /// Call this early in your app’s lifecycle (e.g. in AppDelegate’s didFinishLaunching)
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self  // So we can handle in-app presentation
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        center.requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Request authorization error: \(error)")
            }
            print("Notification permission granted? \(granted)")
        }
    }
    
    // MARK: - 2. Register for Remote Notifications
    /// Typically called in AppDelegate after requesting permission.
    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: - 3. Handle Device Token
    /// This is typically forwarded from AppDelegate’s didRegisterForRemoteNotifications.
    func updateDeviceToken(_ deviceToken: Data) {
        // Convert token to string
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Received APNs device token: \(tokenString)")
        
        // TODO: send tokenString to your server to store under the current user
    }
    
    // MARK: - 4. Local "Badge" or In-App Red Dot for Unread
    /// Recalculate how many unread messages the current user has and
    /// update your app’s tab bar badge or other UI elements.
    func updateUnreadBadge() {
        guard let currentUser = AuthenticationService.shared.getCurrentUser() else {
            clearBadge()
            return
        }
        
        let unreadCount = DatabaseManager.shared.getUnreadCountForAllThreads(for: currentUser)
        DispatchQueue.main.async {
            if unreadCount > 0 {
                // For example, if “Chats” is at index 1:
                if let tabBarController = UIApplication.shared.keyWindowRootTabBarController() {
                    tabBarController.tabBar.items?[1].badgeValue = "\(unreadCount)"
                }
                // Also set the app badge on the icon if you want:
                UIApplication.shared.applicationIconBadgeNumber = unreadCount
                //UNUserNotificationCenter.setBadgeCount(unreadCount)
            } else {
                self.clearBadge()
            }
        }
    }
    
    private func clearBadge() {
        // Clear any tab bar badge
        if let tabBarController = UIApplication.shared.keyWindowRootTabBarController() {
            tabBarController.tabBar.items?[1].badgeValue = nil
        }
        // Clear the app icon badge to zero
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("Failed to clear badge: \(error)")
            }
        }
    }
    
    // MARK: - 5. Present Local Notification In-App if you want
    /// If you want to show a banner/alert while app is in foreground
    func showInAppAlert(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        // “.alert” triggers a banner or alert if allowed by user’s settings
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil  // Immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("In-App alert error: \(error)")
            }
        }
    }
    
    // MARK: - 6. Handle Notification Tap or In-Foreground Presentation
    /// Called if the app is in the foreground (iOS 10+).
    /// Decide how you want to present a notification while active.
    /// e.g., show banner, play sound, etc.
    private func handleForegroundNotification(_ notification: UNNotification) {
        // If you want to show as banner even if the user is in the app:
        // UNNotificationPresentationOptions can be: .alert, .sound, .badge, .banner
    }
    
    /// Called when user taps a notification or performs an action.
    private func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        // e.g. if you included "threadID" or "customData" in the payload
        if userInfo["threadID"] is String {
            // Navigate user to the specific chat, etc.
            // Possibly convert threadID to a UUID or fetch from DB.
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    /// Called when a notification arrives *while the app is in the foreground*.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Decide how to present this if your app is open
        handleForegroundNotification(notification)
        completionHandler([.sound, .banner, .badge]) // or .alert for older style
    }
    
    /// Called when the user taps the notification or performs an action from it.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotificationResponse(response)
        completionHandler()
    }
}

// MARK: - Helper extension to get TabBarController
private extension UIApplication {
    func keyWindowRootTabBarController() -> UITabBarController? {
        // For iOS 13+, you might have multiple scenes.
        // This is a naive approach that looks for the keyWindow's rootViewController.
        
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let tabBar = window.rootViewController as? UITabBarController else {
            return nil
        }
        return tabBar
    }
}
