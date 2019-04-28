//
//  PhotoAlbumViewController.swift
//  Virtual Travel
//
//  Created by Tiago Oliveira on 27/04/19.
//  Copyright © 2019 Tiago Oliveira. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var requestOrDeletePhotoButton: UIButton!
    
    var requestPhoto: Bool = true
    var itemsToDelete: [Int] = []
    var annotation: MKAnnotation!
    
    fileprivate func setUpFlowLayout() {
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / space
        
        // Space between items
        flowLayout.minimumInteritemSpacing = space
        // Space between rows
        flowLayout.minimumLineSpacing = space
        // Cell's size
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    fileprivate func setUpMapViewPin() {
        let coordinates = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        // Zoom
        mapView.setCenter(coordinates, animated: true)
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let coordinateRegion = MKCoordinateRegion(center: coordinates, span: coordinateSpan)
        mapView.setRegion(coordinateRegion, animated: true)
        
        // Add Pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
    }
    
    fileprivate func setUpActionButton() {
        if requestPhoto {
            requestOrDeletePhotoButton.setTitle("New Collection", for: .normal)
        } else {
            requestOrDeletePhotoButton.setTitle("Remove Selected Pictures", for: .normal)
        }
    }
    
    func removeSelection(_ indexPath: IndexPath) {
        let indexToDelete = itemsToDelete.index(of: indexPath.row)
        itemsToDelete.remove(at: indexToDelete ?? 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        mapView.delegate = self
        
        // Setup
        setUpFlowLayout()
        setUpMapViewPin()
        setUpActionButton()
    }
    
    @IBAction func requestOrDeletePhoto(_ sender: Any) {
        if requestPhoto {
            // Request new collection
        } else {
            // Delete selected photos
        }
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.image = #imageLiteral(resourceName: "udaLogo")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.contains(indexPath) {
                collectionView.deselectItem(at: indexPath, animated: true)
                removeSelection(indexPath)
                return false
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemsToDelete.append(indexPath.row)
    }
}
