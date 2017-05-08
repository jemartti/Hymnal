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
    var locality: LocalityEntity!
    
    // MARK: Outlets
    
    @IBOutlet weak var mailingAddressView: UITextView!
    @IBOutlet weak var contactNameView: UITextView!
    @IBOutlet weak var contactPhoneView: UITextView!
    @IBOutlet weak var contactEmailView: UITextView!
    @IBOutlet weak var churchPhoneLabel: UILabel!
    @IBOutlet weak var churchPhoneView: UITextView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialiseContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialiseUI()
    }
    
    // MARK: UI+UX Functionality
    
    private func initialiseUI() {
        navigationItem.title = "Contact"
    }
    
    private func initialiseContent() {
        mailingAddressView.text = locality.mailingAddress!
        
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
