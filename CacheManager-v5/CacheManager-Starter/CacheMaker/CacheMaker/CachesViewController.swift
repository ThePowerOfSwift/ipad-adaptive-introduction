/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Geocache

class CachesViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var inProgressCollectionView: UICollectionView!
    @IBOutlet weak var completedCollectionView: UICollectionView!

    // Initial in-progress geocaches are loaded from a .plist
    private lazy var inProgressDataSource: CachesDataSource = {
        guard let path = Bundle.main.path(forResource: "Geocaches", ofType: "plist")
            else {
                print("Failed to read Geocaches.plist")
                return CachesDataSource(geocaches: [])
        }

        let fileUrl = URL.init(fileURLWithPath: path)

        guard let geocachesArray = NSArray(contentsOf: fileUrl) as? [[String: Any]]
            else { return CachesDataSource(geocaches: []) }

        let geocaches: [Geocache] = geocachesArray.compactMap({ (geocache) in
            guard
                let name = geocache[Geocache.Key.name] as? String,
                let summary = geocache[Geocache.Key.summary] as? String,
                let latitude = geocache[Geocache.Key.latitude] as? Double,
                let longitude = geocache[Geocache.Key.longitude] as? Double,
                let imageName = geocache[Geocache.Key.image] as? String,
                let image = UIImage(named: imageName)?.pngData()
                else {
                    return nil
                }

            return Geocache(
                name: name, summary: summary,
                latitude: latitude, longitude: longitude, image: image)
        })
        return CachesDataSource(geocaches: geocaches)
    }()

    // Initial completed geocaches are empty
    private var completedDataSource = CachesDataSource(geocaches: [])

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        for collectionView in [inProgressCollectionView, completedCollectionView] {
            if let collectionView = collectionView {
                collectionView.dataSource = dataSourceForCollectionView(collectionView)
                collectionView.delegate = self
                collectionView.dragDelegate = self // drag delegate
                collectionView.dropDelegate = self // drop delegate
            }
        }
    }

}

// MARK: - Private methods
private extension CachesViewController {
    func dataSourceForCollectionView(
        _ collectionView: UICollectionView
    ) -> CachesDataSource {
        if collectionView == inProgressCollectionView {
            return inProgressDataSource
        } else {
            return completedDataSource
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CachesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }
}

extension CachesViewController: UICollectionViewDragDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        let dataSource = dataSourceForCollectionView(collectionView)
        return dataSource.dragItems(for: indexPath)
    }
}

extension CachesViewController: UICollectionViewDropDelegate {
    // called when the user ends a drag activity.
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        // 1. Gets the data source for the collection view.
        let dataSource = dataSourceForCollectionView(collectionView)
        // 2. Sets the end of the collection view as the item drop destination.
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            destinationIndexPath = IndexPath(item: collectionView.numberOfItems(inSection: 0), section: 0)
        }
        // 3. Selects the first drag item.
        let item = coordinator.items[0]
        // 4. Checks how you propose to handle the drop.
        switch coordinator.proposal.operation {
        case .copy:
            if let geocache = item.dragItem.localObject as? Geocache {
                print("copy from same app...")
                dataSource.addGeocache(geocache, at: destinationIndexPath.item)
                DispatchQueue.main.async {
                    collectionView.insertItems(at: [destinationIndexPath])
                }
            } else {
                print("copy from different app...")
                let itemProvider = item.dragItem.itemProvider
                // 5. Asynchronously fetchs the dragged item's data.
                itemProvider.loadObject(ofClass: NSString.self) { (string, error) in
                    if let string = string as? String {
                        // 6. Creates a new geocache with a name based on the incoming string data.
                        let geocache = Geocache(name: string, summary: "Unknown", latitude: 0.0, longitude: 0.0)
                        // 7. Adds the new geocache to the data source.
                        dataSource.addGeocache(geocache, at: destinationIndexPath.item)
                        // 8. Inserts the new item in the collection view. You invoke this on the main thread since the data fetching completion block runs on an internal queue.
                        DispatchQueue.main.async {
                            collectionView.insertItems(at: [destinationIndexPath])
                        }
                    }
                }
            }
        case .move:
            print("moving...")
            // 1. Gets the source index path which you should have access to for drag and drops within the same collection view.
            if let sourceIndexPath = item.sourceIndexPath {
                // 2. Performs batch updates to move the geocache in the data source and collection view.
                collectionView.performBatchUpdates({
                    dataSource.moveGeoCache(at: sourceIndexPath.item, to: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                // 3. Animates the insertion of the dragged geocache in the collection view.
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        default: return
        }
    }
    
    // drop session did update
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if session.localDragSession != nil {
            guard session.items.count == 1 else {
                return UICollectionViewDropProposal(operation: .cancel)
            }
            if collectionView.hasActiveDrag {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            } else {
                return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
}
