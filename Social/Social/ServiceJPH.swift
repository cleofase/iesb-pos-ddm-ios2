//
//  ServiceJPHModel.swift
//  Social
//
//  Created by Cleofas Pereira on 30/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import Foundation

struct JPHUser: Codable {
    var id: Int
    var name: String
    var username: String
    var email: String
    var address: JPHAddress
    var phone: String
    var website: String
    var company: JPHCompany
}
struct JPHAddress: Codable {
    var street: String
    var suite: String
    var city: String
    var zipcode: String
    var geo: JPHGeo
}
struct JPHGeo: Codable {
    var lat: String
    var lng: String
}
struct JPHCompany: Codable {
    var name: String
    var catchPhrase: String
    var bs: String
}
struct JPHAlbum: Codable {
    var userId: Int
    var id: Int
    var title: String
}
struct JPHPhoto: Codable {
    var albumId: Int
    var id: Int
    var title: String
    var url: String
    var thumbnailUrl: String
}
    
struct RESTDefinitions {
    static var urlSessionConfiguration: URLSessionConfiguration {
        get {
            let urlSessionConfiguration = URLSessionConfiguration.default
            urlSessionConfiguration.allowsCellularAccess = true
            urlSessionConfiguration.networkServiceType = .default
            urlSessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad
            urlSessionConfiguration.isDiscretionary = true
            urlSessionConfiguration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 4096, diskPath: NSTemporaryDirectory())
            return urlSessionConfiguration
        }
    }
    
    static func uriUsers() -> URL {
        return URL(string: "https://jsonplaceholder.typicode.com/users")!
    }
    
    static func uriAlbums(withUser identifier: Int32) -> URL {
        return URL(string: "https://jsonplaceholder.typicode.com/users/\(identifier)/Albums")!
    }
    
    static func uriPhotos(withAlbum identifier: Int32) -> URL {
        return URL(string: "https://jsonplaceholder.typicode.com/albums/\(identifier)/photos")!
    }
}

