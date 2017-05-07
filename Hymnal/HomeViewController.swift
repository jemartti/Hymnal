//
//  HomeViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate {

    var hymnal: Hymnal!
    
    @IBOutlet weak var hymnNumberInput: UITextField!
    
    @IBAction func hymnNumberSent(_ sender: Any) {
        if let hymnNumber : Int = Int(hymnNumberInput.text!) {
            loadHymn(hymnNumber)
        } else {
            print("Parse Failed")
        }
    }
    
    @IBAction func schedulesSelect(_ sender: Any) {
        loadSchedule()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadHymnal()
        
        fetchSchedule()
        
        fetchLocalities()
        
        addDoneButtonOnKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(HomeViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        hymnNumberInput.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        hymnNumberInput.resignFirstResponder()
        
        if let hymnNumber : Int = Int(hymnNumberInput.text!) {
            print(hymnNumber)
            loadHymn(hymnNumber)
        } else {
            print("Parse Failed")
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
