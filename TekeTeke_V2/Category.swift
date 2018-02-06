//
//  Category.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 13/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class Category: NSObject {
    var categoryName: String?
    var categoryDesc: String?
    var categorySlug: String?
    
    init(categoryName: String, categoryDesc: String, categorySlug: String?) {
        self.categoryName = categoryName
        self.categoryDesc = categoryDesc
        self.categorySlug = categorySlug
    }
}

