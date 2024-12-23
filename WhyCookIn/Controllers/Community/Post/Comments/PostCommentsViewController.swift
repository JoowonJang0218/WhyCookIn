//
//  PostCommentsViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/13/24.
//

import Foundation
import UIKit

import UIKit

class PostCommentsViewController: UIViewController,
                                 UITableViewDataSource,
                                 UITableViewDelegate {
    private var post: Post
    private var comments: [Comment] = []
    private let tableView = UITableView()

    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comments"

        // 1) Register custom cell
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")

        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        // 2) Fetch comments
        comments = DatabaseManager.shared.fetchComments(for: post)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "CommentCell",
                for: indexPath
            ) as? CommentCell
        else {
            return UITableViewCell()
        }

        let comment = comments[indexPath.row]

        // Decide if current user can delete
        let canDelete = (AuthenticationService.shared.getCurrentUser()?.userID
                         == post.author.userID)

        // Configure cell
        cell.configure(with: comment, showDelete: canDelete)

        // If user can delete, wire up the deleteAction closure
        if canDelete {
            cell.deleteAction = { [weak self] in
                self?.handleDeleteComment(commentID: comment.id)
            }
        }

        return cell
    }

    // MARK: - TableView Delegate

    // Example trailing-swipe approach:
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
                   -> UISwipeActionsConfiguration? {
        let comment = comments[indexPath.row]

        // Only let the post author delete
        let canDelete = (AuthenticationService.shared.getCurrentUser()?.userID
                         == post.author.userID)
        guard canDelete else { return nil }

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            self?.handleDeleteComment(commentID: comment.id)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: - Helpers

    private func handleDeleteComment(commentID: UUID) {
        // 3) Use your DatabaseManager method
        DatabaseManager.shared.deleteComment(commentID: commentID)
        // Remove from array & reload
        comments.removeAll { $0.id == commentID }
        tableView.reloadData()
    }
}
