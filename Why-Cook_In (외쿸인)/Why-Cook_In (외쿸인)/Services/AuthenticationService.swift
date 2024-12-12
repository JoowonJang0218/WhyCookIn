//
//  AuthenticationService.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import Foundation

class AuthenticationService {
    static let shared = AuthenticationService()
    
    private init() {}
    
    private var currentUser: User?
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            // Simulate a delay
            sleep(1)
            let success = DatabaseManager.shared.verifyUser(email: email, password: password)
            if success {
                self.currentUser = DatabaseManager.shared.fetchUser(email: email)
            }
            completion(success)
        }
    }
    
    func logout() {
        currentUser = nil
    }
    
    func isUserLoggedIn() -> Bool {
        return currentUser != nil
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func signUp(email: String, password: String, name: String, userID: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            sleep(1)
            let success = DatabaseManager.shared.addUser(email: email, password: password, name: name, userID: userID)
            if success {
                self.currentUser = DatabaseManager.shared.fetchUser(email: email)
            }
            completion(success)
        }
    }

}
