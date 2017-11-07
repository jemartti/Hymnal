//
//  MarttinenConstants.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

// MARK: - MarttinenClient (Constants)

extension MarttinenClient {
    
    // MARK: Constants
    
    struct Constants {
        
        // MARK: API Key
        
        static let ApiKey = "secret"
        
        // MARK: URLs
        
        static let ApiScheme = "https"
        static let ApiHost = "us-central1-hymnal-api.cloudfunctions.net"
        static let ApiPath = ""
    }
    
    // MARK: Methods
    
    struct Methods {
        static let Schedule = "/fetchSchedule"
    }
    
    
    // MARK: JSON Response Keys
    
    struct JSONResponseKeys {
        static let Schedule = "schedule"
        static let DateString = "dateString"
        static let Status = "status"
        static let Comment = "comment"
        static let Missionaries = "missionaries"
        static let Locality = "locality"
        static let LocalityPretty = "localityPretty"
        static let With = "with"
        static let AM = "AM"
        static let PM = "PM"
        static let IsSunday = "isSunday"
    }
}
