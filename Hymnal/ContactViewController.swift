//
//  ContactViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 5/6/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

// MARK: - ContactViewController: UIViewController

class ContactViewController: UIViewController {
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var locality: Locality!
    
    // MARK: Outlets
    
    @IBOutlet weak var mailingAddressLabel: UILabel!
    @IBOutlet weak var mailingAddressView: UITextView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactNameView: UITextView!
    @IBOutlet weak var contactPhoneLabel: UILabel!
    @IBOutlet weak var contactPhoneView: UITextView!
    @IBOutlet weak var contactEmailLabel: UILabel!
    @IBOutlet weak var contactEmailView: UITextView!
    @IBOutlet weak var churchPhoneLabel: UILabel!
    @IBOutlet weak var churchPhoneView: UITextView!
    
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
        navigationItem.title = "Contact"
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
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            
            mailingAddressLabel.textColor = .white
            mailingAddressView.textColor = .white
            mailingAddressView.backgroundColor = Constants.UI.Trout
            
            contactNameLabel.textColor = .white
            contactNameView.textColor = .white
            contactNameView.backgroundColor = Constants.UI.Trout
            
            contactPhoneLabel.textColor = .white
            contactPhoneView.textColor = .white
            contactPhoneView.backgroundColor = Constants.UI.Trout
            
            contactEmailLabel.textColor = .white
            contactEmailView.textColor = .white
            contactEmailView.backgroundColor = Constants.UI.Trout
            
            churchPhoneLabel.textColor = .white
            churchPhoneView.textColor = .white
            churchPhoneView.backgroundColor = Constants.UI.Trout
        } else {
            
            UIApplication.shared.statusBarStyle = .default
            statusBar.backgroundColor = .white
            
            view.backgroundColor = .white
            
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = Constants.UI.Trout
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Constants.UI.Trout]
            
            mailingAddressLabel.textColor = Constants.UI.Trout
            mailingAddressView.textColor = Constants.UI.Trout
            mailingAddressView.backgroundColor = .white
            
            contactNameLabel.textColor = Constants.UI.Trout
            contactNameView.textColor = Constants.UI.Trout
            contactNameView.backgroundColor = .white
            
            contactPhoneLabel.textColor = Constants.UI.Trout
            contactPhoneView.textColor = Constants.UI.Trout
            contactPhoneView.backgroundColor = .white
            
            contactEmailLabel.textColor = Constants.UI.Trout
            contactEmailView.textColor = Constants.UI.Trout
            contactEmailView.backgroundColor = .white
            
            churchPhoneLabel.textColor = Constants.UI.Trout
            churchPhoneView.textColor = Constants.UI.Trout
            churchPhoneView.backgroundColor = .white
        }
    }
    
    // MARK: Content Handling
    
    private func initialiseContent() {
        
        mailingAddressView.text = locality.mailingAddressString
        contactNameView.text = locality.contactName
        contactPhoneView.text = locality.contactPhone
        contactEmailView.text = locality.contactEmail
        
        if let churchPhone = locality.churchPhone {
            churchPhoneLabel.text = "Church Phone:"
            churchPhoneView.text = churchPhone
        } else {
            churchPhoneLabel.text = ""
            churchPhoneView.text = ""
        }
    }
}
