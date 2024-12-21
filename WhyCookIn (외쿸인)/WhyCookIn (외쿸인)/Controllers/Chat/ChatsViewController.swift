//
//  ChatsViewController.swift
//  WhyCookIn (외쿸인)
//
//  Created by Joowon Jang on 12/20/24.
//

import Foundation
import UIKit

class ChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var threads: [ChatThreadEntity] = []
    private let tableView = UITableView()
    
    // Current user from your authentication system
    private var currentUser: User? {
        return AuthenticationService.shared.getCurrentUser()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Chats"
        
        // Set up the table
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatCell")
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //reloadDataFromDatabase()
        tableView.reloadData()
        reloadThreads()
        
        // Check each thread if there's a request from the other user
        // to delete for both sides
        guard let user = currentUser else { return }
        for thread in threads {
            // If the other user requested it, we prompt this user
            if let requestID = thread.deleteForBothRequestedBy,
               requestID != user.userID,      // means the *other* user is the one who requested
               thread.deleteForBothApproved == false {
                
                let alert = UIAlertController(
                    title: "Delete Request",
                    message: "The other user wants to delete this chat for both sides.\nDo you approve?",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Approve", style: .destructive, handler: { [weak self] _ in
                    guard let self = self else { return }
                    DatabaseManager.shared.confirmDeleteForBoth(
                        thread: thread,
                        approvingUserID: requestID,
                        approved: true
                    )
                    self.reloadThreads() // thread might be removed entirely
                }))
                
                alert.addAction(UIAlertAction(title: "Reject", style: .cancel, handler: { [weak self] _ in
                    guard let self = self else { return }
                    DatabaseManager.shared.confirmDeleteForBoth(
                        thread: thread,
                        approvingUserID: requestID,
                        approved: false
                    )
                    self.reloadThreads() // keep the thread
                }))
                
                present(alert, animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        let thread = threads[indexPath.row]
        
        guard
            let user = currentUser,
            let otherUser = DatabaseManager.shared.getOtherUser(in: thread, currentUser: user)
        else {
            cell.textLabel?.text = "Unknown User"
            return cell
        }
        
        // Show a blue dot if this thread has unread messages
        let hasUnread = DatabaseManager.shared.threadHasUnreadMessage(for: thread, currentUser: user)
        cell.accessoryView = hasUnread ? makeBlueDotView() : nil
        
        // Show the other user's name
        cell.textLabel?.text = otherUser.firstName
        cell.textLabel?.textColor = .label
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let thread = threads[indexPath.row]
        guard let user = currentUser else { return }
        
        // Mark all messages as read for the current user
        DatabaseManager.shared.markAllMessagesAsRead(in: thread, for: user)
        
        // Open the chat screen
        let chatVC = ChatViewController(chatThread: thread)
        navigationController?.pushViewController(chatVC, animated: true)
        
        // Reload threads so the blue dot disappears if it was unread
        reloadThreads()
    }
    
    // MARK: - Swipe to Delete
    
    // Provide trailing swipe actions (right-to-left swipe)
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self,
                  let currentUser = self.currentUser else {
                completion(false)
                return
            }
            let thread = self.threads[indexPath.row]
            
            let alert = UIAlertController(
                title: "Delete Chat",
                message: "Do you want to delete this chat just for yourself or request to delete for both sides?",
                preferredStyle: .actionSheet
            )
            
            // Option 1: Hide the thread only for me
            alert.addAction(UIAlertAction(title: "Delete for Me", style: .default, handler: { _ in
                DatabaseManager.shared.hideThreadForUser(thread: thread, userID: currentUser.userID)
                self.reloadThreads()
            }))
            
            // Option 2: Request a delete for both
            alert.addAction(UIAlertAction(title: "Delete for Both", style: .destructive, handler: { _ in
                DatabaseManager.shared.requestDeleteForBoth(thread: thread, requestingUserID: currentUser.userID)
                // Possibly show "Request sent" message
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self.present(alert, animated: true)
            
            completion(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    // MARK: - Helpers
    
    private func reloadThreads() {
        guard let user = currentUser else { return }
        threads = DatabaseManager.shared.fetchUserThreads(for: user)
        tableView.reloadData()
    }
    
    private func makeBlueDotView() -> UIView {
        let dotSize: CGFloat = 10
        let dotView = UIView(frame: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
        dotView.backgroundColor = .systemBlue
        dotView.layer.cornerRadius = dotSize / 2
        dotView.layer.masksToBounds = true
        return dotView
    }
}
