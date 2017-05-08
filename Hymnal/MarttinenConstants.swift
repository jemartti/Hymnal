//
//  MarttinenConstants.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

extension MarttinenClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey = "secret"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "cherry-direction.glitch.me"
        static let ApiPath = ""
    }
    
    // MARK: Methods
    struct Methods {
        static let Localities = "/localities"
        static let Schedule = "/schedule"
    }
    
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        static let Schedule = "schedule"
        static let Localities = "localities"
        static let DateString = "dateString"
        static let Status = "status"
        static let Comment = "comment"
        static let Locality = "locality"
        static let LocalityPretty = "localityPretty"
        static let With = "with"
        static let AM = "AM"
        static let PM = "PM"
        static let IsSunday = "isSunday"
        static let Name = "name"
        static let PhotoURL = "photoURL"
        static let LocationAddress = "locationAddress"
        static let LocationLatitude = "locationLatitude"
        static let LocationLongitude = "locationLongitude"
        static let MailingAddress = "mailingAddress"
        static let ChurchPhone = "churchPhone"
        static let ContactName = "contactName"
        static let ContactPhone = "contactPhone"
        static let ContactEmail = "contactEmail"
    }
}
