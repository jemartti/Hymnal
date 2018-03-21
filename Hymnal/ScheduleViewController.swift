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
        
        // Check if it's time to update the schedule
        var forceFetch = false
        if !UserDefaults.standard.bool(forKey: "hasFetchedSchedule") {
            forceFetch = true
        } else {
            let lastScheduleFetch = UserDefaults.standard.double(forKey: "lastScheduleFetch")
            if (lastScheduleFetch + 60*60*24 < NSDate().timeIntervalSince1970) {
                forceFetch = true
            }
        }
        
        // Check for existing Schedule in Model
        let scheduleFR = NSFetchRequest<NSManagedObject>(entityName: "ScheduleLineEntity")
        scheduleFR.sortDescriptors = [NSSortDescriptor(key: "sortKey", ascending: true)]
        
        do {
            let scheduleLineEntities = try appDelegate.stack.context.fetch(scheduleFR) as! [ScheduleLineEntity]
            
            if scheduleLineEntities.count <= 0 || forceFetch {
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
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        UIApplication.shared.statusBarStyle = .default
        statusBar.backgroundColor = .white
        
        view.backgroundColor = .white
        
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
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Constants.UI.Trout
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: Constants.UI.Trout
        ]
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
        
        MarttinenClient.sharedInstance().getSchedule() { (scheduleRaw, error) in
            
            if error != nil {
                self.alertUserOfFailure(message: "Data download failed.")
            } else {
                
                self.appDelegate.stack.performBackgroundBatchOperation { (workerContext) in
                    
                    // Cleanup any existing data
                    let DelAllScheduleLineEntities = NSBatchDeleteRequest(
                        fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ScheduleLineEntity")
                    )
                    do {
                        try workerContext.execute(DelAllScheduleLineEntities)
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
                        
                        self.tableView.reloadData()
                        
                        UserDefaults.standard.set(true, forKey: "hasFetchedSchedule")
                        UserDefaults.standard.set(NSDate().timeIntervalSince1970, forKey: "lastScheduleFetch")
                        UserDefaults.standard.synchronize()
                        
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
            if let missionaries = scheduleLineRaw.missionaries {
                subtitleString = subtitleString + missionaries
            }
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
        cell.backgroundColor = .white
        cell.textLabel?.textColor = Constants.UI.Trout
        cell.detailTextLabel?.textColor = Constants.UI.Trout
        
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
        
        // Protect against missing locality
        guard let locality = Directory.directory!.localities[key] else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        // If we have location details, load the LocalityView
        // Otherwise, jump straight to ContactView
        if locality.hasLocationDetails {
            
            let localityViewController = storyboard!.instantiateViewController(
                withIdentifier: "LocalityViewController"
                ) as! LocalityViewController
            localityViewController.locality = locality
            navigationController!.pushViewController(localityViewController, animated: true)
        } else {
            
            let contactViewController = storyboard!.instantiateViewController(
                withIdentifier: "ContactViewController"
                ) as! ContactViewController
            contactViewController.locality = locality
            navigationController!.pushViewController(contactViewController, animated: true)
        }
    }
}
