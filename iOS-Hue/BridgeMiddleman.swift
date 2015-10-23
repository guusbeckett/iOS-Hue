//
//  BridgeMiddleman.swift
//  iOS-HueApp
//
//  Created by Guus Beckett on 20/10/15.
//  Copyright © 2015 Reupload. All rights reserved.
//

import Alamofire
import SwiftyJSON

class BridgeMiddleman {
    static let getInstance = BridgeMiddleman()
    
    var userName : String = ""
    var bridgeIp : String = ""
    var lampArray : [HueLamp] = [HueLamp]()
    var hasBridgeIp : Bool = false
    var hasUsername : Bool = false
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    private let parameters = [
        "devicetype":"HueApp#Guus"
    ]
    
    func findAndSetBridgeIp() {
        
        // Ask for available hue lamps
        Alamofire.request(.GET, "https://www.meethue.com/api/nupnp")
            .responseJSON { response in
                let jsonResponse = JSON(response.2.value!)
                if jsonResponse.array?.count == 1 {
                    
                    // If only one bridge is found, save bridge ip as ip to use
                    self.bridgeIp = jsonResponse.arrayValue[0]["internalipaddress"].string!
                    self.hasBridgeIp = true
                    
                }
                else if jsonResponse.array?.count > 1 {
                    // TODO: if more bridges are found, ask the user which bridge he wants to use
                }
                else if jsonResponse.array?.count < 1 {
                    // No bridges found, this should trigger a warning to the user
                    self.bridgeIp = "NO_BRIDGE_IP_AVAILABLE"
                    self.hasBridgeIp = false
                }
        }
    }
    
    func createUsernameHueBridge() {
        Alamofire.request(.POST, "http://\(bridgeIp)/api/", parameters: parameters, encoding: .JSON)
            .responseJSON { response in
                let jsonResponse = JSON(response.2.value!)
                if ((jsonResponse.arrayValue[0]["success"] != nil)) {
                    
                    // Only save username if a username is given (Succes returned)
                    self.userName = String(jsonResponse.arrayValue[0]["success"]["username"])
                    self.hasUsername = true
                    self.saveBridgeSettings(self.userName, bridgeIpSettings: self.bridgeIp)
                    
                }
        }
    }
    
    func getAllLamps() {
        
        // Only try if an username is available
        if( hasUsername.boolValue ) {
            Alamofire.request(.GET, "http://\(bridgeIp)/api/\(userName)/lights/")
                .responseJSON { response in
                    let jsonResponse = JSON(response.2.value!)
                    
                    // Reset lamp array to avoid creating an infinitely long array over time
                    if self.lampArray.count != 0 {self.lampArray = []}
                    
                    // Put every received lamp in the lampArray
                    for lampData in jsonResponse {
                        self.lampArray.append(self.parseLampData(Int(lampData.0)!, jsonData: lampData.1))
                    }
                    
                    // Sort the lamp array based on the name (to sort on something else, replace name in the statement below)
                    self.lampArray.sortInPlace({ $0.name < $1.name })
            }
        }
    }
    
    func parseLampData(lampId: Int, jsonData: JSON) -> HueLamp {
        
        // Create returnable lamp
        let lamp : HueLamp = HueLamp()
        
        // Add JSON lamp data to the newly created lamp
        
        lamp.id = lampId
        lamp.name = jsonData["name"].string
        lamp.isOn = jsonData["state"]["on"].boolValue
        lamp.saturation = jsonData["state"]["sat"].intValue
        lamp.brightness = jsonData["state"]["bri"].intValue
        lamp.hue = jsonData["state"]["hue"].intValue
        
        return lamp
    }
    
    
    func setLampState(lamp: HueLamp) {
        
        // Create JSON body to send to the bridge
        
        let lampStateUpdateParameters = [
            "on":lamp.isOn,
            "bri":lamp.brightness,
            "sat":lamp.saturation,
            "hue":lamp.hue
        ]
        
        // Send the bridge the new lamp data
        
        Alamofire.request(.PUT, "http://\(bridgeIp)/api/\(userName)/lights/\(lamp.id)/state", parameters: lampStateUpdateParameters as? [String : AnyObject], encoding: .JSON)
            .responseJSON { response in
        }
    }
    
    func saveBridgeSettings(userNameSettings: String, bridgeIpSettings: String) {
        
        // Get defaults from settings app
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        // Set all values in user preferences to the currently used
        userDefaults.setValue(userName, forKey: "name_preference")
        userDefaults.setValue(bridgeIp, forKey: "bridge_ip_preference")
        
        // Save the newly set preferences
        userDefaults.synchronize()
    }
    
    func loadBridgeSettings() {
        // Get defaults from settings app
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        // Get value for keys and update local variables
        if let userNamePreferences = userDefaults.stringForKey("name_preference") {
            if let bridgeIpPreferences = userDefaults.stringForKey("bridge_ip_preference") {
                
                if ( userNamePreferences.compare("").rawValue != 0 ) {
                    userName = userNamePreferences
                    self.hasUsername = true
                }
                else {
                    userName = "NO_USERNAME_AVAILABLE"
                    self.hasUsername = false
                }
                
                if ( bridgeIpPreferences.compare("").rawValue != 0 ) {
                    bridgeIp = bridgeIpPreferences
                    self.hasBridgeIp = true
                }
                else {
                    bridgeIp = "NO_BRIDGE_IP_AVAILABLE"
                    self.hasBridgeIp = false
                }
            }
        }
        else {
            // If all fails, just set everything to unavailable
            userName = "NO_USERNAME_AVAILABLE"
            bridgeIp = "NO_BRIDGE_IP_AVAILABLE"
            self.hasBridgeIp = false
            self.hasUsername = false
        }
    }
    
    func resetBridgeSettings() {
        // Get defaults from settings app
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        // Set all values in user preferences to nothing
        userDefaults.setValue("", forKey: "name_preference")
        userDefaults.setValue("", forKey: "bridge_ip_preference")
        userDefaults.setValue(false, forKey: "requested_reset")
        
        
        // Set the flags of availability to false
        self.hasBridgeIp = false
        self.hasUsername = false
        
        // Save the newly set preferences
        userDefaults.synchronize()
    }
    
    
}
