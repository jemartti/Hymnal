//
//  DirectoryViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 11/7/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit
import CoreData

// MARK: - DirectoryViewController: UITableViewController

class DirectoryViewController: UITableViewController {
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var directory: [Locality]!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialiseUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        directory = Array(Directory.directory!.localities.map{ $0.value })
        directory.sort { $0.name < $1.name }
        
        tableView.reloadData()
    }
    
    // UI+UX Functionality
    
    private func initialiseUI() {
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        UIApplication.shared.statusBarStyle = .default
        statusBar.backgroundColor = .white
        
        view.backgroundColor = .white
        
        // Set up the Navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.stop,
            target: self,
            action: #selector(DirectoryViewController.returnToRoot)
        )
        navigationItem.title = "Directory"
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Constants.UI.Trout
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: Constants.UI.Trout
        ]
    }
    
    @objc func returnToRoot() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Table View Data Source
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
        
        return directory.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "DirectoryLineTableViewCell"
            )!
        
        let directoryLine = directory[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = directoryLine.name
        cell.backgroundColor = .white
        cell.textLabel?.textColor = Constants.UI.Trout
        cell.detailTextLabel?.textColor = Constants.UI.Trout
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        
        let locality = directory[(indexPath as NSIndexPath).row]
            
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

