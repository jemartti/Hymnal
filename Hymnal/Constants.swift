//
//  Constants.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 5/7/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

// MARK: - Constants

struct Constants {
    
    // MARK: UI
    
    struct UI {
        static let Armadillo = UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00)
        static let Pumice = UIColor(red:0.78, green:0.78, blue:0.78, alpha:1.00)
        static let WildSand = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.00)
        static let Black = UIColor(red:0.02, green:0.02, blue:0.02, alpha:1.00)
        static let White = UIColor(red:0.82, green:0.82, blue:0.82, alpha:1.00)
    }
    
    // MARK: Themes enum
    
    enum Themes: Int {
        case light = 1, dark, black
        
        init() {
            self = .light
        }
    }
}
