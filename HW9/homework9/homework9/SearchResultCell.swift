//
//  SearchResultCell.swift
//  homework9
//
//  Created by MyMac on 4/17/19.
//  Copyright © 2019 Snowflake. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {


    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productShipping: UILabel!
    @IBOutlet weak var productZip: UILabel!
    @IBOutlet weak var productCondition: UILabel!
    @IBOutlet weak var productWishButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
