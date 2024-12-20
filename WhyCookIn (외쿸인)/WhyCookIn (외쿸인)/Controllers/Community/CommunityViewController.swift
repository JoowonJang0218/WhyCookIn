//
//  CommunityViewController.swift
//  Why-Cook_In (외쿸인)
//

import UIKit

class CommunityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var viewModel: CommunityViewModel!
    private var posts: [Post] = []
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    private let currentUser: User = {
        return AuthenticationService.shared.getCurrentUser()!
    }()
    
    init(viewModel: CommunityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        self.tabBarItem = UITabBarItem(
            title: LanguageManager.shared.string(forKey: "community_title"),
            image: UIImage(systemName: "person.3.fill"),
            tag: 0
        )
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddPost))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = LanguageManager.shared.string(forKey: "community_title")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        fetchAndReload()
    }
    
    @objc private func updateText() {
        title = LanguageManager.shared.string(forKey: "community_title")
        tabBarItem.title = LanguageManager.shared.string(forKey: "community_title")
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func fetchAndReload() {
        viewModel.fetchPosts { [weak self] posts in
            DispatchQueue.main.async {
                self?.posts = posts
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc private func didTapAddPost() {
        let addPostVC = AddPostViewController(viewModel: viewModel)
        addPostVC.postAddedCompletion = { [weak self] in
            self?.fetchAndReload()
        }
        let navVC = BaseNavigationController(rootViewController: addPostVC)
        navVC.modalPresentationStyle = .formSheet
        present(navVC, animated: true)
    }
    
    // MARK: TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let reactionCount = DatabaseManager.shared.getReactionsCount(for: post)
        cell.textLabel?.text = "\(post.title)\n\(post.author.firstName)  Reactions: \(reactionCount)"
        cell.textLabel?.numberOfLines = 0
        cell.accessoryView = nil
        return cell
    }

    // MARK: TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let detailVC = PostDetailViewController(post: post)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // Remove the duplicate didSelectRowAt if you had another one below
    // Also remove the didTapEmpathize and didTapComment methods if they are no longer used in this screen.
}
