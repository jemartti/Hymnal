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
    
    var number : Int!
    var isDark : Bool!
    
    // MARK: Outlets
    
    @IBOutlet weak var hymnText: UITextView!
    @IBOutlet weak var hymnNumber: UILabel!
    @IBOutlet weak var toggleNightModeButton: UIBarButtonItem!
    
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
        if isDark {
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
        
        loadSettings()
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
    
    // MARK: State handling
    
    func loadSettings() {
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            isDark = false
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            saveSettings()
        } else {
            isDark = UserDefaults.standard.bool(forKey: "hymnIsDark")
            setFontSize(to: CGFloat(UserDefaults.standard.double(forKey: "hymnFontSize")))
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(isDark, forKey: "hymnIsDark")
        UserDefaults.standard.set(Double((hymnText.font?.pointSize)!), forKey: "hymnFontSize")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: UI+UX Functionality
    
    func initialiseUI() {
        UIApplication.shared.statusBarStyle = .default
        
        hymnText.textContainerInset = UIEdgeInsetsMake(0, 15, 15, 15)
        hymnText.isScrollEnabled = false
        setNumber(to: number)
        
        setNightMode(to: isDark)
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
            
            saveSettings()
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
        if isDark != enabled {
            isDark = enabled
            saveSettings()
        }
        
        if enabled {
            UIApplication.shared.statusBarStyle = .lightContent
            
            hymnNumber.textColor = .white
            hymnNumber.backgroundColor = .black
            hymnText.backgroundColor = .black
            hymnText.textColor = .white
            self.view.backgroundColor = .black
            
            toggleNightModeButton.title = "🌗"
        } else {
            UIApplication.shared.statusBarStyle = .default
            
            hymnNumber.textColor = .black
            hymnNumber.backgroundColor = .white
            hymnText.backgroundColor = .white
            hymnText.textColor = .black
            self.view.backgroundColor = .white
            
            toggleNightModeButton.title = "🌓"
        }
    }
    
    func returnToRoot() {
        dismiss(animated: true, completion: nil)
    }
}
