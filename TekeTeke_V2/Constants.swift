//
//  Constants.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 10/10/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import Firebase

struct Constants
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
    }
}

