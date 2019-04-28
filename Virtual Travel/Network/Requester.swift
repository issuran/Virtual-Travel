
//
//  Requester.swift
//  Virtual Travel
//
//  Created by Tiago Oliveira on 28/04/19.
//  Copyright © 2019 Tiago Oliveira. All rights reserved.
//

import Foundation

class Requester {
    
    typealias Handler = (Result<Any?, NSError>) -> Void
    
    enum Result<Value, Error: NSError> {
        case success(Value)
        case failure(NSError)
    }
    
    func getPhotosFromFlickr(latitude: Double,
                             longitude: Double,
                             page: Int = 1,
                             completion: @escaping Handler) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest/"
        components.queryItems = [
            URLQueryItem(name: "method", value: "\(Constants.flickrPhotosEndpoint)"),
            URLQueryItem(name: "api_key", value: "\(Constants.flickrAPIKey)"),
            URLQueryItem(name: "lat", value: "\(latitude)"),
            URLQueryItem(name: "lon", value: "\(longitude)"),
            URLQueryItem(name: "per_page", value: "\(Constants.NUMBER_OF_PHOTOS_TO_DISPLAY)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "format", value: "\(Constants.format)")
        ]
        
        let url = components.url
        var request = URLRequest(url: url!)
        request.httpMethod = Constants.HttpMethod.get.rawValue
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                if let data = data {
                    // Remove response not parseable [eg. jsonFlickrApi( .. )]
                    let range = Range(uncheckedBounds: (14, data.count - 1))
                    let newData = data.subdata(in: range)
                    
                    var flickrImages: [FlickrImage] = []
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: newData) as? [String:Any],
                            let photosMeta = json["photos"] as? [String:Any],
                            let photos = photosMeta["photo"] as? [Any] {
                            
                            for photo in photos {
                                if let flickrImage = photo as? [String: Any],
                                    let id = flickrImage["id"] as? String,
                                    let secret = flickrImage["secret"] as? String,
                                    let server = flickrImage["server"] as? String,
                                    let farm = flickrImage["farm"] as? Int {
                                    
                                    flickrImages.append(FlickrImage(id: id, secret: secret, server: server, farm: farm))
                                }
                            }
                            completion(.success(flickrImages))
                        } else {
                            completion(.failure(NSError.init(domain: "Failure on parsing", code: 400, userInfo: nil)))
                        }
                    } catch {
                        completion(.failure(NSError.init(domain: "Failure creating Flickr Image array", code: 400, userInfo: nil)))
                    }
                } else {
                    completion(.failure(error! as NSError))
                }
            }
        }
        task.resume()
    }
}
