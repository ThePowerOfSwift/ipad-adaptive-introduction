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
    
    private lazy var inProgressDataSource: DDDemoDataSource = {
        let geocaches: [Geo] = [
            Geo(name: "Old Faithful", summary: "Old Faithful is a cone geyser located in Yellowstone National Park in Wyoming, United States. It was named in 1870 during the Washburn-Langford-Doane Expedition and was the first geyser in the park to receive a name. It is a highly predictable geothermal feature, and has erupted every 44 to 125 minutes since 2000.", latitude: 44.460479, longitude: -110.828138, image: UIImage(named: "old_faithful")?.pngData()),
            Geo(name: "Statue of Liberty", summary: "The Statue of Liberty is a colossal neoclassical sculpture on Liberty Island in New York Harbor in New York, in the United States.", latitude: 40.689249, longitude: -74.0445, image: UIImage(named: "statue_of_liberty")?.pngData()),
            Geo(name: "Martin Luther King Jr. Memorial", summary: "The Martin Luther King Jr . Memorial is located in West Potomac Park next to the National Mall in Washington, D.C., United States. It covers four acres and includes the Stone of Hope, a granite statue of Civil Rights Movement leader Martin Luther King carved by sculptor Lei Yixin.", latitude: 38.886111, longitude: -77.044167, image: UIImage(named: "mlk_memorial")?.pngData()),
            Geo(name: "Colosseum", summary: "The Colosseum or Coliseum, also known as the Flavian Amphitheatre, is an oval amphitheatre in the centre of the city of Rome, Italy. Built of travertine, tuff, and brick-faced concrete, it is the largest amphitheatre ever built.", latitude: 41.89021, longitude: 12.492231, image: UIImage(named: "colosseum")?.pngData()),
            Geo(name: "Grand Canyon", summary: "Grand Canyon National Park, in Arizona, is home to much of the immense Grand Canyon, with its layered bands of red rock revealing millions of years of geological history. Viewpoints include Mather Point, Yavapai Observation Station and architect Mary Colter’s Lookout Studio and her Desert View Watchtower. Lipan Point, with wide views of the canyon and Colorado River, is a popular, especially at sunrise and sunset.", latitude: 36.055261, longitude: -112.121836, image: UIImage(named: "grand_canyon")?.pngData()),
            Geo(name: "Temple of Olympian Zeus", summary: "The Temple of Olympian Zeus, also known as the Olympieion or Columns of the Olympian Zeus, is a former colossal temple at the center of the Greek capital Athens. It was dedicated to \"Olympian\" Zeus, a name originating from his position as head of the Olympian gods.", latitude: 37.969372, longitude: 23.733078, image: UIImage(named: "olympieion")?.pngData()),
            Geo(name: "Space Needle", summary: "The Space Needle is an observation tower in Seattle, Washington, United States. It is a landmark of the Pacific Northwest and an icon of Seattle. It was built in the Seattle Center for the 1962 World's Fair, which drew over 2.3 million visitors. Nearly 20,000 people a day used its elevators during the event.", latitude: 47.6204, longitude: -122.3491, image: UIImage(named: "space_needle")?.pngData()),
            Geo(name: "Jökulsárlón Glacier Lagoon", summary: "Jökulsárlón is a glacial lagoon, bordering Vatnajökull National Park in southeastern Iceland. Its still, blue waters are dotted with icebergs from the surrounding Breiðamerkurjökull Glacier, part of larger Vatnajökull Glacier. The Glacier Lagoon flows through a short waterway into the Atlantic Ocean, leaving chunks of ice on a black sand beach. In winter, the fish-filled lagoon hosts hundreds of seals.", latitude: 64.070278, longitude: -16.211667, image: UIImage(named: "jokulsarlon")?.pngData())
        ]
        return DDDemoDataSource(geoCaches: geocaches)
    }()
    
    private var completedDataSource = DDDemoDataSource(geoCaches: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for tableView in [inProgressTableView, completedTableView] {
            if let tableView = tableView {
                tableView.dataSource = dataSourceForTableView(tableView)
                tableView.dragDelegate = self
                tableView.dropDelegate = self
            }
        }
    }

    func dataSourceForTableView(_ tableView: UITableView) -> DDDemoDataSource {
        if tableView == inProgressTableView {
            return inProgressDataSource
        } else {
            return completedDataSource
        }
    }

}

extension DDDemoViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dataSource = dataSourceForTableView(tableView)
        let dragCoordinator = CacheDragCoordinator(sourceIndexPath: indexPath)
        session.localContext = dragCoordinator
        return dataSource.dragItems(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        guard
            let dragCoordinator = session.localContext as? CacheDragCoordinator,
            dragCoordinator.dragCompleted == true,
            dragCoordinator.isReordering == false
            else { return }
        let dataSource = dataSourceForTableView(tableView)
        let sourceIndexPath = dragCoordinator.sourceIndexPath
        tableView.performBatchUpdates({
            dataSource.deleteGeo(at: sourceIndexPath.item)
            tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
        })
    }
}

extension DDDemoViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let dataSource = dataSourceForTableView(tableView)
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            destinationIndexPath = IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)
        }
        
        let item = coordinator.items[0]

        switch coordinator.proposal.operation {
        case .move:
            guard let dragCoordinator = coordinator.session.localDragSession?.localContext as? CacheDragCoordinator
                else { return }
            // Save information to calculate reordering
            if let sourceIndexPath = item.sourceIndexPath {
                print("Moving within the same table view...")
                dragCoordinator.isReordering = true
                // Update datasource and collection view
                tableView.performBatchUpdates({
                    dataSource.moveGeo(at: sourceIndexPath.row, to: destinationIndexPath.row)
                    tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                    tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                })
            } else {
                print("Moving between table views...")
                dragCoordinator.isReordering = false
                // Update datasource and collection view
                if let geocache = item.dragItem.localObject as? Geo {
                    tableView.performBatchUpdates({
                        dataSource.addGeo(geocache, at: destinationIndexPath.row)
                        tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                    })
                }
            }
            // Set flag to indicate drag completed
            dragCoordinator.dragCompleted = true
            coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
        case .copy:
            print("Copying from different app...")
          
            let itemProvider = item.dragItem.itemProvider
            // Set up the placeholder
            let context = coordinator.drop(item.dragItem, to: makePlaceholder(destinationIndexPath))
            itemProvider.loadObject(ofClass: Geo.self) { geocache, _ in
                if let geocache = geocache as? Geo {
                    DispatchQueue.main.async {
                        context.commitInsertion(dataSourceUpdates: { _ in
                            dataSource.addGeo(geocache, at: destinationIndexPath.row)
                        })
                    }
                }
            }
          
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        guard session.localDragSession != nil else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
        guard session.items.count == 1 else {
            return UITableViewDropProposal(operation: .cancel)
        }
        if let provier = session.items.first?.itemProvider {
            return UITableViewDropProposal(operation: provier.canLoadObject(ofClass: Geo.self) ? .move : .forbidden, intent: .insertAtDestinationIndexPath)
        } else {
            return UITableViewDropProposal(operation: .forbidden, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func makePlaceholder(_ destinationIndexPath: IndexPath) -> UITableViewDropPlaceholder {
        let placeholder = UITableViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: String(describing: DDDemoTableViewCell.self), rowHeight: 108)
        placeholder.cellUpdateHandler = { cell in
            if let cell = cell as? DDDemoTableViewCell {
                cell.titleLabel.text = "Loading..."
                cell.subtitleLabel.text = ""
                cell.iconImageView.image = nil
            }
        }
        return placeholder
    }
}
