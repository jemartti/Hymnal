//
//  LocalityViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 5/6/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

class LocalityViewController: UIViewController {
    
    var locality: Locality!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Contact",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(LocalityViewController.contactInformation)
        )
        navigationItem.title = locality.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    func contactInformation() {
        let contactViewController = storyboard!.instantiateViewController(
            withIdentifier: "ContactViewController"
        ) as! ContactViewController
        contactViewController.locality = locality
        navigationController!.pushViewController(contactViewController, animated: true)
    }
}
