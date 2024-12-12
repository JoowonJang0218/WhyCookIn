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
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let categoryPicker = UIPickerView()
    private var categories: [String] = []
    
    private let addCategoryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    private let newCategoryField: UITextField = {
        let tf = UITextField()
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
        UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
        
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
        
        updateText()
    }
    
    @objc private func updateText() {
        let lm = LanguageManager.shared
        title = lm.string(forKey: "add_post_title")
        titleField.placeholder = lm.string(forKey: "post_title_placeholder")
        categoryLabel.text = lm.string(forKey: "category_label")
        addCategoryButton.setTitle(lm.string(forKey: "add_category_button"), for: .normal)
        newCategoryField.placeholder = lm.string(forKey: "new_category_placeholder")
        saveButton.title = lm.string(forKey: "save_button")
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
        let lm = LanguageManager.shared
        guard let currentUser = AuthenticationService.shared.getCurrentUser() else {
            dismiss(animated: true)
            return
        }
        
        guard let title = titleField.text, !title.isEmpty else {
            // Show alert: no title
            let alert = UIAlertController(title: lm.string(forKey: "error_title"),
                                          message: lm.string(forKey: "empty_fields_error"),
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
            category = "category_general"
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
        let categoryKey = categories[row]
        return LanguageManager.shared.string(forKey: categoryKey)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let categoryKey = categories[row]
        if categoryKey == "category_suggest_new" {
            newCategoryField.isHidden = false
            addCategoryButton.isHidden = false
        } else {
            newCategoryField.isHidden = true
            addCategoryButton.isHidden = true
        }
    }

}
