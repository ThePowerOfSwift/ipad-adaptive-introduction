//
//  DetailViewController.swift
//  Demo
//
//  Created by shiwei on 2020/4/24.
//  Copyright © 2020 shiwei. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var weaponImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    var monster: Monster? {
        didSet {
            refreshUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func refreshUI() {
        loadViewIfNeeded()
        let isPlaceholderHidden = monster == nil
        containerView.isHidden = isPlaceholderHidden
        placeholderLabel.isHidden = !isPlaceholderHidden
        
        nameLabel.text = monster?.name
        descriptionLabel.text = monster?.description
        iconImageView.image = monster?.icon
        weaponImageView.image = monster?.weapon.image
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
