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
        
        initialiseUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        
        // Check for existing Schedule in Model
        let scheduleFR = NSFetchRequest<NSManagedObject>(entityName: "ScheduleLineEntity")
        scheduleFR.sortDescriptors = [NSSortDescriptor(key: "sortKey", ascending: true)]
        
        do {
            let scheduleLineEntities = try appDelegate.stack.context.fetch(scheduleFR) as! [ScheduleLineEntity]
            
            if scheduleLineEntities.count <= 0 {
                schedule = [ScheduleLineEntity]()
                fetchSchedule()
            } else {
                schedule = scheduleLineEntities
                tableView.reloadData()
            }
        } catch _ as NSError {
            alertUserOfFailure(message: "Data load failed.")
        }
    }
    
    // UI+UX Functionality
    
    private func initialiseUI() {
        
        indicator = createIndicator()
        
        // Set up the Navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.stop,
            target: self,
            action: #selector(ScheduleViewController.returnToRoot)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.refresh,
            target: self,
            action: #selector(ScheduleViewController.fetchSchedule)
        )
        navigationItem.title = "Schedule"
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
        } else {
            
            UIApplication.shared.statusBarStyle = .default
            statusBar.backgroundColor = .white
            
            view.backgroundColor = .white
            
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = Constants.UI.Trout
            navigationController?.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor: Constants.UI.Trout
            ]
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
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.indicator.stopAnimating()
        }
    }
    
    @objc func returnToRoot() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Data Management Functions
    
    @objc func fetchSchedule() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        indicator.startAnimating()
        
        MarttinenClient.sharedInstance().getSchedule() { (scheduleRaw, localitiesRaw, error) in
            
            if error != nil {
                self.alertUserOfFailure(message: "Data download failed.")
            } else {
                
                self.appDelegate.stack.performBackgroundBatchOperation { (workerContext) in
                    
                    // Cleanup any existing data
                    let DelAllScheduleLineEntities = NSBatchDeleteRequest(
                        fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ScheduleLineEntity")
                    )
                    let DelAllLocalityEntities = NSBatchDeleteRequest(
                        fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "LocalityEntity")
                    )
                    do {
                        try workerContext.execute(DelAllScheduleLineEntities)
                        try workerContext.execute(DelAllLocalityEntities)
                    }
                    catch {
                        self.alertUserOfFailure(message: "Data load failed.")
                    }
                    
                    // Clear local properties
                    self.schedule = [ScheduleLineEntity]()
                    
                    // We have to clear data in active contexts after performing batch operations
                    self.appDelegate.stack.reset()
                    
                    DispatchQueue.main.async {
                        
                        self.parseAndSaveSchedule(scheduleRaw)
                        self.parseAndSaveLocalities(localitiesRaw)
                        
                        self.tableView.reloadData()
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.indicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    private func parseAndSaveSchedule(_ scheduleRaw: [ScheduleLine]) {
        
        for i in 0 ..< scheduleRaw.count {
            
            let scheduleLineRaw = scheduleRaw[i]
            
            let scheduleLineEntity = ScheduleLineEntity(context: self.appDelegate.stack.context)
            
            scheduleLineEntity.sortKey = Int32(i)
            scheduleLineEntity.isSunday = scheduleLineRaw.isSunday
            scheduleLineEntity.locality = scheduleLineRaw.locality
            
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
            
            self.schedule.append(scheduleLineEntity)
        }
        
        self.appDelegate.stack.save()
    }
    
    private func parseAndSaveLocalities(_ localitiesRaw: [String:Locality]) {
        
        for (key, value) in localitiesRaw {
            
            let localityEntity = LocalityEntity(context: self.appDelegate.stack.context)
            
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
                
                let photo = LocalityPhotoEntity(context: self.appDelegate.stack.context)
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
        
        self.appDelegate.stack.save()
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
        
        if appDelegate.isDark {
            cell.backgroundColor = Constants.UI.Trout
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .white
        } else {
            cell.backgroundColor = .white
            cell.textLabel?.textColor = Constants.UI.Trout
            cell.detailTextLabel?.textColor = Constants.UI.Trout
        }
        
        if scheduleLine.isSunday {
            cell.textLabel?.textColor = .red
            cell.detailTextLabel?.textColor = .red
        }
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        
        let scheduleLine = schedule[(indexPath as NSIndexPath).row]
        
        // Only load information if the ScheduleLine refers to a specific locality
        guard let key = scheduleLine.locality else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        // Fetch the corresponding locality
        let stack = appDelegate.stack
        let fr = NSFetchRequest<NSManagedObject>(entityName: "LocalityEntity")
        fr.predicate = NSPredicate(format: "key = %@", argumentArray: [key])
        
        do {
            let localityResults = try stack.context.fetch(fr) as! [LocalityEntity]
            
            if localityResults.count <= 0 || localityResults.count > 1 {
                let userInfo = [NSLocalizedDescriptionKey : "Missing locality"]
                throw NSError(domain: "ScheduleViewController", code: 1, userInfo: userInfo)
            }
            
            let locality = localityResults[0]
            
            // If we have location details, load the LocalityView
            // Otherwise, jump straight to ContactView
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
            alertUserOfFailure(message: "Data load failed.")
        }
    }
}
