//
//  OnlineCartTableViewCell.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 17/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class OnlineCartTableViewCell: UITableViewCell {

    @IBOutlet weak var customName: UILabel!
    @IBOutlet weak var orderQty: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
