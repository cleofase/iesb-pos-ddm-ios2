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
