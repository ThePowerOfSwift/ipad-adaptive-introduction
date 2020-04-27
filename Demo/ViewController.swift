//
//  ViewController.swift
//  Demo
//
//  Created by shiwei on 2020/4/20.
//  Copyright © 2020 shiwei. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, DataModelControllerObserver {
    
    var dataModelController = DataModelController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dataModelController.drawings.isEmpty {
            dataModelController.newDrawing()
        }
        
        dataModelController.thumbnailTraitCollection = traitCollection
        
        dataModelController.observers.append(self)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        dataModelController.thumbnailTraitCollection = traitCollection
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 0]:
            performSegue(withIdentifier: "UIAdaptiveSegue", sender: nil)
        case [0, 1]:
            performSegue(withIdentifier: "DragAndDropSegue", sender: nil)
        case [0, 2]:
            performSegue(withIdentifier: "DrawingSegue", sender: nil)
        case [0, 3]:
            performSegue(withIdentifier: "SplitViewControllerSegue", sender: nil)
        case [0, 4]:
            performSegue(withIdentifier: "PDFKitSegue", sender: nil)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DrawingSegue" {
            if let viewController = segue.destination as? DrawingViewController {
                viewController.dataModelController = dataModelController
            }
        }
    }
    
    func dataModelChanged() {
        
    }
    
}

