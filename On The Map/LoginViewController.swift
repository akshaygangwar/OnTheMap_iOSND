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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var isValidUser = false
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

        activityIndicator.startAnimating()
        
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
                    self.showAlertForInvalidCredentials()
                    return
                }
                guard let accountRegistrationValue = accountDetailsDictionary["registered"] as? Int else {
                    self.showError("Could not cast registered to Int")
                    self.showAlertForInvalidCredentials()
                    return
                }
                if (accountRegistrationValue == 1) {
                    isRegistered = true
                } else {
                    self.showError("User not registered")
                    self.showAlertForInvalidCredentials()
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
                    self.loginSuccessfully()
                    
                }
                
            
            }
            
            task.resume()
        }
        
    }
    // MARK: Setup functions
    func setupViewColors() {
        self.view.backgroundColor = OTMConstants.UIConstants.backgroundColor
        loginButton.backgroundColor = OTMConstants.UIConstants.buttonColor
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
    
    func showAlertForInvalidCredentials() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alertViewController = UIAlertController(title: "Invalid Credentials", message: "The username and/or password is incorrect", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.usernameField.text = ""
                self.passwordField.text = ""
                self.passwordField.resignFirstResponder()
            })
            alertViewController.addAction(okAction)
            self.activityIndicator.stopAnimating()
            self.presentViewController(alertViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: Login functions
    // TODO: Refactor code for logging in.
    
    // Create request
    func createRequest(methodType: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: OTMConstants.UdacityConstants.UdacityURL)!)
        request.HTTPMethod = methodType
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    //login and segue
    func loginSuccessfully() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            guard let homeScreen = self.storyboard?.instantiateViewControllerWithIdentifier("homeScreen") as? UITabBarController else {
                print("fail gracefully")
                return
            }
            self.activityIndicator.stopAnimating()
            self.presentViewController(homeScreen, animated: true, completion: nil)
        }
        
    }


}

