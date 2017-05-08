//
//  VerticallyCenteredTextView.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 5/7/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

// MARK: - VerticallyCenteredTextView: UITextView

class VerticallyCenteredTextView: UITextView {
    
    // MARK: UITextView
    
    override var contentSize: CGSize {
        didSet {
            isScrollEnabled = true
            
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}
