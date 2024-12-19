//
//  ChatsViewController.swift
//  WhyCookIn (외쿸인)
//
//  Created by Joowon Jang on 12/20/24.
//

import Foundation
import UIKit

class ChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var threads: [ChatThreadEntity] = []
    private var currentUser: User? {
        return AuthenticationService.shared.getCurrentUser()
    }
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Chats"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatCell")
        
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let user = AuthenticationService.shared.getCurrentUser() else { return }
        threads = DatabaseManager.shared.fetchUserThreads(for: user)
        tableView.reloadData()
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thread = threads[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        
        guard let user = currentUser,
              let otherUser = DatabaseManager.shared.getOtherUser(in: thread, currentUser: user) else {
            cell.textLabel?.text = "Unknown User"
            return cell
        }
        
        cell.textLabel?.text = "\(otherUser.firstName) \(otherUser.lastName)"
        
        return cell
    }
    
    // MARK: TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thread = threads[indexPath.row]
        // Open chat view controller for this thread
        let chatVC = ChatViewController(chatThread: thread)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
