//
//  DetailViewController.swift
//  iOS-Hue
//
//  Created by Guus Beckett on 21/10/15.
//  Copyright © 2015 Reupload. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var lamp : HueLamp!
    var bridgeMiddleman = BridgeMiddleman.getInstance
    
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelID: UILabel!
    @IBOutlet var colourImage: UIImageView!
    @IBOutlet var onOffSwitch: UISwitch!
    @IBOutlet var sliderHue: UISlider!
    @IBOutlet var sliderSaturation: UISlider!
    @IBOutlet var sliderBrightness: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLampInView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func lampToggle(sender: AnyObject) {
        lamp.isOn = onOffSwitch.on
        bridgeMiddleman.setLampState(lamp)
        loadLampInView()
    }
    
    @IBAction func updateHue(sender: AnyObject) {
        lamp.hue = Int(sliderHue.value)
        loadLampInView()
    }
    @IBAction func updateSaturation(sender: AnyObject) {
        lamp.saturation = Int(sliderSaturation.value)
        loadLampInView()
    }
    @IBAction func updateBrightness(sender: AnyObject) {
        lamp.brightness = Int(sliderBrightness.value)
        loadLampInView()
    }
    
    @IBAction func updateLampToBridge(sender: AnyObject) {
        bridgeMiddleman.setLampState(lamp)
    }

    func loadLampInView() {
        self.title = lamp.name
        labelName.text = lamp.name
        labelID.text = String(lamp.id)
        onOffSwitch.setOn(lamp.isOn, animated: true)
        sliderHue.value = Float(lamp.hue)
        sliderSaturation.value = Float(lamp.saturation)
        sliderBrightness.value = Float(lamp.brightness)
        colourImage.image = lamp.isOn.boolValue ? lamp.getImage() : UIColor.blackColor().convertImage()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
