//
//  LocalityViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 5/6/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit
import MapKit

// MARK: - LocalityViewController: UIViewController

class LocalityViewController: UIViewController {
    
    // MARK: Properties
    
    var locality: Locality!
    
    // MARK: Outlets
    
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var addressView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Actions
    
    @IBAction func addressViewTapped(_ sender: Any) {
        openMaps()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialiseContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialiseUI()
    }
    
    // MARK: UI+UX Functionality
    
    private func initialiseUI() {
        mapView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Contact",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(LocalityViewController.contactInformation)
        )
        navigationItem.title = "Locality"
    }
    
    private func initialiseContent() {
        titleView.text = locality.name
        
        // If the image has been loaded, set it immediately
        // Otherwise, download the image Data and set it
        if let url = locality.photoURL {
            DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
                if let imageData = try? Data(contentsOf: URL(string: url)!) {
                    print("Loaded image")
                    DispatchQueue.main.async {
                        print("Setting image")
                        self.imageView.image = UIImage(data: imageData)
                    }
                }
            }
        }
        
        mapView.removeAnnotations(self.mapView.annotations)
        if let rawLat = locality.locationLatitude, let rawLong = locality.locationLongitude {
            let lat = CLLocationDegrees(rawLat)
            let long = CLLocationDegrees(rawLong)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.title = "OALC of " + locality.name
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500)
            mapView.setRegion(region, animated: false)
        }
        
        var addressString = ""
        for i in 0 ..< locality.locationAddress.count {
            if i != 0 {
                addressString = addressString + "\n"
            }
            addressString = addressString + locality.locationAddress[i]
        }
        addressView.text = addressString
    }
    
    func contactInformation() {
        let contactViewController = storyboard!.instantiateViewController(
            withIdentifier: "ContactViewController"
        ) as! ContactViewController
        contactViewController.locality = locality
        navigationController!.pushViewController(contactViewController, animated: true)
    }
    
    func openMaps() {
        var addressString = ""
        for i in 0 ..< locality.locationAddress.count {
            if i != 0 {
                addressString = addressString + "\n"
            }
            addressString = addressString + locality.locationAddress[i]
        }
        
        CLGeocoder().geocodeAddressString(addressString, completionHandler: {(placemarks, error) in
            if error == nil, placemarks!.count > 0 {
                let placemark = placemarks![0]
                if let addressDict = placemark.addressDictionary as? [String:AnyObject], let coordinate = placemark.location?.coordinate {
                    let mapItem = MKMapItem(placemark:MKPlacemark(coordinate: coordinate, addressDictionary: addressDict))
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: launchOptions)
                }
            }
        })
    }
}

// MARK: - LocalityViewController: MKMapViewDelegate

extension LocalityViewController: MKMapViewDelegate {
    
    // MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect: MKAnnotationView) {
        mapView.deselectAnnotation(didSelect.annotation!, animated: false)
        openMaps()
    }
}
