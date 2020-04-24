//
//  Monster.swift
//  Demo
//
//  Created by shiwei on 2020/4/24.
//  Copyright © 2020 shiwei. All rights reserved.
//

import UIKit

enum Weapon {
    case blowgun, ninjaStar, fire, sword, smoke
    
    var image: UIImage {
        switch self {
        case .blowgun:
            return UIImage(named: "blowgun")!
        case .ninjaStar:
            return UIImage(named: "fire")!
        case .fire:
            return UIImage(named: "ninjastar")!
        case .smoke:
            return UIImage(named: "smoke")!
        case .sword:
            return UIImage(named: "sword")!
        }
    }
}

class Monster {
    let name: String
    let description: String
    let iconName: String
    let weapon: Weapon
    
    init(name: String, description: String, iconName: String, weapon: Weapon) {
        self.name = name
        self.description = description
        self.iconName = iconName
        self.weapon = weapon
    }
    
    var icon: UIImage? {
        return UIImage(named: iconName)
    }
}
