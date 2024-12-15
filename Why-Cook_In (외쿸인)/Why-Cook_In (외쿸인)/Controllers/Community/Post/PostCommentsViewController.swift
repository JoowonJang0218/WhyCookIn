//
//  PostCommentsViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/13/24.
//

import Foundation
import UIKit

class PostCommentsViewController: UIViewController, UITableViewDataSource {
    private let post: Post
    private var comments: [Comment] = []
    private let tableView = UITableView()

    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comments"
        tableView.dataSource = self
        view.addSubview(tableView)
        comments = DatabaseManager.shared.fetchComments(for: post) // Implement fetchComments in DatabaseManager
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = comments[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = c.author.name
        cell.detailTextLabel?.text = c.content
        return cell
    }
}
