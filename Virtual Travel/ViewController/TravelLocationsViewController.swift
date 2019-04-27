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
    
    var locations = [CLLocation]()
    var pins = [MKAnnotation]()
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
                let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                locations.append(location)
                
                let pin = MKPointAnnotation()
                pin.coordinate = coordinates
                pins.append(pin)
                
                mapView.addAnnotation(pin)
            }
        }
    }
    
    func fetchPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pinsDB = result
            self.mapView.removeAnnotations(pins)
        }
    }
}

extension TravelLocationsViewController: MKMapViewDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoSegue" {
            let photoViewController = segue.destination as! PhotoAlbumViewController
            let annotationView = sender as! MKAnnotationView
            photoViewController.annotationView = annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !shouldDeletePins {
            performSegue(withIdentifier: "photoSegue", sender: view)
        } else {
            if let annotation = view.annotation {
                mapView.removeAnnotation(annotation)
            }
        }
        mapView.deselectAnnotation(view.annotation, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for pinDB in pinsDB {
            let point = CGPoint(x: pinDB.latitude, y: pinDB.longitude)
            let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
            
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            pins.append(pin)
            
            mapView.addAnnotation(pin)
        }
    }
}
