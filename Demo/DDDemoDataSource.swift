//
//  DDDemoDataSource.swift
//  Demo
//
//  Created by shiwei on 2020/4/22.
//  Copyright © 2020 shiwei. All rights reserved.
//

import UIKit

class DDDemoDataSource: NSObject, UITableViewDataSource {
    private var geoCaches: [Geo]
    
    init(geoCaches: [Geo]) {
        self.geoCaches = geoCaches
        super.init()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: DDDemoTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let row = indexPath.row
        if let cell = cell as? DDDemoTableViewCell, row < geoCaches.count {
            let geo = geoCaches[row]
            if let image = geo.image {
                cell.iconImageView.image = UIImage(data: image)
            } else {
                cell.iconImageView.image = nil
            }
            cell.titleLabel.text = geo.name
            cell.subtitleLabel.text = geo.summary
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return geoCaches.count
    }
    
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let geo = geoCaches[indexPath.item]
        let itemProvider = NSItemProvider(object: geo)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = geo
        return [dragItem]
    }
    
    func addGeo(_ newGeo: Geo, at index: Int) {
        geoCaches.insert(newGeo, at: index)
    }
    
    func moveGeo(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        
        let geo = geoCaches[sourceIndex]
        geoCaches.remove(at: sourceIndex)
        geoCaches.insert(geo, at: destinationIndex)
    }
    
    func deleteGeo(at index: Int) {
        geoCaches.remove(at: index)
    }
}
