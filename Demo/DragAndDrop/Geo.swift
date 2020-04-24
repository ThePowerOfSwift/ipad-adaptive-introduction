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

extension Geo: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [geoTypeId, kUTTypePNG as String, kUTTypePlainText as String]
    }
    
    func loadData(
        withTypeIdentifier typeIdentifier: String,
        forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void
    ) -> Progress? {
        if typeIdentifier == kUTTypePNG as String {
            if let image = image {
                completionHandler(image, nil)
            } else {
                completionHandler(nil, nil)
            }
        } else if typeIdentifier == kUTTypePlainText as String {
            completionHandler(name.data(using: .utf8), nil)
        } else if typeIdentifier == geoTypeId {
            do {
                let archiver = NSKeyedArchiver(requiringSecureCoding: false)
                try archiver.encodeEncodable(self, forKey: NSKeyedArchiveRootObjectKey)
                archiver.finishEncoding()
                let data = archiver.encodedData
                completionHandler(data, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        return nil
    }
}

extension Geo: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [
            geoTypeId,
            kUTTypePlainText as String
        ]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        if typeIdentifier == kUTTypePlainText as String {
            guard let name = String(data: data, encoding: .utf8) else {
                throw EncodingError.invalidData
            }
            return self.init(name: name, summary: "Unknown", latitude: 0.0, longitude: 0.0)
        } else if typeIdentifier == geoTypeId {
            do {
                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
                guard let geocache =
                    try unarchiver.decodeTopLevelDecodable(
                        Geo.self,
                        forKey: NSKeyedArchiveRootObjectKey)
                    else {
                        throw EncodingError.invalidData
                    }
                return self.init(geocache)
            } catch {
                throw EncodingError.invalidData
            }
        } else {
            throw EncodingError.invalidData
        }
    }
}
