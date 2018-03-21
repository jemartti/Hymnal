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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: UIActivityIndicatorView!
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
        
        initialiseUI()
        initialiseContent()
    }
    
    // MARK: UI+UX Functionality
    
    private func initialiseUI() {
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        UIApplication.shared.statusBarStyle = .default
        statusBar.backgroundColor = .white
        
        view.backgroundColor = .white
        
        indicator = createIndicator()
        
        mapView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Contact",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(LocalityViewController.contactInformation)
        )
        navigationItem.title = "Locality"
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Constants.UI.Armadillo
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: Constants.UI.Armadillo
        ]
        
        titleView.textColor = Constants.UI.Armadillo
        addressView.textColor = Constants.UI.Armadillo
        addressView.backgroundColor = .white
    }
    
    private func createIndicator() -> UIActivityIndicatorView {
        
        let indicator = UIActivityIndicatorView(
            activityIndicatorStyle: UIActivityIndicatorViewStyle.gray
        )
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubview(toFront: view)
        return indicator
    }
    
    // MARK: Content Handling
    
    private func initialiseContent() {
        
        titleView.text = locality.name
        addressView.text = "\(locality.locationAddressString)\n🚗"
        
        imageView.image = UIImage(named: locality.key)
        
        // Set up the map view
        mapView.removeAnnotations(mapView.annotations)
        let coordinate = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(locality.locationLatitude),
            longitude: CLLocationDegrees(locality.locationLongitude)
        )
        let annotation = MKPointAnnotation()
        annotation.title = "OALC of \(locality.name)"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500)
        mapView.setRegion(region, animated: false)
    }
    
    @objc func contactInformation() {
        
        let contactViewController = storyboard!.instantiateViewController(
            withIdentifier: "ContactViewController"
            ) as! ContactViewController
        contactViewController.locality = locality
        navigationController!.pushViewController(contactViewController, animated: true)
    }
    
    // Open maps with driving directions to address if user taps either the address or the pin on the map
    func openMaps() {
        
        CLGeocoder().geocodeAddressString(locality.locationAddressString, completionHandler: { (placemarks, error) in
            
            if error == nil, placemarks!.count > 0 {
                
                let placemark = placemarks![0]
                if let addressDict = placemark.addressDictionary as? [String:AnyObject],
                    let coordinate = placemark.location?.coordinate {
                    
                    let mapItem = MKMapItem(
                        placemark: MKPlacemark(
                            coordinate: coordinate,
                            addressDictionary: addressDict
                        )
                    )
                    let launchOptions = [
                        MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving
                    ]
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
