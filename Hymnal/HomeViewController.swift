//
//  HomeViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    var hymnal: Hymnal!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadHymnal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                
                hymnal = Hymnal(dictionary: parsedResult as! [String:AnyObject])
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
