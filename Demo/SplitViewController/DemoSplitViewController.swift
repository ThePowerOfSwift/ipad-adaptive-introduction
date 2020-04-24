//
//  DemoSplitViewController.swift
//  Demo
//
//  Created by shiwei on 2020/4/24.
//  Copyright © 2020 shiwei. All rights reserved.
//

import UIKit

class DemoSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        preferredDisplayMode = .allVisible
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
