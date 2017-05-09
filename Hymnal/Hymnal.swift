//
//  Hymnal.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import Foundation

// MARK: - Hymnal

struct Hymnal {
    
    // MARK: Properties
    
    static var hymnal : Hymnal!
    
    let language: String
    let hymns: [Hymn]
    
    // MARK: Initialisers
    
    init(dictionary: [String:AnyObject]) {
        language = dictionary["language"] as! String
        hymns = Hymn.hymnsFromDictionary(dictionary["hymns"] as! [[String:AnyObject]])
    }
}
