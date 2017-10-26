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
    var delegate: AddressFromMapDelegate?
    
    var locationAddress: CLLocation?
    
    @IBOutlet weak var addressMapView: MKMapView! {
        didSet {
            addressMapView.showsUserLocation = true
            addressMapView.delegate = self
            
            let gestures = addressMapView.gestureRecognizers?.filter{(gestureRecognizer) in gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self)}
            if gestures == nil || gestures?.count == 0 {
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_: )))
                addressMapView.addGestureRecognizer(longPressGesture)
            }
        }
    }
    
    fileprivate func addAddressMark(at location: CLLocation) {
        let oldsAdressMark = addressMapView.annotations.filter{(annotation) in
            return annotation.isKind(of: MKPointAnnotation.self)
        }
        addressMapView.removeAnnotations(oldsAdressMark)
        
        if let _ = locationAddress {
            let addressMark = MKPointAnnotation()
            addressMark.title = "Endereço"
            addressMark.coordinate = location.coordinate
            addressMapView.addAnnotation(addressMark)
        }

    }
    
    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let pressPoint = sender.location(in: addressMapView)
            let addressLocationCordinate = addressMapView.convert(pressPoint, toCoordinateFrom: addressMapView)
            locationAddress = CLLocation(latitude: addressLocationCordinate.latitude, longitude: addressLocationCordinate.longitude)
            addAddressMark(at: locationAddress!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if locationAddress == nil {
            locationManager.startUpdatingLocation()
        } else {
            addAddressMark(at: locationAddress!)
            let addressLocationCamera = MKMapCamera(lookingAtCenter: locationAddress!.coordinate, fromDistance: 1000, pitch: 0, heading: 0)
            addressMapView.setCamera(addressLocationCamera, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let _ = delegate, let _ = locationAddress {
            delegate?.addressFromMap(didUpdateAddressFromMap: locationAddress!)
        }
    }
    
    override func viewDidLoad() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
}

extension AddressFromMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKPointAnnotation.self) {
            let viewForAddressMark = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "reuseAddressMark")
            viewForAddressMark.isDraggable = true
            return viewForAddressMark
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .ending {
            locationAddress = CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
        }
    }
}

extension AddressFromMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.stopUpdatingLocation()
            let userLocationCamera = MKMapCamera(lookingAtCenter: locations.last!.coordinate, fromDistance: 1000, pitch: 0, heading: 0)
            addressMapView.setCamera(userLocationCamera, animated: true)
        }
    }
}
