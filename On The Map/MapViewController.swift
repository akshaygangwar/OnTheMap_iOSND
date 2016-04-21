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
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var annotations = [MKPointAnnotation]()
                    for studentDictionary in resultsDictionary {
                        let lat = CLLocationDegrees(studentDictionary["latitude"] as! Double)
                        let long = CLLocationDegrees(studentDictionary["longitude"] as! Double)
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        print(lat)
                        print(long)
                        
                        let first = studentDictionary["firstName"] as! String
                        let last = studentDictionary["lastName"] as! String
                        let mediaURL = studentDictionary["mediaURL"] as! String
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = mediaURL
                        
                        annotations.append(annotation)
                    }
                    
                    self.mapView.addAnnotations(annotations)
                })
                
            }
            
        }
        task.resume()
    }
    
    
    func initialiseAppDelegate() -> AppDelegate {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate
    }
}
