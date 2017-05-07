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

    // MARK: Outlets
    
    @IBOutlet weak var hymnNumberInput: UITextField!
    @IBOutlet weak var openHymnButton: UIButton!
    
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
        
        // Heavy lifting
        loadHymnal()
        fetchSchedule()
        fetchLocalities()
        
        hymnNumberInput.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // MARK: Fetching
    
    func fetchSchedule() {
        MarttinenClient.sharedInstance().getSchedule() { (error) in
            if error != nil {
                print(error!)
            } else {
                print("Download complete")
            }
        }
    }
    
    func fetchLocalities() {
        MarttinenClient.sharedInstance().getLocalities() { (error) in
            if error != nil {
                print(error!)
            } else {
                print("Download complete")
            }
        }
    }
    
    func doneButtonAction() {
        hymnNumberInput.resignFirstResponder()
        
        if let hymnNumber : Int = Int(hymnNumberInput.text!) {
            loadHymn(hymnNumber)
        }
    }
    
    func loadHymnal() {
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
    
    func loadHymn(_ id: Int) {
        let hymnVC = storyboard!.instantiateViewController(
            withIdentifier: "HymnViewController"
        ) as! HymnViewController
        
        hymnVC.number = id
        
        present(hymnVC, animated: true, completion: nil)
    }
    
    func loadSchedule() {
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
