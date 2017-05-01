//
//  Hymn.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import Foundation

struct Hymnal {
    
    static var hymnal : Hymnal!
    
    let language: String
    let hymns: [Hymn]
    
    init(dictionary: [String:AnyObject]) {
        language = dictionary["language"] as! String
        hymns = Hymn.hymnsFromDictionary(dictionary["hymns"] as! [[String:AnyObject]])
    }
}

struct Hymn {
    let verses: [String]
    let chorus: String?
    let refrain: String?
    
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
