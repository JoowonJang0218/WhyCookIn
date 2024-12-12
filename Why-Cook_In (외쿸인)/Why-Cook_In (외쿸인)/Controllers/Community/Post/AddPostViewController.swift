//
//  AddPostViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import UIKit

class AddPostViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var postAddedCompletion: (() -> Void)?
    private var viewModel: CommunityViewModel
    
    // Category label
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("category_label", comment: "")
        label.textAlignment = .left
        return label
    }()

    init(viewModel: CommunityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("AddPostViewController must be initialized with a viewModel")
    }
    
    private let titleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = NSLocalizedString("post_title_placeholder", comment: "")
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let categoryPicker = UIPickerView()
    private var categories: [String] = []
    private let addCategoryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("add_category_button", comment: ""), for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()
    private let newCategoryField: UITextField = {
        let tf = UITextField()
        tf.placeholder = NSLocalizedString("new_category_placeholder", comment: "")
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.borderColor = UIColor.secondaryLabel.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        return tv
    }()
    
    private let saveButton: UIBarButtonItem = {
        UIBarButtonItem(
            title: NSLocalizedString("save_button", comment: ""),
            style: .done,
            target: nil,
            action: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("add_post_title", comment: "")
        
        view.addSubview(titleField)
        view.addSubview(categoryLabel)
        view.addSubview(categoryPicker)
        view.addSubview(newCategoryField)
        view.addSubview(addCategoryButton)
        view.addSubview(textView)
        
        addCategoryButton.addTarget(self, action: #selector(didTapAddCategory), for: .touchUpInside)
        
        saveButton.target = self
        saveButton.action = #selector(didTapSave)
        navigationItem.rightBarButtonItem = saveButton
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        categories = DatabaseManager.shared.fetchCategories()
        
        // Initially hide newCategoryField and addCategoryButton
        newCategoryField.isHidden = true
        addCategoryButton.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 44
        
        titleField.frame = CGRect(x: padding,
                                  y: view.safeAreaInsets.top + 20,
                                  width: view.frame.size.width - padding*2,
                                  height: fieldHeight)
        
        categoryLabel.frame = CGRect(x: padding,
                                     y: titleField.frame.maxY + 10,
                                     width: 200,
                                     height: 30)
        
        categoryPicker.frame = CGRect(x: padding,
                                      y: categoryLabel.frame.maxY + 10,
                                      width: view.frame.size.width - padding*2,
                                      height: 100)
        
        newCategoryField.frame = CGRect(x: padding,
                                        y: categoryPicker.frame.maxY + 10,
                                        width: view.frame.size.width - padding*2,
                                        height: fieldHeight)
        
        addCategoryButton.frame = CGRect(x: padding,
                                         y: newCategoryField.frame.maxY + 10,
                                         width: view.frame.size.width - padding*2,
                                         height: fieldHeight)
        
        textView.frame = CGRect(x: padding,
                                y: addCategoryButton.frame.maxY + 10,
                                width: view.frame.size.width - padding*2,
                                height: 200)
    }
    
    @objc private func didTapAddCategory() {
        guard let newCat = newCategoryField.text, !newCat.isEmpty else { return }
        DatabaseManager.shared.addCategory(newCat)
        categories = DatabaseManager.shared.fetchCategories()
        categoryPicker.reloadAllComponents()
    }
    
    @objc private func didTapSave() {
        guard let currentUser = AuthenticationService.shared.getCurrentUser() else {
            dismiss(animated: true)
            return
        }
        
        guard let title = titleField.text, !title.isEmpty else {
            // Show alert: no title
            let alert = UIAlertController(title: NSLocalizedString("error_title", comment: ""),
                                          message: NSLocalizedString("empty_fields_error", comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let content = textView.text ?? ""
        let selectedCategoryIndex = categoryPicker.selectedRow(inComponent: 0)
        
        // Safely get the category from the array
        let category: String
        if selectedCategoryIndex >= 0 && selectedCategoryIndex < categories.count {
            category = categories[selectedCategoryIndex]
        } else {
            category = "General"
        }
        
        viewModel.addPost(title: title, content: content, category: category, author: currentUser)
        dismiss(animated: true) { [weak self] in
            self?.postAddedCompletion?()
        }
    }
    
    // MARK: - UIPickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return categories[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let chosen = categories[row]
        // If chosen is "주원에게 새로운 범주 건의하기", show newCategoryField and addCategoryButton
        if chosen == "주원에게 새로운 범주 건의하기" {
            newCategoryField.isHidden = false
            addCategoryButton.isHidden = false
        } else {
            newCategoryField.isHidden = true
            addCategoryButton.isHidden = true
        }
    }
}
