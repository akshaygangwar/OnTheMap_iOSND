//
//  NetworkController.swift
//  On The Map
//
//  Created by Akshay Gangwar on 22/04/16.
//  Copyright © 2016 Akshay Gangwar. All rights reserved.
//

import Foundation
import UIKit

class NetworkController:NSObject {
    
    class func createURL(parameters:[String:AnyObject]) -> NSURL {
        let appDelegate = initialiseAppDelegate()
        let methodParameters = parameters
        let url = appDelegate.otmURLFromParameters(methodParameters)
        return url
    }
    
    class func createRequest(url: NSURL, method: String="", body: String = "") -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        if (method != "") {
            request.HTTPMethod = method
        }
        request.addValue(OTMConstants.ParseParameterValues.ApplicationID, forHTTPHeaderField: OTMConstants.ParseParameterKeys.ApplicationID)
        request.addValue(OTMConstants.ParseParameterValues.RESTAPIKey, forHTTPHeaderField: OTMConstants.ParseParameterKeys.RESTAPIKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if (body != "") {
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        return request
    }
    
    class func getStudentLocationData(completionHandler handler:(results:[[String:AnyObject]]) -> Void) {
        let methodParameters = [OTMConstants.ParseParameterKeys.Limit:OTMConstants.ParseParameterValues.Limit]
        let url = createURL(methodParameters)
        let request = createRequest(url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error != nil {
                print("Error")
            }
            
            if let data = data {
                var parsedJSON: AnyObject!
                do {
                    parsedJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String:AnyObject]
                } catch {
                    print ("error in parsed JSON")
                }
                
                guard let resultsDictionary = parsedJSON["results"] as? [[String:AnyObject]] else {
                    print("Could not find key \"results\" in \(parsedJSON)")
                    return
                }
                
                print (resultsDictionary)
                let appDelegate = self.initialiseAppDelegate()
                appDelegate.locations = resultsDictionary
                
                handler(results: resultsDictionary)
            }
        }
        task.resume()
    }
            
    class func initialiseAppDelegate() -> AppDelegate{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate
    }
}
