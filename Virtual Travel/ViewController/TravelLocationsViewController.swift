//
//  TravelLocationsViewController.swift
//  Virtual Travel
//
//  Created by Tiago Oliveira on 27/04/19.
//  Copyright © 2019 Tiago Oliveira. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var locations = [CLLocation]()
    var pins = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Virtual Travel"
        setUpNavigation()
        addLongPressAction()
        
        mapView.delegate = self
    }
    
    func setUpNavigation() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editAction))
        navigationItem.rightBarButtonItem = editButton
    }
    
    @objc
    func editAction() {
        print("Edit map")
    }
    
    func addLongPressAction() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPinInLocation(longGesture:)))
        longPress.minimumPressDuration = 1.0
        
        mapView.addGestureRecognizer(longPress)
    }
    
    @objc
    func addPinInLocation(longGesture: UIGestureRecognizer) {
        let point = longGesture.location(in: mapView)
        let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        locations.append(location)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        pins.append(pin)
        
        mapView.addAnnotation(pin)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoSegue" {
            let photoViewController = segue.destination as! PhotoAlbumViewController
            let annotationView = sender as! MKAnnotationView
            photoViewController.annotationView = annotationView
        }
    }
}

extension TravelLocationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "photoSegue", sender: view)
    }
}
