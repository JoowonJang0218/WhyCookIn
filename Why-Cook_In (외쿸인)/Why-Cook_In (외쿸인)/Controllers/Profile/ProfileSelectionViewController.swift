//
//  ProfileSelectionViewController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import UIKit

class ProfileSelectionViewController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    
    var items: [String] = []       // Full list of available options
    private var filteredItems: [String] = []
    
    var onSelect: ((String) -> Void)?
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        filteredItems = items
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.title = LanguageManager.shared.string(forKey: "choose_option") // Add a key like "choose_option" = "Choose Option"
        
        definesPresentationContext = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        // Update text if language changes
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc private func updateText() {
        navigationItem.title = LanguageManager.shared.string(forKey: "choose_option")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        filteredItems = query.isEmpty ? items : items.filter { $0.lowercased().contains(query.lowercased()) }
        tableView.reloadData()
    }
    
    // MARK: - UITableView DataSource/Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = filteredItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let selected = filteredItems[indexPath.row]
        onSelect?(selected)
        navigationController?.popViewController(animated: true)
    }
}
