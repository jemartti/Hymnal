//
//  Locality.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 5/6/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import Foundation

// MARK: - Locality

struct Locality {
    
    // MARK: Properties
    
    let name : String
    let photoURL : String?
    let locationAddress : [String]
    let locationLatitude : Float?
    let locationLongitude : Float?
    let mailingAddress : [String]
    let churchPhone : String?
    let contactName : String
    let contactPhone: String
    let contactEmail: String
    
    // MARK: Initialisers
    
    // construct a Locality from a dictionary
    init(dictionary: [String:AnyObject]) {
        
        name = dictionary[MarttinenClient.JSONResponseKeys.Name] as! String
        photoURL = dictionary[MarttinenClient.JSONResponseKeys.PhotoURL] as? String
        locationLatitude = dictionary[MarttinenClient.JSONResponseKeys.LocationLatitude] as? Float
        locationLongitude = dictionary[MarttinenClient.JSONResponseKeys.LocationLongitude] as? Float
        churchPhone = dictionary[MarttinenClient.JSONResponseKeys.ChurchPhone] as? String
        contactName = dictionary[MarttinenClient.JSONResponseKeys.ContactName] as! String
        contactPhone = dictionary[MarttinenClient.JSONResponseKeys.ContactPhone] as! String
        contactEmail = dictionary[MarttinenClient.JSONResponseKeys.ContactEmail] as! String
        
        if let locationAddressArray = dictionary[MarttinenClient.JSONResponseKeys.LocationAddress] as? [String] {
            locationAddress = locationAddressArray
        } else {
            locationAddress = [String]()
        }
        
        if let mailingAddressArray = dictionary[MarttinenClient.JSONResponseKeys.MailingAddress] as? [String] {
            mailingAddress = mailingAddressArray
        } else {
            mailingAddress = [String]()
        }
    }
    
    // Convert results to an array of Localities
    static func localitiesFromResults(_ results: [String:[String:AnyObject]]) -> [String:Locality] {
        
        var localities = [String:Locality]()
        
        // iterate through dictionary, each Locality is a dictionary
        for (key, value) in results {
            localities[key] = Locality(dictionary: value)
        }
        
        return localities
    }
}
