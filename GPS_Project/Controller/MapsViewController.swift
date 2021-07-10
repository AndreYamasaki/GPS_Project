//
//  MapsViewController.swift
//  GPS_Project
//
//  Created by André Yamasaki on 09/07/21.
//

import UIKit
import MapKit

class MapsViewController: UIViewController {
    
    //MARK: Attributes
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressTextField: UITextField!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var selectedAdress: Address? = nil
    var lastLocation: CLLocationCoordinate2D? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        
        if let address = selectedAdress {
            showRoute(address)
        }
    }
    
    //MARK: - Methods
    
    @IBAction func tappedShowAddress(_ sender: UIButton) {
        getPossibleTextFromText()
    }
    
    private func getPossibleTextFromText() {
        
        var address: [Address] = []
        CLGeocoder().geocodeAddressString(addressTextField.text!) { placemarks, error in
            if error == nil {
                for placemark in placemarks! {
                    address.append(self.converToAddress(placeMark: placemark))
                }
                self.showAddressTables(addresses: address)
            } else {
                let controller = UIAlertController(title: "Error", message: "Problem trying to fetch address from the text", preferredStyle: .alert)
                self.present(controller, animated: true)
            }
        }
    }
    
    private func converToAddress (placeMark: CLPlacemark) -> Address {
        
        return Address(name: placeMark.postalAddress!.street, placeMark: placeMark, postalAddress: placeMark.postalAddress!)
    }
    
    private func showAddressTables(addresses: [Address]) {
        
        let addressesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AddressesTableViewController") as! AddressesTableViewController
        addressesVC.addresses = addresses
        addressesVC.selectedAddress = { address in
            self.selectedAdress = address
        }
        self.navigationController?.pushViewController(addressesVC, animated: true)
    }
    
    private func showRoute(_ address: Address) {
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = address.placeMark.location!.coordinate
        destinationAnnotation.title = address.name
        self.mapView.addAnnotation(destinationAnnotation)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: lastLocation!))
        request.destination = MKMapItem(placemark: MKPlacemark(placemark: address.placeMark))
        request.transportType = .automobile
        
        let direction = MKDirections(request: request)
        
        direction.calculate { (response, error) in
            guard let unwrappedResponse = response else {return}
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension MapsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        self.lastLocation = location?.coordinate
        mapView.centerCoordinate = location!.coordinate
        let region = mapView.regionThatFits(MKCoordinateRegion(center: location!.coordinate, latitudinalMeters: 600.0, longitudinalMeters: 600.0))
        mapView.setRegion(region, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error)
    }
}

//MARK: - MKMapViewDelegate

extension MapsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .orange
        renderer.lineWidth = 5.0
        return renderer
    }
}
