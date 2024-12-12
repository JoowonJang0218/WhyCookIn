//
//  PostDetailViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    private let post: Post
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 20)
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
        return lbl
    }()
    
    private let commentsPlaceholder: UILabel = {
        let lbl = UILabel()
        lbl.text = LanguageManager.shared.string(forKey: "comments_placeholder")
        lbl.textColor = .systemGray
        lbl.textAlignment = .center
        return lbl
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
        title = LanguageManager.shared.string(forKey: "add_post_detail_view")
        
        view.addSubview(titleLabel)
        view.addSubview(authorLabel)
        view.addSubview(contentLabel)
        view.addSubview(commentsPlaceholder)
        
        titleLabel.text = post.title
        authorLabel.text = "\(post.author.userID) - \(post.category)"
        contentLabel.text = post.content
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 20
        
        titleLabel.frame = CGRect(x: padding,
                                  y: view.safeAreaInsets.top + 20,
                                  width: view.frame.size.width - padding*2,
                                  height: 30)
        
        authorLabel.frame = CGRect(x: padding,
                                   y: titleLabel.frame.maxY + 5,
                                   width: view.frame.size.width - padding*2,
                                   height: 20)
        
        let contentHeight: CGFloat = 200
        contentLabel.frame = CGRect(x: padding,
                                    y: authorLabel.frame.maxY + 10,
                                    width: view.frame.size.width - padding*2,
                                    height: contentHeight)
        
        commentsPlaceholder.frame = CGRect(x: padding,
                                           y: contentLabel.frame.maxY + 20,
                                           width: view.frame.size.width - padding*2,
                                           height: 40)
    }
    
    @objc private func updateText() {
        title = LanguageManager.shared.string(forKey: "add_post_detail_view")
        commentsPlaceholder.text = LanguageManager.shared.string(forKey: "comments_placeholder")
    }
}
