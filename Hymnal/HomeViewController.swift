//
//  HomeViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

// MARK: - HomeViewController: UIViewController

class HomeViewController: UIViewController {
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    // MARK: Outlets
    
    @IBOutlet weak var statusBar: UILabel!
    @IBOutlet weak var openHymnButton: UIButton!
    @IBOutlet weak var hymnNumberInput: UITextField!
    @IBOutlet weak var scheduleButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func hymnNumberSent(_ sender: Any) {
        doneButtonAction()
    }

    @IBAction func schedulesSelect(_ sender: Any) {
        loadSchedule()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSettings()
        loadHymnal()
        
        initialiseUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    // MARK: State Handling
    
    private func loadSettings() {
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            appDelegate.isDark = false
            appDelegate.hymnFontSize = CGFloat(24.0)
            
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.set(appDelegate.isDark, forKey: "hymnIsDark")
            UserDefaults.standard.set(Double(appDelegate.hymnFontSize), forKey: "hymnFontSize")
            UserDefaults.standard.synchronize()
        } else {
            appDelegate.isDark = UserDefaults.standard.bool(forKey: "hymnIsDark")
            appDelegate.hymnFontSize = CGFloat(UserDefaults.standard.double(forKey: "hymnFontSize"))
        }
    }
    
    // MARK: Data Management
    
    private func loadHymnal() {
        if let path = Bundle.main.path(forResource: "hymns", ofType: "json")
        {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                var parsedResult: AnyObject! = nil
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                } catch {
                    let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                    throw NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo)
                }
                
                Hymnal.hymnal = Hymnal(dictionary: parsedResult as! [String:AnyObject])
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // UI Functionality
    
    private func initialiseUI() {
        let placeholder = NSAttributedString(
            string: "000",
            attributes: [NSForegroundColorAttributeName: Constants.UI.ShipCove]
        )
        hymnNumberInput.attributedPlaceholder = placeholder
        hymnNumberInput.delegate = self
    }
    
    private func updateUI() {
        setNightMode(to: appDelegate.isDark)
    }
    
    private func setNightMode(to enabled: Bool) {
        if appDelegate.isDark != enabled {
            appDelegate.isDark = enabled
            UserDefaults.standard.set(appDelegate.isDark, forKey: "hymnIsDark")
            UserDefaults.standard.synchronize()
        }
        
        if enabled {
            UIApplication.shared.statusBarStyle = .default
            
            self.view.backgroundColor = Constants.UI.Trout
            
            hymnNumberInput.keyboardAppearance = .dark
            
            statusBar.backgroundColor = .white
            openHymnButton.backgroundColor = .white
            hymnNumberInput.textColor = .white
            scheduleButton.backgroundColor = .white
            
            openHymnButton.setTitleColor(Constants.UI.Trout, for: .normal)
            scheduleButton.setTitleColor(Constants.UI.Trout, for: .normal)
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
            
            self.view.backgroundColor = .white
            
            hymnNumberInput.keyboardAppearance = .light
            
            statusBar.backgroundColor = Constants.UI.Trout
            openHymnButton.backgroundColor = Constants.UI.Trout
            hymnNumberInput.textColor = Constants.UI.Trout
            scheduleButton.backgroundColor = Constants.UI.Trout
            
            openHymnButton.setTitleColor(.white, for: .normal)
            scheduleButton.setTitleColor(.white, for: .normal)
        }
    }
    
    // MARK: UX Functionality
    
    func doneButtonAction() {
        hymnNumberInput.resignFirstResponder()
        
        if let hymnNumber : Int = Int(hymnNumberInput.text!) {
            loadHymn(hymnNumber)
        }
    }
    
    private func loadHymn(_ id: Int) {
        let hymnVC = storyboard!.instantiateViewController(
            withIdentifier: "HymnViewController"
        ) as! HymnViewController
        
        hymnVC.number = id
        
        present(hymnVC, animated: true, completion: nil)
    }
    
    private func loadSchedule() {
        let scheduleVC = storyboard!.instantiateViewController(
            withIdentifier: "ListNavigationController"
        )
        
        present(scheduleVC, animated: true, completion: nil)
    }
}

// MARK: - HomeViewController: UITextFieldDelegate

extension HomeViewController: UITextFieldDelegate {
    
    // MARK: Actions
    
    @IBAction func userTappedView(_ sender: AnyObject) {
        resignIfFirstResponder(hymnNumberInput)
        doneButtonAction()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doneButtonAction()
        return true
    }
    
    // Limit text field input to numbers in range
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {
            return true
        }
        let prospectiveText = (text as NSString).replacingCharacters(in: range, with: string)
        if prospectiveText == "" {
            return true
        } else if let number = Int(prospectiveText), number <= Hymnal.hymnal.hymns.count {
            return true
        }
        
        return false
    }
    
    // MARK: Show/Hide Keyboard
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
}
