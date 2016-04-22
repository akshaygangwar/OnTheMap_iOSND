//
//  TableViewController.swift
//  On The Map
//
//  Created by Akshay Gangwar on 22/04/16.
//  Copyright © 2016 Akshay Gangwar. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var appDelegate: AppDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = initialiseAppDelegate()
    }
    
    @IBAction func refreshTableData(sender: AnyObject) {
        NetworkController.getStudentLocationData { (results) -> Void in
            self.tableView.reloadData()
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (appDelegate.locations?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listViewPrototype") as UITableViewCell!
        cell.imageView?.image = UIImage(named: "PinIcon")
        let studentDict = appDelegate.locations![indexPath.item]
        let first = studentDict["firstName"] as! String
        let last = studentDict["lastName"] as! String
        cell.textLabel?.text = "\(first) \(last)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //get student details for selected row item
        let studentDict = appDelegate.locations![indexPath.item]
        if let mediaURL = studentDict["mediaURL"] {
            if let URL = NSURL(string: mediaURL as! String) {
                let app = UIApplication.sharedApplication()
                app.openURL(URL)
            }
        }
    }
    
    func initialiseAppDelegate() -> AppDelegate {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate
    }
}