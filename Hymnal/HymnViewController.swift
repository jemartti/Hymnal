//
//  HymnViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

class HymnViewController: UIViewController {
    
    var hymnal : Hymnal!
    var number : Int!
    
    @IBOutlet weak var hymnText: UITextView!
    @IBOutlet weak var hymnNumber: UILabel!
    
    @IBAction func backOne(_ sender: Any) {
        number = number - 1
        setNumber()
    }
    
    @IBAction func forwardOne(_ sender: Any) {
        number = number + 1
        setNumber()
    }
    
    @IBAction func increaseFontSize(_ sender: Any) {
        adjustFontSize(by: 1)
    }
    
    @IBAction func decreaseFontSize(_ sender: Any) {
        adjustFontSize(by: -1)
    }
    
    @IBAction func toggleNightMode(_ sender: Any) {
        
    }
    
    @IBAction func exit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hymnText.textContainerInset = UIEdgeInsetsMake(0, 15, 15, 15)
        
        hymnText.isScrollEnabled = false
        setNumber()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hymnText.isScrollEnabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func adjustFontSize(by: Int) {
        hymnText.font = UIFont(
            name: (hymnText.font?.fontName)!,
            size: (hymnText.font?.pointSize)! + CGFloat(by)
        )
    }
    
    func setNumber() {
        hymnNumber.text = " " + String(number)
        
        hymnText.text = ""
        for line in hymnal.hymns[number - 1].verses {
            if hymnText.text != "" {
                hymnText.text = hymnText.text + "\n\n"
            }
            hymnText.text = hymnText.text + line
        }
        
        hymnText.scrollRangeToVisible(NSRange(location: 0, length: 1))
    }
}
