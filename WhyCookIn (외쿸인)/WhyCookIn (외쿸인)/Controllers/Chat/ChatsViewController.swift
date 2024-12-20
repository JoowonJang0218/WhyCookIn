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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("ChatsViewController init")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        print("ChatsViewController loadView")
    }
    
    private var currentUser: User? {
        return AuthenticationService.shared.getCurrentUser()
    }
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChatsViewController viewDidLoad")
        view.backgroundColor = .systemBackground
        title = "Chats"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatCell")
        view.addSubview(tableView)
        
        // Initially fetch threads when the view loads
        if let user = currentUser {
            threads = DatabaseManager.shared.fetchUserThreads(for: user)
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ChatsViewController viewWillAppear")
        guard let user = AuthenticationService.shared.getCurrentUser() else {
            print("No current user in ChatsViewController viewWillAppear")
            return
        }
        threads = DatabaseManager.shared.fetchUserThreads(for: user)
        print("Threads fetched in viewWillAppear: \(threads.count)")
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print("viewWillAppear in \(self), threads: \(threads.count)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ChatsViewController viewDidAppear")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows in section: \(threads.count)")
        return threads.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        
        guard let currentUser = currentUser else {
            cell.textLabel?.text = "No Current User"
            return cell
        }
        
        let thread = threads[indexPath.row]
        if let otherUser = DatabaseManager.shared.getOtherUser(in: thread, currentUser: currentUser) {
            cell.textLabel?.text = "\(otherUser.firstName)"
        } else {
            cell.textLabel?.text = "Unknown User"
        }
        cell.textLabel?.textColor = .label
        
        return cell
    }
    
    // MARK: TableView Delegate
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let thread = threads[indexPath.row]
        // Open chat view controller for this thread
        let chatVC = ChatViewController(chatThread: thread)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
