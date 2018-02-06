//
//  Chat.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 02/10/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import Foundation

class Chat: NSObject {
    var chatId: String?
    var teketeke_staff: String?
    var chatStatus: Int?
    
    init(chatId: String,teketeke_staff: String, chatStatus: Int) {
        self.chatId = chatId
        self.teketeke_staff = teketeke_staff
        self.chatStatus = chatStatus
    }
}
