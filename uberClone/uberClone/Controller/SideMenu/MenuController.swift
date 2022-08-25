//
//  MenuController.swift
//  uberClone
//
//  Created by Михаил Щербаков on 23.08.2022.
//

import UIKit

class MenuController: UITableViewController {
    
    private let reuseIdentifier = "MenuCell"
    
    //MARK: Properties
    
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: 140)
        let view = MenuHeader(frame: frame)
        return view
    }()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
    }
    
    //MARK: Selectors
    
    //MARK: Helpers
    
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
    }
}

extension MenuController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "Menu option"
        return cell
    }
}
