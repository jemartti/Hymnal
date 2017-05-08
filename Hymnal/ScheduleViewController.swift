//
//  ScheduleViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 5/6/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

// MARK: - ScheduleViewController: UITableViewController

class ScheduleViewController: UITableViewController {
    
    // MARK: Properties
    
    var indicator: UIActivityIndicatorView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = createIndicator()
        fetchSchedule()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initialiseUI()
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
        
        MarttinenClient.sharedInstance().getSchedule() { (error) in
            if error != nil {
                self.alertUserOfFailure(message: "Data download failed.")
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.indicator.stopAnimating()
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func fetchLocalities() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        indicator.startAnimating()
        
        MarttinenClient.sharedInstance().getLocalities() { (error) in
            if error != nil {
                self.alertUserOfFailure(message: "Data download failed.")
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.indicator.stopAnimating()
                }
            }
        }
    }
    
    // MARK: Table View Data Source
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
        return ScheduleLine.schedule.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ScheduleLineTableViewCell"
            )!
        let scheduleLine = ScheduleLine.schedule[(indexPath as NSIndexPath).row]
        
        var titleString = scheduleLine.dateString + ": "
        if let status = scheduleLine.status {
            titleString = titleString + status
        } else if let localityPretty = scheduleLine.localityPretty {
            titleString = titleString + localityPretty
        }
        cell.textLabel?.text = titleString
        
        var subtitleString = ""
        if scheduleLine.with.count > 0 {
            subtitleString = subtitleString + "(with "
            for i in 0 ..< scheduleLine.with.count {
                if i != 0 {
                    subtitleString = subtitleString + " and "
                }
                subtitleString = subtitleString + scheduleLine.with[i]
            }
            subtitleString = subtitleString + ")"
        }
        
        if let isAM = scheduleLine.am, let isPM = scheduleLine.pm {
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
        
        if let comment = scheduleLine.comment {
            if subtitleString != "" {
                subtitleString = subtitleString + " "
            }
            subtitleString = subtitleString + "(" + comment + ")"
        }
        
        cell.detailTextLabel?.text = subtitleString
        
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
        let scheduleLine = ScheduleLine.schedule[(indexPath as NSIndexPath).row]
        
        fetchLocalities()
        
        if let localityCode = scheduleLine.locality, let locality = Locality.localities[localityCode] {
            // If we have location data, load the locality view
            // Otherwise load the contact view
            if let _ = locality.locationLatitude, let _ = locality.locationLongitude, let _ = locality.photoURL {
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
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
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
        // Load the schedule and reload the table
        MarttinenClient.sharedInstance().getSchedule() { (error) in
            if error != nil {
                self.alertUserOfFailure(message: "Data download failed.")
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func returnToRoot() {
        dismiss(animated: true, completion: nil)
    }
}
