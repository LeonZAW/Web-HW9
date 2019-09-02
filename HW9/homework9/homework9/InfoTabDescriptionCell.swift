//
//  InfoTabDescriptionCell.swift
//  homework9
//
//  Created by MyMac on 4/19/19.
//  Copyright © 2019 Snowflake. All rights reserved.
//

import UIKit

class InfoTabDescriptionCell: UITableViewCell {

    @IBOutlet weak var tableTitle: UILabel!
    @IBOutlet weak var tableValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
