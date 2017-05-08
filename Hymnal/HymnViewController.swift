//
//  HymnViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

// MARK: - HymnViewController: UIViewController

class HymnViewController: UIViewController {
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var number : Int!
    
    // MARK: Outlets
    
    @IBOutlet weak var hymnText: UITextView!
    @IBOutlet weak var hymnNumber: UILabel!
    @IBOutlet weak var toggleNightModeButton: UIBarButtonItem!
    @IBOutlet weak var toolbarObject: UIToolbar!
    
    // MARK: Actions
    
    @IBAction func backOne(_ sender: Any) {
        setNumber(to: number - 1)
    }
    
    @IBAction func forwardOne(_ sender: Any) {
        setNumber(to: number + 1)
    }
    
    @IBAction func increaseFontSize(_ sender: Any) {
        adjustFontSize(by: 1)
    }
    
    @IBAction func decreaseFontSize(_ sender: Any) {
        adjustFontSize(by: -1)
    }
    
    @IBAction func toggleNightMode(_ sender: Any) {
        if appDelegate.isDark {
            setNightMode(to: false)
        } else {
            setNightMode(to: true)
        }
    }
    
    @IBAction func exit(_ sender: Any) {
        returnToRoot()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialiseUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hymnText.isScrollEnabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: UI+UX Functionality
    
    func initialiseUI() {
        UIApplication.shared.statusBarStyle = .default
        
        hymnText.textContainerInset = UIEdgeInsetsMake(0, 15, 15, 15)
        hymnText.isScrollEnabled = false
        setNumber(to: number)
        
        setFontSize(to: appDelegate.hymnFontSize)
        setNightMode(to: appDelegate.isDark)
    }
    
    func adjustFontSize(by sizeDifference: Int) {
        setFontSize(to: (hymnText.font?.pointSize)! + CGFloat(sizeDifference))
    }
    
    func setFontSize(to newSize: CGFloat) {
        if hymnText.font?.pointSize != newSize {
            hymnText.font = UIFont(
                name: (hymnText.font?.fontName)!,
                size: newSize
            )
            print(newSize)
            
            appDelegate.hymnFontSize = newSize
            UserDefaults.standard.set(Double(appDelegate.hymnFontSize), forKey: "hymnFontSize")
            UserDefaults.standard.synchronize()
        }
    }
    
    func setNumber(to newNumber: Int) {
        number = newNumber
        
        hymnNumber.text = " " + String(number)
        
        hymnText.text = ""
        for line in Hymnal.hymnal.hymns[number - 1].verses {
            if hymnText.text != "" {
                hymnText.text = hymnText.text + "\n\n"
            }
            hymnText.text = hymnText.text + line
        }
        
        hymnText.scrollRangeToVisible(NSRange(location: 0, length: 1))
    }
    
    func setNightMode(to enabled: Bool) {
        if appDelegate.isDark != enabled {
            appDelegate.isDark = enabled
            UserDefaults.standard.set(appDelegate.isDark, forKey: "hymnIsDark")
            UserDefaults.standard.synchronize()
        }
        
        if enabled {
            UIApplication.shared.statusBarStyle = .lightContent
            
            hymnNumber.textColor = .white
            hymnNumber.backgroundColor = Constants.UI.Trout
            hymnText.backgroundColor = Constants.UI.Trout
            hymnText.textColor = .white
            self.view.backgroundColor = Constants.UI.Trout
            
            toolbarObject.barTintColor = Constants.UI.Trout
            for item in toolbarObject.items!
            {
                item.tintColor = .white
            }
            toggleNightModeButton.title = "🌗"
        } else {
            UIApplication.shared.statusBarStyle = .default
            
            hymnNumber.textColor = Constants.UI.Trout
            hymnNumber.backgroundColor = .white
            hymnText.backgroundColor = .white
            hymnText.textColor = Constants.UI.Trout
            self.view.backgroundColor = .white
            
            toolbarObject.barTintColor = .white
            for item in toolbarObject.items!
            {
                item.tintColor = Constants.UI.Trout
            }
            toggleNightModeButton.title = "🌓"
        }
    }
    
    func returnToRoot() {
        dismiss(animated: true, completion: nil)
    }
}
