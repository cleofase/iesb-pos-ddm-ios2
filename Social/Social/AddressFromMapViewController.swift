//
//  AddressFromMapViewController.swift
//  Social
//
//  Created by Cleofas Pereira on 09/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AddressFromMapViewController: UIViewController {
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var addressMapView: MKMapView! {
        didSet {
            addressMapView.showsUserLocation = true
            
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAddressMark(_: )))
            addressMapView.addGestureRecognizer(longPressGesture)
        }
    }
    
    @objc private func addAddressMark(_ sender: UILongPressGestureRecognizer) {
        print("toque longo...")
        
        
        var addressMark = MKPointAnnotation()
        addressMark.title = "Endereço"
        addressMark.subtitle = ""
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
}



extension AddressFromMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            let userLocationCamera = MKMapCamera(lookingAtCenter: locations.last!.coordinate, fromDistance: 1000, pitch: 0, heading: 0)
            addressMapView.setCamera(userLocationCamera, animated: true)
        }
    }
}
