//
//  LocalityViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 5/6/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import Contacts
import MapKit
import UIKit

// MARK: - LocalityViewController: UIViewController

class LocalityViewController: UIViewController {
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: UIActivityIndicatorView!
    var locality: Locality!
    
    var impactGenerator: UIImpactFeedbackGenerator? = nil
    
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
        
        view.backgroundColor = .white
        
        indicator = createIndicator()
        
        mapView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Contact",
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(LocalityViewController.contactInformation)
        )
        navigationItem.title = "Locality"
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Constants.UI.Armadillo
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Constants.UI.Armadillo
        ]
        
        titleView.textColor = Constants.UI.Armadillo
        addressView.textColor = Constants.UI.Armadillo
        addressView.backgroundColor = .white
    }
    
    private func createIndicator() -> UIActivityIndicatorView {
        
        let indicator = UIActivityIndicatorView(
            style: UIActivityIndicatorView.Style.gray
        )
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
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
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
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
        impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactGenerator?.prepare()
        
        CLGeocoder().geocodeAddressString(locality.locationAddressString, completionHandler: { (placemarks, error) in
            
            if error == nil,
                let placemarks = placemarks,
                placemarks.count > 0,
                let location = placemarks[0].location,
                let postalAddress = placemarks[0].postalAddress
            {
                self.impactGenerator?.impactOccurred()
                
                let mkPlacemark = MKPlacemark(
                    coordinate: location.coordinate,
                    postalAddress: postalAddress
                )
                let mapItem = MKMapItem(placemark: mkPlacemark)
                let launchOptions = [
                    MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving
                ]
                mapItem.openInMaps(launchOptions: launchOptions)
            }
            
            self.impactGenerator = nil
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
