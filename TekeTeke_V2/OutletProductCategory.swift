//
//  OutletProductCategory.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 15/11/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit


class OutletProductCategory: NSObject {
    var categoryName: String?
    var categoryDesc: String?
    var categorySlug: String?
    var categoryImage: String?
    
    init(categoryName: String, categoryDesc: String, categorySlug: String?, categoryImage: String?) {
        self.categoryName = categoryName
        self.categoryDesc = categoryDesc
        self.categorySlug = categorySlug
        self.categoryImage = categoryImage
    }
}

