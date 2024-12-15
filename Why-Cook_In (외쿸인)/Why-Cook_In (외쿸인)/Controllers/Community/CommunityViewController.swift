//
//  CommunityViewController.swift
//  Why-Cook_In (외쿸인)
//

/*
 TODO
 */

import UIKit

class CommunityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var viewModel: CommunityViewModel!
    private var posts: [Post] = []
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    init(viewModel: CommunityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(
            title: LanguageManager.shared.string(forKey: "community_title"),
            image: UIImage(systemName: "person.3.fill"),
            tag: 0
        )
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddPost))
    }
    
    required init?(coder: NSCoder) {
        fatalError("CommunityViewController should be initialized with a view model")
    }
    
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
    
    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(post.author.userID) - [\(post.category)] \(post.title)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let detailVC = PostDetailViewController(post: post)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
