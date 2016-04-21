//
//  MapViewController.swift
//  On The Map
//
//  Created by Akshay Gangwar on 21/04/16.
//  Copyright © 2016 Akshay Gangwar. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentLocationData()
        
    }
    
    func createURL(parameters:[String:AnyObject]) -> NSURL {
        let appDelegate = initialiseAppDelegate()
        let methodParameters = parameters
        let url = appDelegate.otmURLFromParameters(methodParameters)
        return url
    }
    
    func createRequest(url: NSURL, method: String="", body: String = "") -> NSMutableURLRequest {
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
    
    func getStudentLocationData() {
        let methodParameters = [OTMConstants.ParseParameterKeys.Limit:2]
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
                
                print(parsedJSON)
            }
            
        }
        task.resume()
    }
    
    func initialiseAppDelegate() -> AppDelegate {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate
    }
}
