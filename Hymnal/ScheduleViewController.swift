//
//  ScheduleViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 5/6/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit
import CoreData

// MARK: - ScheduleViewController: UITableViewController

class ScheduleViewController: UITableViewController {
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: UIActivityIndicatorView!
    var schedule: [ScheduleLineEntity]!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = createIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initialiseUI()
        
        let stack = appDelegate.stack
        
        // Load existing Schedule
        let scheduleFR = NSFetchRequest<NSManagedObject>(entityName: "ScheduleLineEntity")
        scheduleFR.sortDescriptors = [NSSortDescriptor(key: "sortKey", ascending: true)]
        //let localityFR = NSFetchRequest<NSManagedObject>(entityName: "LocalityEntity")
        do {
            let scheduleLineEntities = try stack.context.fetch(scheduleFR) as! [ScheduleLineEntity]
            //let localityEntities = try stack.context.fetch(localityFR) as! [LocalityEntity]
            
            if scheduleLineEntities.count <= 0 {
                schedule = [ScheduleLineEntity]()
                fetchSchedule()
            } else {
                print("Loaded from CoreData")
                schedule = scheduleLineEntities
            }
        } catch _ as NSError {
            self.alertUserOfFailure(message: "Data load failed.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    // UI+UX Functionality
    
    private func initialiseUI() {
        // Set up the Navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.stop,
            target: self,
            action: #selector(ScheduleViewController.returnToRoot)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.refresh,
            target: self,
            action: #selector(ScheduleViewController.updateSchedule)
        )
        navigationItem.title = "Schedule"
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    // MARK: Data Management Functions
    
    private func fetchSchedule() {

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        indicator.startAnimating()
        
        MarttinenClient.sharedInstance().getSchedule() { (scheduleRaw, localitiesRaw, error) in
            if error != nil {
                self.alertUserOfFailure(message: "Data download failed.")
            } else {
                
                self.appDelegate.stack.performBackgroundBatchOperation { (workerContext) in
                    
                    for i in 0 ..< scheduleRaw.count {
                        let scheduleLineEntity = ScheduleLineEntity(context: workerContext)
                    
                        let scheduleLineRaw = scheduleRaw[i]
                    
                        scheduleLineEntity.sortKey = Int32(i)
                        
                        var titleString = scheduleLineRaw.dateString + ": "
                        if let status = scheduleLineRaw.status {
                            titleString = titleString + status
                        } else if let localityPretty = scheduleLineRaw.localityPretty {
                            titleString = titleString + localityPretty
                        }
                        scheduleLineEntity.title = titleString
                        
                        var subtitleString = ""
                        if scheduleLineRaw.with.count > 0 {
                            subtitleString = subtitleString + "(with "
                            for i in 0 ..< scheduleLineRaw.with.count {
                                if i != 0 {
                                    subtitleString = subtitleString + " and "
                                }
                                subtitleString = subtitleString + scheduleLineRaw.with[i]
                            }
                            subtitleString = subtitleString + ")"
                        }
                        
                        if let isAM = scheduleLineRaw.am, let isPM = scheduleLineRaw.pm {
                            if subtitleString != "" {
                                subtitleString = subtitleString + " "
                            }
                            if isAM && isPM {
                                subtitleString = subtitleString + "(AM & PM)"
                            } else if isAM {
                                subtitleString = subtitleString + "(AM Only)"
                            } else if isPM {
                                subtitleString = subtitleString + "(PM Only)"
                            }
                        }
                        
                        if let comment =  scheduleLineRaw.comment {
                            if subtitleString != "" {
                                subtitleString = subtitleString + " "
                            }
                            subtitleString = subtitleString + "(" + comment + ")"
                        }
                        
                        scheduleLineEntity.subtitle = subtitleString
                        
                        scheduleLineEntity.isSunday = scheduleLineRaw.isSunday
                        
                        scheduleLineEntity.locality = scheduleLineRaw.locality
                        
                        self.schedule.append(scheduleLineEntity)
                    }
                    
                    for (key, value) in localitiesRaw {
                        let localityEntity = LocalityEntity(context: workerContext)
                        
                        localityEntity.key = key
                        
                        localityEntity.churchPhone = value.churchPhone
                        localityEntity.contactEmail = value.contactEmail
                        localityEntity.contactName = value.contactName
                        localityEntity.contactPhone = value.contactPhone
                        localityEntity.name = value.name
                        
                        
                        
                        if let locationLatitude = value.locationLatitude,
                            let locationLongitude = value.locationLongitude,
                            let photoURL = value.photoURL {
                            localityEntity.locationLatitude = locationLatitude
                            localityEntity.locationLongitude = locationLongitude
                            
                            let photo = LocalityPhotoEntity(context: workerContext)
                            photo.url = photoURL
                            localityEntity.localityPhoto = photo
                            
                            localityEntity.hasLocationDetails = true
                        } else {
                            localityEntity.locationLatitude = 0
                            localityEntity.locationLongitude = 0
                            localityEntity.hasLocationDetails = false
                        }
                        
                        
                        var locationAddressString = ""
                        for i in 0 ..< value.locationAddress.count {
                            if i != 0 {
                                locationAddressString = locationAddressString + "\n"
                            }
                            locationAddressString = locationAddressString + value.locationAddress[i]
                        }
                        localityEntity.locationAddress = locationAddressString
                        
                        var mailingAddressString = ""
                        for i in 0 ..< value.mailingAddress.count {
                            if i != 0 {
                                mailingAddressString = mailingAddressString + "\n"
                            }
                            mailingAddressString = mailingAddressString + value.mailingAddress[i]
                        }
                        localityEntity.mailingAddress = mailingAddressString
                    }
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.indicator.stopAnimating()
                        
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: Table View Data Source
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
        return schedule.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ScheduleLineTableViewCell"
        )!
        
        let scheduleLine = schedule[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = scheduleLine.title!
        cell.detailTextLabel?.text = scheduleLine.subtitle!
        
        if scheduleLine.isSunday {
            cell.textLabel?.textColor = .red
            cell.detailTextLabel?.textColor = .red
        } else {
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        }
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        let scheduleLine = schedule[(indexPath as NSIndexPath).row]
        
        guard let key = scheduleLine.locality else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let stack = appDelegate.stack
        let fr = NSFetchRequest<NSManagedObject>(entityName: "LocalityEntity")
        fr.predicate = NSPredicate(format: "key = %@", argumentArray: [key])
        do {
            let localityResults = try stack.context.fetch(fr) as! [LocalityEntity]
            
            if localityResults.count <= 0 || localityResults.count > 1 {
                let userInfo = [NSLocalizedDescriptionKey : "Missing locality"]
                throw NSError(domain: "VTAlbumViewController", code: 1, userInfo: userInfo)
            }
            
            let locality = localityResults[0]
            
            if locality.hasLocationDetails {
                let localityViewController = storyboard!.instantiateViewController(
                    withIdentifier: "LocalityViewController"
                    ) as! LocalityViewController
                localityViewController.locality = locality
                localityViewController.photo = locality.localityPhoto
                navigationController!.pushViewController(localityViewController, animated: true)
            } else {
                let contactViewController = storyboard!.instantiateViewController(
                    withIdentifier: "ContactViewController"
                    ) as! ContactViewController
                contactViewController.locality = locality
                navigationController!.pushViewController(contactViewController, animated: true)
            }
        } catch _ as NSError {
            self.alertUserOfFailure(message: "Data load failed.")
        }
    }
    
    // MARK: Supplementary Functions
    
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
    
    private func alertUserOfFailure( message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: "Action Failed",
                message: message,
                preferredStyle: UIAlertControllerStyle.alert
            )
            alertController.addAction(UIAlertAction(
                title: "Dismiss",
                style: UIAlertActionStyle.default,
                handler: nil
            ))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func updateSchedule() {
    }
    
    func returnToRoot() {
        dismiss(animated: true, completion: nil)
    }
}
