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
import CoreData

class PhotoAlbumViewController: BaseViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var requestOrDeletePhotoButton: UIButton!
    
    var requestPhoto: Bool = true
    var itemsToDelete: [Int] = []
    var photosDB: [Photo] = []
    var flickrImages: [FlickrImage]!
    var pin: Pin!
    
    var annotation: MKAnnotation!
    var dataController: DataController!
    let requester = Requester()
    var page: Int = 0
    
    deinit {
        dataController = nil
        itemsToDelete = []
        requestPhoto = true
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
        
        loadPhotosFromDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpActionButton()
    }
    
    @IBAction func requestOrDeletePhoto(_ sender: Any) {
        if requestPhoto {
            // TODO: REQUEST MORE PHOTOS
            performRequestPhotos()
        } else {
            if itemsToDelete.count > 0 {
                deletePhotos()
            }
        }
    }
    
    fileprivate func loadPhotosFromDB() {
        let fetchRequeste: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequeste.sortDescriptors = []
        fetchRequeste.predicate = NSPredicate(format: "pin == %@", pin)
    
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequeste, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
            print("Photos loaded from core data")
        } catch { }
    
        if fetchedResultsController.fetchedObjects!.count > 0 {
            photosDB = fetchedResultsController.fetchedObjects!
            collectionView.reloadData()
        } else {
            performRequestPhotos()
        }
    }
    
    // MARK: Private functions
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
        requestPhoto = itemsToDelete.count == 0 ? true : false
        
        if requestPhoto {
            requestOrDeletePhotoButton.setTitle("Request New Collection", for: .normal)
//            requestOrDeletePhotoButton.isEnabled = photosDB.count > 0 ? true : false
        } else {
            requestOrDeletePhotoButton.setTitle("Remove Selected Pictures", for: .normal)
        }
    }
    
    fileprivate func removeSelection(_ indexPath: IndexPath) {
        let indexToDelete = itemsToDelete.index(of: indexPath.row)
        itemsToDelete.remove(at: indexToDelete ?? 0)
        
        setUpActionButton()
    }
    
    // MARK: Database functions
    
    // MARK: Add Photo to Data Base
    func addPhotoToDB() {
        
        for flickrImage in flickrImages {
            let photoDB = Photo(context: dataController.viewContext)
            photoDB.imageURL = flickrImage.imageURL()
            photoDB.index = flickrImage.id
            photoDB.pin = pin
            persistToDataBase {
                self.photosDB.append(photoDB)
            }
        }
        
        collectionView.reloadData()
    }
    
    // MARK: Delete Photo from Data Base
    fileprivate func deletePhotos() {
        for item in itemsToDelete {
            if item <= photosDB.count {
                let itemToDelete = photosDB.remove(at: item)
                dataController.viewContext.delete(itemToDelete)
            } else {
                let itemToDelete = photosDB.remove(at: item - 1)
                dataController.viewContext.delete(itemToDelete)
            }
        }
        
        persistToDataBase {
            self.collectionView.reloadData()
        }
        itemsToDelete.removeAll()
        setUpActionButton()
    }
    
    fileprivate func clearDataBasePhotos() {
        for photo in photosDB {
            deleteFromDatabase(photo)
        }
        photosDB.removeAll()
    }
    
    func deleteFromDatabase(_ photo: Photo) {
        dataController.viewContext.delete(photo)
        
        persistToDataBase()
    }
    
    // MARK: Persist changes to Data Base
    fileprivate func persistToDataBase(completion: (() -> Void)? = nil) {
        do {
            try dataController.viewContext.save()
            completion?()
        } catch {
            print("Error on saving")
        }
    }
}

// MARK: Collection View Extension
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosDB.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        if photosDB[indexPath.row].imageURL != nil {
            requester.downloadImage(photosDB[indexPath.row]) { result in
                switch result {
                    
                case .success(let image):
                    cell.imageView.image = UIImage(data: image as! Data)
                case .failure(let message):
                    self.alert(message: message.localizedDescription)
                }
                
            }
        } else {
            cell.imageView.image = #imageLiteral(resourceName: "udaLogo")
        }
        
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
        setUpActionButton()
    }
}

// MARK: Network extension
extension PhotoAlbumViewController {
    func performRequestPhotos() {
        requester.getPhotosFromFlickr(latitude: annotation.coordinate.latitude,
                                      longitude: annotation.coordinate.longitude, 
                                      page: page) { result in
            switch result {
            case .success(let flickrImages):
                self.clearDataBasePhotos()
                self.setUpActionButton()
                self.page += 1
                self.flickrImages = flickrImages as? [FlickrImage]
                self.addPhotoToDB()
            case .failure(let message):
                self.alert(message: message.localizedDescription)
            }
        }
    }
}
