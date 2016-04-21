//
//  LoginViewController.swift
//  On The Map
//
//  Created by Akshay Gangwar on 20/04/16.
//  Copyright © 2016 Akshay Gangwar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var debugLabel: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewColors()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func attemptLogin(sender: AnyObject) {
        
        //do in background queue, don't block
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let request = self.createRequest("POST")
            request.HTTPBody = "{\"udacity\": {\"username\": \"\(self.usernameField.text!)\", \"password\": \"\(self.passwordField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                
                if error != nil {
                    self.showError("found an error")
                }
                
                //if error is nil, then data will not be nil.
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                
                var parsedJSON: AnyObject!
                do {
                    parsedJSON = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as? [String:AnyObject]
                } catch {
                    self.showError ("Could not serialize JSON")
                }
                
                //check if account is registered
                var isRegistered = false
                
                guard let accountDetailsDictionary = parsedJSON["account"] as? [String:AnyObject] else {
                    self.showError("Could not find key \"account\" in \(parsedJSON)")
                    return
                }
                guard let accountRegistrationValue = accountDetailsDictionary["registered"] as? Int else {
                    self.showError("Could not cast registered to Int")
                    return
                }
                if (accountRegistrationValue == 1) {
                    isRegistered = true
                } else {
                    self.showError("User not registered")
                }
                
                //if registered, get the session ID
                if (isRegistered) {
                    guard let sessionDetailsDictionary = parsedJSON["session"] as? [String:AnyObject] else {
                        self.showError ("Could not find key \"session\" in \(parsedJSON)")
                        return
                    }
                    
                    guard let sessionID = sessionDetailsDictionary["id"] as? String else {
                        self.showError("Could not get session ID as String from \(sessionDetailsDictionary)")
                        return
                    }
                    
                    let appDelegate = self.initialiseAppDelegate()
                    appDelegate.sessionID = sessionID
                    
                }
                
            
            }
            
            task.resume()
        }
        
    }
    // MARK: Setup functions
    func setupViewColors() {
        let backgroundColor = UIColor(red: 237/255.0, green: 118/255.0, blue: 38/255.0, alpha: 1)
        self.view.backgroundColor = backgroundColor
        let buttonColor = UIColor(red: 231/255.0, green: 61/255.0, blue: 37/255.0, alpha: 1)
        loginButton.backgroundColor = buttonColor
    }
    
    func initialiseAppDelegate() -> AppDelegate {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate
    }
    
    func showError(message: String) {
        print(message)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.debugLabel.text = message
        }
    }
    
    // MARK: Login functions
    // TODO: Refactor code for logging in.
    
    // Create request
    func createRequest(methodType: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = methodType
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }


}

