//
//  MarttinenClient.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import Foundation

// MARK: - MarttinenClient: NSObject

class MarttinenClient : NSObject {
    
    // MARK: Properties
    
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
        
        session = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 5
            configuration.timeoutIntervalForResource = 5
            return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        }()
    }
    
    // MARK: GET
    
    func taskForGETMethod(
        _ method: String,
        parameters: [String:AnyObject],
        completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void
    ) -> URLSessionDataTask {
        
        let request = marttinenRequestFromParameters(parameters, method: method)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("The request failed (likely due to a network issue). Check your settings and try again.")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError("The request failed due to a server error. Try again later.")
                return
            }
            if statusCode < 200 || statusCode > 299 {
                if statusCode == 403 {
                    sendError("Invalid credentials.")
                } else {
                    sendError("The request failed due to a server error (\(statusCode)). Try again later.")
                }
                return
            }
            
            guard let data = data else {
                sendError("The request failed due to a server error. Try again later.")
                return
            }
            
            ClientHelpers.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        return task
    }
    
    // MARK: Helpers
    
    private func marttinenRequestFromParameters(
        _ parameters: [String:AnyObject],
        method: String? = nil
    ) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(url: marttinenURLFromParameters(parameters, withPathExtension: method))
        request.addValue(MarttinenClient.Constants.ApiKey, forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func marttinenURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = MarttinenClient.Constants.ApiScheme
        components.host = MarttinenClient.Constants.ApiHost
        components.path = MarttinenClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> MarttinenClient {
        
        struct Singleton {
            static var sharedInstance = MarttinenClient()
        }
        
        return Singleton.sharedInstance
    }
}
