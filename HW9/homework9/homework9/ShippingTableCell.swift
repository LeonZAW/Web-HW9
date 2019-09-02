//
//  ShippingTableCell.swift
//  homework9
//
//  Created by MyMac on 4/20/19.
//  Copyright © 2019 Snowflake. All rights reserved.
//

import UIKit

class ShippingTableCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var labelImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
