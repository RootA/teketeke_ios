//
//  Outlet.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 12/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class Outlet: NSObject {
    var outletName: String?
    var outletCaption: String?
    var outletBannerImage: String?
    var outletLogoImage: String?
    var outletMilage: String?
    var outletDescription: String?
    var outletSlug: String?
    
    
    init(outletName: String, outletCaption: String, outletBannerImage: String, outletLogoImage: String, outletMilage: String, outletDescription: String, outletSlug: String) {
        self.outletName = outletName
        self.outletCaption = outletCaption
        self.outletBannerImage = outletBannerImage
        self.outletLogoImage = outletLogoImage
        self.outletMilage = outletMilage
        self.outletDescription = outletDescription
        self.outletSlug = outletSlug
    }
}

class SingleOutlet: NSObject {
    var outletName: String?
    var outletCaption: String?
    var outletBannerImage: String?
    var outletLogoImage: String?
    var outletMilage: String?
    var outletDescription: String?
    var outletSlug: String?
    var outletEmail: String?
    var outletStreet: String?
    var outletBuilding: String?
    var outletTelephone: String?
    
    init(outletName: String, outletCaption: String, outletBannerImage: String, outletLogoImage: String, outletMilage: String, outletDescription: String, outletSlug: String, outletEmail: String,outletStreet: String,outletBuilding: String, outletTelephone: String) {
        self.outletName = outletName
        self.outletCaption = outletCaption
        self.outletBannerImage = outletBannerImage
        self.outletLogoImage = outletLogoImage
        self.outletMilage = outletMilage
        self.outletDescription = outletDescription
        self.outletSlug = outletSlug
        self.outletEmail = outletEmail
        self.outletTelephone = outletTelephone
        self.outletBuilding = outletBuilding
        self.outletStreet = outletStreet
    }
}
