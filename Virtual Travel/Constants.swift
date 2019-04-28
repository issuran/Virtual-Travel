//
//  Constants.swift
//  Virtual Travel
//
//  Created by Tiago Oliveira on 28/04/19.
//  Copyright © 2019 Tiago Oliveira. All rights reserved.
//

import Foundation

struct Constants {
    // Static variables
    static let NUMBER_OF_PHOTOS_TO_DISPLAY = 12
    
    enum HttpMethod: String {        
        case get = "GET"
    }
    
    // Network variable statics
    static let flickrBaseURL = "https://api.flickr.com/services/rest/"
    static let flickrAPIKey = "3a5b0238823407eeb462d206ce82dc07"
    static let flickrPhotosEndpoint = "flickr.photos.search"
    static let format = "json"
}
