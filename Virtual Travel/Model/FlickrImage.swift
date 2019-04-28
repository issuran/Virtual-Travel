//
//  FlickrImage.swift
//  Virtual Travel
//
//  Created by Tiago Oliveira on 28/04/19.
//  Copyright © 2019 Tiago Oliveira. All rights reserved.
//

import Foundation

class FlickrImage: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
    
    init(id: String, secret: String, server: String, farm: Int) {
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
    }
    
    func imageURL() -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
    }
}
