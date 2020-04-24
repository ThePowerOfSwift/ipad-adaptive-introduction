//
//  CacheDragCoordinator.swift
//  Demo
//
//  Created by 施伟 on 2020/4/22.
//  Copyright © 2020 shiwei. All rights reserved.
//

import Foundation

class CacheDragCoordinator {
    // MARK: - Properties
    let sourceIndexPath: IndexPath
    var dragCompleted = false
    var isReordering = false

    // MARK: - Initialization
    init(sourceIndexPath: IndexPath) {
        self.sourceIndexPath = sourceIndexPath
    }
}
