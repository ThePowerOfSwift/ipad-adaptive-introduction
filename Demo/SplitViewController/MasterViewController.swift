//
//  MasterViewController.swift
//  Demo
//
//  Created by shiwei on 2020/4/24.
//  Copyright © 2020 shiwei. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISplitViewControllerDelegate {
    
    let monsters = [
        Monster(name: "Cat-Bot", description: "MEE-OW", iconName: "meetcatbot", weapon: .sword),
        Monster(name: "Dog-Bot", description: "BOW-WOW", iconName: "meetdogbot", weapon: .blowgun),
        Monster(name: "Explode-Bot", description: "BOOM!", iconName: "meetexplodebot", weapon: .smoke),
        Monster(name: "Fire-Bot", description: "Will Make You Steamed", iconName: "meetfirebot", weapon: .ninjaStar),
        Monster(name: "Ice-Bot", description: "Has A Chilling Effect", iconName: "meeticebot", weapon: .fire),
        Monster(name: "Mini-Tomato-Bot", description: "Extremely Handsome", iconName: "meetminitomatobot", weapon: .ninjaStar)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self
    }
    
    @IBAction func handleDismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monsters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let monster = monsters[indexPath.row]
        cell.textLabel?.text = monster.name
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let detailViewController: DetailViewController
                if let destination = segue.destination as? UINavigationController {
                    detailViewController = destination.topViewController as! DetailViewController
//                    detailViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                    detailViewController.navigationItem.leftItemsSupplementBackButton = true
                } else {
                    detailViewController = segue.destination as! DetailViewController
                }
                
                let monster = monsters[indexPath.row]
                detailViewController.monster = monster
            }
        }
    }

}
