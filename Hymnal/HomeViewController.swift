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
    
    @IBOutlet weak var openHymnButton: UIButton!
    @IBOutlet weak var hymnNumberInput: UITextField!
    @IBOutlet weak var directoryButton: UIButton!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var xHomeBackground: UILabel!
    
    // MARK: Actions
    
    @IBAction func hymnNumberSent(_ sender: Any) {
        doneButtonAction()
    }
    
    @IBAction func directorySelect(_ sender: Any) {
        loadDirectory()
    }
    
    @IBAction func schedulesSelect(_ sender: Any) {
        loadSchedule()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSettings()
        initialiseUI()
        
        loadHymnalFile()
        loadDirectoryFile()
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
    
    private func loadHymnalFile() {
        
        if let path = Bundle.main.path(forResource: "hymns", ofType: "json") {
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                var parsedResult: AnyObject! = nil
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                } catch {
                    let userInfo = [NSLocalizedDescriptionKey : "Could not parse the hymnal file data as JSON: '\(data)'"]
                    throw NSError(domain: "HomeViewController", code: 1, userInfo: userInfo)
                }
                
                Hymnal.hymnal = Hymnal(dictionary: parsedResult as! [String:AnyObject])
            } catch _ as NSError {
                alertUserOfFailure(message: "Hymnal file loading failed.")
            }
        }
    }
    
    private func loadDirectoryFile() {
        
        if let path = Bundle.main.path(forResource: "directory", ofType: "json") {
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                var parsedResult: AnyObject! = nil
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                } catch {
                    let userInfo = [NSLocalizedDescriptionKey : "Could not parse the directory file data as JSON: '\(data)'"]
                    throw NSError(domain: "HomeViewController", code: 1, userInfo: userInfo)
                }
                
                Directory.directory = Directory(dictionary: parsedResult as! [String:[String:AnyObject]])
            } catch _ as NSError {
                alertUserOfFailure(message: "Directory file loading failed.")
            }
        }
    }
    
    // UI+UX Functionality
    
    private func initialiseUI() {
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = .white
        UIApplication.shared.statusBarStyle = .default
        
        xHomeBackground.backgroundColor = .white
        view.backgroundColor = Constants.UI.WildSand
        
        openHymnButton.backgroundColor = .white
        openHymnButton.setTitleColor(Constants.UI.Armadillo, for: .normal)
        
        let placeholder = NSAttributedString(
            string: "000",
            attributes: [NSAttributedStringKey.foregroundColor: Constants.UI.Armadillo]
        )
        hymnNumberInput.attributedPlaceholder = placeholder
        hymnNumberInput.textColor = Constants.UI.Armadillo
        hymnNumberInput.keyboardAppearance = .light
        hymnNumberInput.delegate = self
        
        directoryButton.backgroundColor = .white
        directoryButton.setTitleColor(Constants.UI.Armadillo, for: .normal)
        
        scheduleButton.backgroundColor = .white
        scheduleButton.setTitleColor(Constants.UI.Armadillo, for: .normal)
    }
    
    private func updateUI() {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = .white
        UIApplication.shared.statusBarStyle = .default
    }
    
    private func alertUserOfFailure( message: String) {
        
        DispatchQueue.main.async {
            
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
    
    private func loadDirectory() {
        
        let directoryVC = storyboard!.instantiateViewController(
            withIdentifier: "DirectoryListNavigationController"
        )
        present(directoryVC, animated: true, completion: nil)
    }
    
    private func loadSchedule() {
        
        let scheduleVC = storyboard!.instantiateViewController(
            withIdentifier: "ScheduleListNavigationController"
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
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
        ) -> Bool {
        
        guard let text = textField.text else {
            return true
        }
        
        let prospectiveText = (text as NSString).replacingCharacters(in: range, with: string)
        if prospectiveText == "" {
            return true
        } else if let number = Int(prospectiveText), let hymnal = Hymnal.hymnal {
            
            if number <= hymnal.hymns.count && number > 0 {
                return true
            }
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
