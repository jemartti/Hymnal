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
        
        initialiseUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
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
    
    private func initialiseUI() {
        hymnText.textContainerInset = UIEdgeInsetsMake(0, 15, 15, 15)
    }
    
    private func updateUI() {
        hymnText.isScrollEnabled = false
        setNumber(to: number)
        setFontSize(to: appDelegate.hymnFontSize)
        setNightMode(to: appDelegate.isDark)
    }
    
    private func adjustFontSize(by sizeDifference: Int) {
        setFontSize(to: appDelegate.hymnFontSize + CGFloat(sizeDifference))
    }
    
    private func setFontSize(to newSize: CGFloat) {
        let newHymnText = NSMutableAttributedString(attributedString: hymnText.attributedText)
        
        newHymnText.enumerateAttribute(
            NSFontAttributeName, in: NSMakeRange(0, newHymnText.length), options: []
        ) { value, range, stop in
            guard let currentFont = value as? UIFont else {
                return
            }
            let newFont = UIFont(descriptor: currentFont.fontDescriptor, size: newSize)
            newHymnText.addAttributes([NSFontAttributeName: newFont], range: range)
        }
        
        hymnText.attributedText = newHymnText
        
        appDelegate.hymnFontSize = newSize
        UserDefaults.standard.set(Double(appDelegate.hymnFontSize), forKey: "hymnFontSize")
        UserDefaults.standard.synchronize()
    }
    
    private func setNumber(to newNumber: Int) {

        // Set properties
        number = newNumber
        
        // Set up basic text attributes
        var textColor = Constants.UI.Trout
        if appDelegate.isDark {
            textColor = UIColor.white
        }
        
        var italicSections = [Int:Int]()
        let boldSections = [Int:Int]()
        
        // Create hymn string
        var hymnStringRaw = ""
        for line in Hymnal.hymnal.hymns[number - 1].verses {
            if hymnStringRaw != "" {
                hymnStringRaw = hymnStringRaw + "\n\n"
            }
            hymnStringRaw = hymnStringRaw + line
            
            if let chorus = Hymnal.hymnal.hymns[number - 1].chorus {
                hymnStringRaw = hymnStringRaw + "\n\n"
                italicSections[hymnStringRaw.characters.count] = 7
                hymnStringRaw = hymnStringRaw + "Chorus: " + chorus
            } else if let refrain = Hymnal.hymnal.hymns[number-1].refrain {
                hymnStringRaw = hymnStringRaw + "\n\n"
                italicSections[hymnStringRaw.characters.count] = 8
                hymnStringRaw = hymnStringRaw + "Refrain: " + refrain
            }
        }
        
        // Create attributed hymn string
        let hymnString = NSMutableAttributedString(
            string: hymnStringRaw,
            attributes: [
                NSForegroundColorAttributeName: textColor,
                NSFontAttributeName: UIFont.systemFont(ofSize: appDelegate.hymnFontSize)
            ]
        )
        
        for (key, value) in italicSections {
            hymnString.addAttribute(NSFontAttributeName, value: UIFont.italicSystemFont(ofSize: appDelegate.hymnFontSize), range: NSMakeRange(key, value))
        }
        for (key, value) in boldSections {
            hymnString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: appDelegate.hymnFontSize), range: NSMakeRange(key, value))
        }
        
        // Set UI
        hymnNumber.text = " " + String(number)
        hymnText.attributedText = hymnString
        hymnText.scrollRangeToVisible(NSRange(location: 0, length: 1))
    }
    
    private func setNightMode(to enabled: Bool) {
        
        if appDelegate.isDark != enabled {
            appDelegate.isDark = enabled
            UserDefaults.standard.set(appDelegate.isDark, forKey: "hymnIsDark")
            UserDefaults.standard.synchronize()
        }
        
        let newHymnText = NSMutableAttributedString(attributedString: hymnText.attributedText)
        
        if enabled {
            UIApplication.shared.statusBarStyle = .lightContent
            
            view.backgroundColor = Constants.UI.Trout
            
            hymnNumber.textColor = .white
            hymnNumber.backgroundColor = Constants.UI.Trout
            
            hymnText.backgroundColor = Constants.UI.Trout
            
            newHymnText.enumerateAttribute(
                NSForegroundColorAttributeName, in: NSMakeRange(0, newHymnText.length), options: []
            ) { value, range, stop in
                newHymnText.addAttributes([NSForegroundColorAttributeName: UIColor.white], range: range)
            }
            
            toolbarObject.barTintColor = Constants.UI.Trout
            for item in toolbarObject.items!
            {
                item.tintColor = .white
            }
            toggleNightModeButton.title = "🌗"
        } else {
            UIApplication.shared.statusBarStyle = .default
            
            view.backgroundColor = .white
            
            hymnNumber.textColor = Constants.UI.Trout
            hymnNumber.backgroundColor = .white
            
            hymnText.backgroundColor = .white
            
            newHymnText.enumerateAttribute(
                NSForegroundColorAttributeName, in: NSMakeRange(0, newHymnText.length), options: []
            ) { value, range, stop in
                newHymnText.addAttributes([NSForegroundColorAttributeName: Constants.UI.Trout], range: range)
            }
            
            toolbarObject.barTintColor = .white
            for item in toolbarObject.items!
            {
                item.tintColor = Constants.UI.Trout
            }
            toggleNightModeButton.title = "🌓"
        }
        
        hymnText.attributedText = newHymnText
    }
    
    // MARK: Supplementary Functions
    
    private func returnToRoot() {
        dismiss(animated: true, completion: nil)
    }
}
