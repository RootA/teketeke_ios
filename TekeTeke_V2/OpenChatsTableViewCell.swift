//
//  OpenChatsTableViewCell.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 03/10/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class OpenChatsTableViewCell: UITableViewCell {

    @IBOutlet weak var customerCare: UILabel!
    @IBOutlet weak var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
