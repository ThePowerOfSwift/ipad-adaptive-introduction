//
//  Geo.swift
//  Demo
//
//  Created by shiwei on 2020/4/22.
//  Copyright © 2020 shiwei. All rights reserved.
//

import Foundation
import MobileCoreServices

let geoTypeId = "com.shiwei.geo"

enum EncodingError: Error {
    case invalidData
}

class Geo: NSObject, Codable {
    
    enum Key {
        static let name = "name"
        static let summary = "summary"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let image = "imageName"
    }
    
    // MARK: - Properties
    var name: String
    var summary: String
    var latitude: Double
    var longitude: Double
    var image: Data?
    
    required init(
        name: String,
        summary: String,
        latitude: Double,
        longitude: Double,
        image: Data? = nil
    ) {
        self.name = name
        self.summary = summary
        self.latitude = latitude
        self.longitude = longitude
        self.image = image
    }
    
    required init(_ geo: Geo) {
        self.name = geo.name
        self.summary = geo.summary
        self.latitude = geo.latitude
        self.longitude = geo.longitude
        self.image = geo.image
        super.init()
    }
}
