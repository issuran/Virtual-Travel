//
//  TravelLocationsViewController.swift
//  Virtual Travel
//
//  Created by Tiago Oliveira on 27/04/19.
//  Copyright © 2019 Tiago Oliveira. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsNotification: UIButton!
    
    var shouldDeletePins = false
    
    var pinsDB: [Pin] = []
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Virtual Travel"
        setUpNavigation()
        addLongPressAction()
        fetchPins()
        
        mapView.delegate = self
    }
    
    func setUpNavigation() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editAction))
        navigationItem.rightBarButtonItem = editButton
    }
    
    @objc
    func editAction() {
        UIView .transition(with: deletePinsNotification,
                           duration: 0.4,
                           options: .transitionFlipFromBottom,
                           animations: {
                            self.deletePinsNotification.isHidden = self.shouldDeletePins
                            self.shouldDeletePins = !self.shouldDeletePins
        },
                           completion: nil)
    }
    
    // MARK: Add Pin using Long Press
    func addLongPressAction() {
        if !shouldDeletePins {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPinInLocation(longGesture:)))
            longPress.minimumPressDuration = 0.5
            
            mapView.addGestureRecognizer(longPress)
        }
    }
    
    @objc
    func addPinInLocation(longGesture: UIGestureRecognizer) {
        if !shouldDeletePins {
            if longGesture.state == .ended {
                let point = longGesture.location(in: mapView)
                let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
                
                let pin = MKPointAnnotation()
                pin.coordinate = coordinates
                
                addPinToDB(coordinates)
                
                mapView.addAnnotation(pin)
            }
        }
    }
    
    // MARK: Fetch Pins from Data Base
    func fetchPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pinsDB = result
            loadPins()
        }
    }
    
    // MARK: Load Pins
    func loadPins() {
        for pinDB in pinsDB {
            let coordinates = CLLocationCoordinate2D(latitude: pinDB.latitude, longitude: pinDB.longitude)
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            mapView.addAnnotation(pin)
        }
    }
    
    // MARK: Persist changes to Data Base
    func persistToDataBase() {
        do {
            try dataController.viewContext.save()
        } catch {
            print("Error on saving")
        }
    }
    
    // MARK: Add Pin to Data Base
    func addPinToDB(_  coordinates: CLLocationCoordinate2D) {
        let pinDB = Pin(context: dataController.viewContext)
        pinDB.latitude = coordinates.latitude
        pinDB.longitude = coordinates.longitude
        pinsDB.append(pinDB)
        
        persistToDataBase()
    }
    
    // MARK: Delete Pin from Data Base
    func delete(_ pin: Pin, andFromMap annotation: MKAnnotation) {
        dataController.viewContext.delete(pin)
        mapView.removeAnnotation(annotation)
        
        persistToDataBase()
    }
}

extension TravelLocationsViewController: MKMapViewDelegate {
    
    // MARK: Go to Photo Album
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoSegue" {
            let photoViewController = segue.destination as! PhotoAlbumViewController
            let annotationView = sender as! MKAnnotationView
            if let annotation = annotationView.annotation {
                photoViewController.annotation = annotation
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !shouldDeletePins {
            performSegue(withIdentifier: "photoSegue", sender: view)
        } else {
            if let annotation = view.annotation {
                for pin in pinsDB {
                    if pin.latitude == annotation.coordinate.latitude && pin.longitude == annotation.coordinate.longitude {
                        delete(pin, andFromMap: annotation)
                        break
                    }
                }
            }
        }
        mapView.deselectAnnotation(view.annotation, animated: false)
    }
}
