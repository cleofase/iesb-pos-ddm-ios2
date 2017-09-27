//
//  User.swift
//  Social
//
//  Created by Cleofas Pereira on 24/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//
/*
 "id": 2,
 "name": "Ervin Howell",
 "username": "Antonette",
 "email": "Shanna@melissa.tv",
 "address": {
 "street": "Victor Plains",
 "suite": "Suite 879",
 "city": "Wisokyburgh",
 "zipcode": "90566-7771",
 "geo": {
 "lat": "-43.9509",
 "lng": "-34.4618"
 }
 },
 "phone": "010-692-6593 x09125",
 "website": "anastasia.net",
 "company": {
 "name": "Deckow-Crist",
 "catchPhrase": "Proactive didactic contingency",
 "bs": "synergize scalable supply-chains"
*/

import Foundation
import CoreData

struct User: Codable {
    var id: Int
    var name: String
    var username: String
}
