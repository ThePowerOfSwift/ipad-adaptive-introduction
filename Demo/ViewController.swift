//
//  ViewController.swift
//  Demo
//
//  Created by shiwei on 2020/4/20.
//  Copyright © 2020 shiwei. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 0]:
            performSegue(withIdentifier: "UIAdaptiveSegue", sender: nil)
        case [0, 1]:
            performSegue(withIdentifier: "DragAndDropSegue", sender: nil)
        case [0, 3]:
            performSegue(withIdentifier: "SplitViewControllerSegue", sender: nil)
        default:
            break
        }
    }
}

