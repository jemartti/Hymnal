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
    var locality: LocalityEntity!
    var photo: LocalityPhotoEntity!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    // MARK: UI+UX Functionality
    
    private func initialiseUI() {
        
        indicator = createIndicator()
        
        mapView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Contact",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(LocalityViewController.contactInformation)
        )
        navigationItem.title = "Locality"
    }
    
    private func updateUI() {
        setNightMode(to: appDelegate.isDark)
    }
    
    private func setNightMode(to enabled: Bool) {
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        
        if appDelegate.isDark != enabled {
            appDelegate.isDark = enabled
            UserDefaults.standard.set(appDelegate.isDark, forKey: "hymnIsDark")
            UserDefaults.standard.synchronize()
        }
        
        if enabled {
            
            UIApplication.shared.statusBarStyle = .lightContent
            statusBar.backgroundColor = Constants.UI.Trout
            
            view.backgroundColor = Constants.UI.Trout
            
            navigationController?.navigationBar.barTintColor = Constants.UI.Trout
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white
            ]
            
            titleView.textColor = .white
            addressView.textColor = .white
            addressView.backgroundColor = Constants.UI.Trout
        } else {
            
            UIApplication.shared.statusBarStyle = .default
            statusBar.backgroundColor = .white
            
            view.backgroundColor = .white
            
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = Constants.UI.Trout
            navigationController?.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor: Constants.UI.Trout
            ]
            
            titleView.textColor = Constants.UI.Trout
            addressView.textColor = Constants.UI.Trout
            addressView.backgroundColor = .white
        }
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
        addressView.text = "\(locality.locationAddress!)\n🚗"
        
        // If the image has been loaded, set it immediately
        // Otherwise, download the image Data and set it
        if let imageData = photo.imageData {
            imageView.image = UIImage(data: imageData as Data)
        } else if let url = photo.url {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            indicator.startAnimating()
            
            DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
                
                do {
                    let imageData = try Data(contentsOf: URL(string: url)!)
                    let image = UIImage(data: imageData)
                    
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        self.photo.imageData = imageData
                        self.appDelegate.stack.save()
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.indicator.stopAnimating()
                    }
                } catch _ as NSError {
                    DispatchQueue.main.async {
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.indicator.stopAnimating()
                    }
                }
            }
        }
        
        // Set up the map view
        mapView.removeAnnotations(mapView.annotations)
        let coordinate = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(locality.locationLatitude),
            longitude: CLLocationDegrees(locality.locationLongitude)
        )
        let annotation = MKPointAnnotation()
        annotation.title = "OALC of \(locality.name!)"
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
        
        CLGeocoder().geocodeAddressString(locality.locationAddress!, completionHandler: { (placemarks, error) in
            
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
