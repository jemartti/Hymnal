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
    
    let key : String
    let name : String
    let hasPhoto : Bool
    let hasLocationDetails : Bool
    let locationAddress : [String]
    let locationAddressString : String
    let locationLatitude : Float
    let locationLongitude : Float
    let mailingAddress : [String]
    let mailingAddressString : String
    let churchPhone : String?
    let contactName : String
    let contactPhone: String
    let contactEmail: String
    
    // MARK: Initialisers
    
    // construct a Locality from a dictionary
    init(localityKey: String, dictionary: [String:AnyObject]) {
        
        key = localityKey
        name = dictionary["name"] as! String
        hasPhoto = dictionary["hasPhoto"] as! Bool
        churchPhone = dictionary["churchPhone"] as? String
        contactName = dictionary["contactName"] as! String
        contactPhone = dictionary["contactPhone"] as! String
        contactEmail = dictionary["contactEmail"] as! String
        
        if let _locationLatitude = dictionary["locationLatitude"],
            let _locationLongitude = dictionary["locationLongitude"] {
            locationLatitude = _locationLatitude as! Float
            locationLongitude = _locationLongitude as! Float
            hasLocationDetails = true
        } else {
            locationLatitude = 0
            locationLongitude = 0
            hasLocationDetails = false
        }
        
        if let locationAddressArray = dictionary["locationAddress"] as? [String] {
            locationAddress = locationAddressArray
        } else {
            locationAddress = [String]()
        }
        
        if let mailingAddressArray = dictionary["mailingAddress"] as? [String] {
            mailingAddress = mailingAddressArray
        } else {
            mailingAddress = [String]()
        }
        
        var _locationAddressString = ""
        for i in 0 ..< locationAddress.count {
            if i != 0 {
                _locationAddressString = _locationAddressString + "\n"
            }
            _locationAddressString = _locationAddressString + locationAddress[i]
        }
        locationAddressString = _locationAddressString
        
        var _mailingAddressString = ""
        for i in 0 ..< mailingAddress.count {
            if i != 0 {
                _mailingAddressString = _mailingAddressString + "\n"
            }
            _mailingAddressString = _mailingAddressString + mailingAddress[i]
        }
        mailingAddressString = _mailingAddressString
    }
    
    // Convert results to an array of Localities
    static func localitiesFromResults(_ results: [String:[String:AnyObject]]) -> [String:Locality] {
        
        var localities = [String:Locality]()
        
        // iterate through dictionary, each Locality is a dictionary
        for (key, value) in results {
            localities[key] = Locality(localityKey: key, dictionary: value)
        }
        
        return localities
    }
}
