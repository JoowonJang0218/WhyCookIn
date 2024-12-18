//
//  AllUsersViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/19/24.
//

import Foundation
import UIKit

class AllUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var users: [User] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "All Users"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fetch the latest users each time view appears
        users = DatabaseManager.shared.fetchAllUsers()
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(user.email) | \(user.firstName) \(user.lastName)"
        return cell
    }

    // Optional: Add swipe to delete functionality
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = users[indexPath.row]
            DatabaseManager.shared.deleteUser(email: user.email)
            users = DatabaseManager.shared.fetchAllUsers()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
