//
//  ChatViewController.swift
//  WhyCookIn (외쿸인)
//
//  Created by Joowon Jang on 12/20/24.
//

import Foundation
import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    private let chatThread: ChatThreadEntity
    
    // Data source for messages
    private var messages: [MessageEntity] = []
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.allowsSelection = false
        return tv
    }()
    
    // Create a container for input field and send button
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    private let messageTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Type a message..."
        return tf
    }()
    
    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        return btn
    }()
    
    init(chatThread: ChatThreadEntity) {
        self.chatThread = chatThread
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Chat"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(messageTextField)
        inputContainerView.addSubview(sendButton)
        
        messageTextField.delegate = self
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        
        // Fetch messages from DB
        messages = DatabaseManager.shared.fetchMessages(for: chatThread)
        tableView.reloadData()
        scrollToBottom()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let inputHeight: CGFloat = 50
        inputContainerView.frame = CGRect(x: 0,
                                          y: view.frame.size.height - view.safeAreaInsets.bottom - inputHeight,
                                          width: view.frame.size.width,
                                          height: inputHeight)
        
        let padding: CGFloat = 8
        let buttonWidth: CGFloat = 60
        
        sendButton.frame = CGRect(x: inputContainerView.frame.size.width - padding - buttonWidth,
                                  y: (inputHeight - 36)/2,
                                  width: buttonWidth,
                                  height: 36)
        
        messageTextField.frame = CGRect(x: padding,
                                        y: (inputHeight - 36)/2,
                                        width: inputContainerView.frame.size.width - buttonWidth - padding*3,
                                        height: 36)
        
        tableView.frame = CGRect(x: 0, y: 0,
                                 width: view.frame.size.width,
                                 height: inputContainerView.frame.origin.y)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let msg = messages[indexPath.row]
        
        // You may want to customize cell UI:
        // For simplicity, just show the content
        cell.textLabel?.text = msg.content
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    @objc private func didTapSend() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        guard let currentUser = AuthenticationService.shared.getCurrentUser() else { return }
        
        // Send message through DatabaseManager
        DatabaseManager.shared.sendMessage(in: chatThread, from: currentUser, content: text) { [weak self] success in
            guard let self = self else { return }
            if success {
                // Refetch messages and reload
                self.messages = DatabaseManager.shared.fetchMessages(for: self.chatThread)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom()
                    self.messageTextField.text = nil
                }
            } else {
                // Handle error if needed
            }
        }
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let lastIndex = IndexPath(row: messages.count-1, section: 0)
        tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardFrame.height
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.3
        UIView.animate(withDuration: duration) {
            self.inputContainerView.frame.origin.y = self.view.frame.size.height - self.view.safeAreaInsets.bottom - keyboardHeight - self.inputContainerView.frame.size.height
            self.tableView.frame.size.height = self.inputContainerView.frame.origin.y
        }
        scrollToBottom()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.3
        UIView.animate(withDuration: duration) {
            self.inputContainerView.frame.origin.y = self.view.frame.size.height - self.view.safeAreaInsets.bottom - self.inputContainerView.frame.size.height
            self.tableView.frame.size.height = self.inputContainerView.frame.origin.y
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}
