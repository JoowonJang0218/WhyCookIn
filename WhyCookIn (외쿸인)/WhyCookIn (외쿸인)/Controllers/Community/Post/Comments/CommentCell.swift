//
//  CommentCell.swift
//  WhyCookIn (외쿸인)
//
//  Created by Joowon Jang on 12/xx/24.
//

import UIKit

class CommentCell: UITableViewCell {
    
    var deleteAction: (() -> Void)?  // Called when user taps “Delete” in this cell
    
    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Delete", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        return btn
    }()
    
    // Whether to show/hide the delete button
    var showDeleteButton: Bool = false {
        didSet {
            deleteButton.isHidden = !showDeleteButton
        }
    }
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(deleteButton)
        deleteButton.addTarget(self,
                               action: #selector(didTapDelete),
                               for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Position the delete button on the right edge
        let buttonWidth: CGFloat = 60
        let buttonHeight: CGFloat = 30
        
        deleteButton.frame = CGRect(
            x: contentView.bounds.width - buttonWidth - 16,
            y: (contentView.bounds.height - buttonHeight) / 2,
            width: buttonWidth,
            height: buttonHeight
        )
    }
    
    @objc private func didTapDelete() {
        deleteAction?()
    }
    
    // Called from cellForRow:
    func configure(with comment: Comment, showDelete: Bool) {
        textLabel?.text = comment.content
        showDeleteButton = showDelete
    }
}
