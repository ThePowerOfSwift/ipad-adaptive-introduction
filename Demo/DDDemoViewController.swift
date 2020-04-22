//
//  DDDemoViewController.swift
//  Demo
//
//  Created by shiwei on 2020/4/22.
//  Copyright © 2020 shiwei. All rights reserved.
//

import UIKit

// Drag and Drop demo

class DDDemoViewController: UIViewController {

    @IBOutlet weak var inProgressTableView: UITableView!
    @IBOutlet weak var completedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for tableView in [inProgressTableView, completedTableView] {
            if let tableView = tableView {
                
                tableView.delegate = self
            }
        }
    }

}


