//
//  HueTableViewCell.swift
//  iOS-Hue
//
//  Created by Guus Beckett on 21/10/15.
//  Copyright © 2015 Reupload. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet var hueColour: UIImageView!
    @IBOutlet var hueName: UILabel!
    @IBOutlet var hueID: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        hueColour.layer.cornerRadius = 55
        hueColour.layer.borderColor = UIColor.blackColor().CGColor
        hueColour.layer.borderWidth = 0.6
        hueColour.clipsToBounds = true

    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
