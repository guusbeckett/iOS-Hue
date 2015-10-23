//
//  TableViewController.swift
//  iOS-Hue
//
//  Created by Guus Beckett on 21/10/15.
//  Copyright © 2015 Reupload. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var bridgeMiddleman = BridgeMiddleman.getInstance
    var alertControllerUsername = UIAlertController(title: "Connect to bridge", message: "Press the bridge button to continue.", preferredStyle: .Alert)
    var alertControllerBridge = UIAlertController(title: "Looking for bridge", message: "Make sure you are connected to the bridge network.", preferredStyle: .Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Your 💡💡"
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reloadHueLamps:")
        self.navigationItem.rightBarButtonItem = refreshButton
        
        checkForResetRequest()
        
        
        connectToBridge()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if bridgeMiddleman.hasUsername.boolValue  && bridgeMiddleman.hasBridgeIp.boolValue {
            loadHueLamps()
        }
    }

    func connectToBridge() {
        bridgeMiddleman.loadBridgeSettings()
        
        if !bridgeMiddleman.hasBridgeIp.boolValue {
            retrieveBridgeIp()
            showNoBridgeAlert()
        }
        
        else if !bridgeMiddleman.hasUsername.boolValue {
            retrieveUsername()
            showNoUsernameAlert()
        }
        
        else {
            loadHueLamps()
        }
    }
    
    func retrieveBridgeIp() {
        bridgeMiddleman.findAndSetBridgeIp()
        if ( !bridgeMiddleman.hasBridgeIp.boolValue ) {
            self.performSelector("retrieveUsername", withObject: nil, afterDelay: 1) // Repeat function with 2 sec delay
        }
        else {
            self.alertControllerBridge.dismissViewControllerAnimated(true, completion: nil)
            retrieveUsername()
        }
        
    }
    
    func retrieveUsername() {
        bridgeMiddleman.createUsernameHueBridge()
        if ( !bridgeMiddleman.hasUsername.boolValue ) {
            self.performSelector("retrieveUsername", withObject: nil, afterDelay: 1) // Repeat function with 2 sec delay
        }
        else {
            self.alertControllerUsername.dismissViewControllerAnimated(true, completion: nil)
            loadHueLamps()
        }
    }

    func loadHueLamps() {
        bridgeMiddleman.getAllLamps()
        if (bridgeMiddleman.lampArray.count == 0) {
            self.performSelector("loadHueLamps", withObject: nil, afterDelay: 1) // Repeat function with 1 sec delay
        }
        else {
            self.tableView.reloadData()
        }
    }
    
    func reloadHueLamps(sender: AnyObject) {
        if bridgeMiddleman.hasUsername.boolValue {
            loadHueLamps()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bridgeMiddleman.lampArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HueLamp", forIndexPath: indexPath) as! ContactTableViewCell

        // Get row and section
        let row = indexPath.row
        //
        cell.hueName?.text = bridgeMiddleman.lampArray[row].name
        cell.hueID?.text = String(bridgeMiddleman.lampArray[row].id)
        cell.hueColour?.image = bridgeMiddleman.lampArray[row].getImage()
        return cell
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Check if the right segue is handled
        if segue.identifier == "showDetail" {
            
            // Get destination controller
            if let destination = segue.destinationViewController as? DetailViewController {
                
                // Get selected row and lookup selected lamp in array
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    
                    // Pass lamp to detailed view
                    let lamp = bridgeMiddleman.lampArray[indexPath.row]
                    destination.lamp = lamp
                    
                }
            }
        }
    }
    
    func checkForResetRequest() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.boolForKey("requested_reset") {
            bridgeMiddleman.resetBridgeSettings()
        }
    }
    
    func showNoUsernameAlert() {
        
        self.presentViewController(alertControllerUsername, animated: true) {
            
        }
    }
    
    func showNoBridgeAlert() {
        
        self.presentViewController(alertControllerUsername, animated: true) {
            
        }
    }
}
