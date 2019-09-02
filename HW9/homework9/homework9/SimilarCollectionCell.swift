//
//  SimilarCollectionCell.swift
//  homework9
//
//  Created by MyMac on 4/21/19.
//  Copyright © 2019 Snowflake. All rights reserved.
//

import UIKit

class SimilarCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var similarImageView: UIImageView!
    @IBOutlet weak var similarTitle: UILabel!
    @IBOutlet weak var similarShipFee: UILabel!
    @IBOutlet weak var similarLeftDay: UILabel!
    @IBOutlet weak var similarPrice: UILabel!
    var itemURL:String = ""
}
