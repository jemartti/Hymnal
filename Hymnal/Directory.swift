//
//  Directory.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 11/7/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import Foundation

// MARK: - Directory

struct Directory {
    
    // MARK: Properties
    
    static var directory : Directory?
    
    let localities: [String:Locality]
    
    // MARK: Initialisers
    
    init(dictionary: [String:[String:AnyObject]]) {
        localities = Locality.localitiesFromResults(dictionary)
    }
}
