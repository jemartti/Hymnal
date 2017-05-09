//
//  Hymn.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 5/9/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import Foundation

// MARK: - Hymn

struct Hymn {
    
    // MARK: Properties
    
    let verses: [String]
    let chorus: String?
    let refrain: String?
    
    // MARK: Initialisers
    
    init(dictionary: [String:AnyObject]) {
        verses = dictionary["verses"] as! [String]
        chorus = dictionary["chorus"] as? String
        refrain = dictionary["refrain"] as? String
    }
    
    static func hymnsFromDictionary(_ results: [[String:AnyObject]]) -> [Hymn] {
        var hymns = [Hymn]()
        
        for result in results {
            let hymn = Hymn(dictionary: result)
            hymns.append(hymn)
        }
        
        return hymns
    }
}
