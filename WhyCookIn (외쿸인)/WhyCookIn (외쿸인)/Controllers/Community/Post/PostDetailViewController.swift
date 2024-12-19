//
//  PostDetailViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

/*
 THINGS TO WORK ON

 */

import UIKit

class PostDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let post: Post
    private var comments: [Comment] = []
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 24)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let authorLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let contentLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 16)
        return lbl
    }()
    
    private let empathizeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("I feel this shit", for: .normal)
        return btn
    }()
    
    private let reactionCountLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let tableView = UITableView()
    private let commentField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add a comment..."
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let addCommentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Comment", for: .normal)
        btn.layer.cornerRadius = 8
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()
    
    private let currentUser: User = {
        return AuthenticationService.shared.getCurrentUser()!
    }()
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("PostDetailViewController must be initialized with a post")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Post"
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        
        titleLabel.text = post.title
        authorLabel.text = post.author.userID.uuidString
        contentLabel.text = post.content
        
        empathizeButton.addTarget(self, action: #selector(didTapEmpathize), for: .touchUpInside)
        addCommentButton.addTarget(self, action: #selector(didTapAddComment), for: .touchUpInside)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        [titleLabel, authorLabel, contentLabel, empathizeButton, reactionCountLabel, tableView, commentField, addCommentButton].forEach {
            view.addSubview($0)
        }

        fetchComments()
        updateReactionCount()
    }
    
    @objc private func updateText() {
        // If any localized strings needed, update them here
        // Currently the buttons have English text, localize if you add keys.
    }
    
    private func fetchComments() {
        comments = DatabaseManager.shared.fetchComments(for: post)
        tableView.reloadData()
    }
    
    private func updateReactionCount() {
        let count = DatabaseManager.shared.getReactionsCount(for: post)
        reactionCountLabel.text = "Reactions: \(count)"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        let width = view.frame.size.width - padding*2
        
        var y = view.safeAreaInsets.top + padding
        
        titleLabel.frame = CGRect(x: padding, y: y, width: width, height: titleLabel.intrinsicContentSize.height)
        y += titleLabel.frame.height + 5
        
        authorLabel.frame = CGRect(x: padding, y: y, width: width, height: 20)
        y += 25
        
        let contentHeight = contentLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
        contentLabel.frame = CGRect(x: padding, y: y, width: width, height: contentHeight)
        y += contentHeight + 20
        
        empathizeButton.frame = CGRect(x: padding, y: y, width: 150, height: 44)
        reactionCountLabel.frame = CGRect(x: empathizeButton.frame.maxX + 10, y: y, width: width - (empathizeButton.frame.width + 10), height: 44)
        y += 64
        
        // TableView for comments takes up most space
        let bottomBarHeight: CGFloat = 44 + 10 + 44 // space for commentField and addCommentButton
        let tableHeight = view.frame.height - y - bottomBarHeight - view.safeAreaInsets.bottom - padding
        tableView.frame = CGRect(x: padding, y: y, width: width, height: tableHeight)
        y += tableHeight + 10
        
        commentField.frame = CGRect(x: padding, y: y, width: width - 100, height: 44)
        addCommentButton.frame = CGRect(x: commentField.frame.maxX + 5, y: y, width: 80, height: 44)
    }
    
    @objc private func didTapEmpathize() {
        DatabaseManager.shared.empathizePost(post, by: currentUser)
        updateReactionCount()
    }
    
    @objc private func didTapAddComment() {
        guard let text = commentField.text, !text.isEmpty else { return }
        DatabaseManager.shared.addComment(to: post, author: currentUser, content: text)
        commentField.text = ""
        fetchComments()
    }
    
    // MARK: TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = comments[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = c.author.userID.uuidString
        cell.detailTextLabel?.text = c.content
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
}
