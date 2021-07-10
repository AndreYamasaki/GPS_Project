//
//  MapsViewController.swift
//  GPS_Project
//
//  Created by André Yamasaki on 09/07/21.
//

import UIKit
import MapKit

class MapsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
    }
}

extension MapsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        mapView.centerCoordinate = location!.coordinate
        let region = mapView.regionThatFits(MKCoordinateRegion(center: location!.coordinate, latitudinalMeters: 600.0, longitudinalMeters: 600.0))
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error)
    }
}
