//
//  MarttinenConvenience.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit
import Foundation

// MARK: - MarttinenClient (Convenient Resource Methods)

extension MarttinenClient {
    
    // MARK: GET Convenience Methods
    
    func getSchedule(
        completionHandlerForGetSchedule: @escaping (_ error: NSError?) -> Void
    ) {
        
        /* Specify parameters */
        let parameters = [:] as [String:AnyObject]
        
        /* Make the request */
        let _ = taskForGETMethod(Methods.Schedule, parameters: parameters as [String:AnyObject]) { (results, error) in
            
            /* Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForGetSchedule(error)
            } else {
                if let results = results?[MarttinenClient.JSONResponseKeys.Schedule] as? [[String:AnyObject]] {
                    ScheduleLine.schedule = ScheduleLine.scheduleFromResults(results)
                    completionHandlerForGetSchedule(nil)
                } else {
                    completionHandlerForGetSchedule(NSError(
                        domain: "getSchedule parsing",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Could not parse getSchedule"]
                    ))
                }
            }
        }
    }
    
    func getLocalities(
        completionHandlerForGetLocalities: @escaping (_ error: NSError?) -> Void
    ) {
        
        /* Specify parameters */
        let parameters = [:] as [String:AnyObject]
        
        /* Make the request */
        let _ = taskForGETMethod(Methods.Localities, parameters: parameters as [String:AnyObject]) { (results, error) in
            
            /* Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForGetLocalities(error)
            } else {
                if let results = results as? [String:[String:AnyObject]] {
                    Locality.localities = Locality.localitiesFromResults(results)
                    completionHandlerForGetLocalities(nil)
                } else {
                    completionHandlerForGetLocalities(NSError(
                        domain: "getLocalities parsing",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Could not parse getLocalities"]
                    ))
                }
            }
        }
    }
}
