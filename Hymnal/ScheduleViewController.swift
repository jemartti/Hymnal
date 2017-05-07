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
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set up the Navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(ScheduleViewController.returnToRoot)
        )
        navigationItem.title = "Schedule"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
        //self.updateStudentInformation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    

    
    private func alertUserOfFailure( message: String) {
        
        performUIUpdatesOnMain {
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
    
    func update() {
        
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
        
        var labelString = scheduleLine.dateString + ": "
        if let comment = scheduleLine.comment {
            labelString = labelString + comment
        } else if let localityPretty = scheduleLine.localityPretty {
            labelString = labelString + localityPretty
        }
        
        if scheduleLine.with.count > 0 {
            labelString = labelString + " (with "
            for i in 0 ..< scheduleLine.with.count {
                if i != 0 {
                    labelString = labelString + "and "
                }
                labelString = labelString + scheduleLine.with[i]
            }
            labelString = labelString + ")"
        }
        
        if let isAM = scheduleLine.am, let isPM = scheduleLine.pm {
            if isAM && isPM {
                labelString = labelString + " (AM & PM)"
            } else if isAM {
                labelString = labelString + " (AM Only)"
            } else if isPM {
                labelString = labelString + " (PM Only)"
            }
        }
        
        cell.textLabel?.text = labelString
        
        if scheduleLine.isSunday {
            cell.textLabel?.textColor = .red
        }
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        let scheduleLine = ScheduleLine.schedule[(indexPath as NSIndexPath).row]
        
        if let localityCode = scheduleLine.locality,
           let locality = Locality.localities[localityCode] {
            let localityViewController = storyboard!.instantiateViewController(
                withIdentifier: "LocalityViewController"
                ) as! LocalityViewController
            localityViewController.locality = locality
            navigationController!.pushViewController(localityViewController, animated: true)
        }
    }
    
    // MARK: Supplementary Functions
    
    func updateSchedule() {
        // Load the schedule and reload the table
        MarttinenClient.sharedInstance().getSchedule() { (error) in
            if error != nil {
                self.alertUserOfFailure(message: "Data download failed.")
            } else {
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // Displays the Create View
//    func create() {
//        let informationPostingVC = storyboard!.instantiateViewController(
//            withIdentifier: "InformationPostingViewController"
//        )
//        present(informationPostingVC, animated: true, completion: nil)
//    }
    
    func returnToRoot() {
        dismiss(animated: true, completion: nil)
    }
}
