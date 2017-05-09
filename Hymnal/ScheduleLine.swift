//
//  ScheduleLine.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 5/6/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import Foundation

// MARK: - ScheduleLine

struct ScheduleLine {
    
    // MARK: Properties
    
    let dateString : String
    let status : String?
    let comment : String?
    let locality : String?
    let localityPretty : String?
    let with : [String]
    let am : Bool?
    let pm : Bool?
    let isSunday : Bool
    
    // MARK: Initialisers
    
    // construct a ScheduleLine from a dictionary
    init(dictionary: [String:AnyObject]) {
        
        dateString = dictionary[MarttinenClient.JSONResponseKeys.DateString] as! String
        status = dictionary[MarttinenClient.JSONResponseKeys.Status] as? String
        comment = dictionary[MarttinenClient.JSONResponseKeys.Comment] as? String
        locality = dictionary[MarttinenClient.JSONResponseKeys.Locality] as? String
        localityPretty = dictionary[MarttinenClient.JSONResponseKeys.LocalityPretty] as? String
        am = dictionary[MarttinenClient.JSONResponseKeys.AM] as? Bool
        pm = dictionary[MarttinenClient.JSONResponseKeys.PM] as? Bool
        isSunday = dictionary[MarttinenClient.JSONResponseKeys.IsSunday] as! Bool
        
        if let withArray = dictionary[MarttinenClient.JSONResponseKeys.With] as? [String] {
            with = withArray
        } else {
            with = [String]()
        }
    }
    
    // Convert results to an array of ScheduleLines
    static func scheduleFromResults(_ results: [[String:AnyObject]]) -> [ScheduleLine] {
        
        var schedule = [ScheduleLine]()
        
        // iterate through array of dictionaries, each ScheduleLine is a dictionary
        for result in results {
            schedule.append(ScheduleLine(dictionary: result))
        }
        
        return schedule
    }
}
