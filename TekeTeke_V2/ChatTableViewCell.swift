//
//  ChatTableViewCell.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 02/10/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageBubble: UILabel!
    @IBOutlet weak var messageRecipentBubble: UIView!
    @IBOutlet weak var messageSenderBubble: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell(message: Dictionary<String, Any>){
        self.messageBubble.text = message["message"] as? String
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
