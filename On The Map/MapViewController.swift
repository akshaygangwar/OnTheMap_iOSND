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
        NetworkController.getStudentLocationData { (results) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.addAnnotationsToMap(resultArrayOfDictionaries: results)
            })
        }
    }
    
    func addAnnotationsToMap(resultArrayOfDictionaries results: [[String:AnyObject]]) {
        var annotations = [MKPointAnnotation]()
        for studentDictionary in results {
            let lat = CLLocationDegrees(studentDictionary["latitude"] as! Double)
            let long = CLLocationDegrees(studentDictionary["longitude"] as! Double)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
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
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    
    func initialiseAppDelegate() -> AppDelegate {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate
    }
}
