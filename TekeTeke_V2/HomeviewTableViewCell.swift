//
//  HomeviewTableViewCell.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 12/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class HomeviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var outletThumbnail: UIImageView!
    @IBOutlet weak var outletName: UILabel!
    @IBOutlet weak var outletDesc: UILabel!
    @IBOutlet weak var deliveryCost: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
