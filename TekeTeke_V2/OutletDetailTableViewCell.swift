//
//  OutletDetailTableViewCell.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 13/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class OutletDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryDesc: UILabel!
    @IBOutlet weak var caegoryImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


