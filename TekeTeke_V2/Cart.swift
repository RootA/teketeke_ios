//
//  Cart.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 14/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit


class CartData: NSObject {
    //defines the cart items
    var product_id: Int = 0
    var outlet_id: Int = 0
    var quantity: Int = 0
    var subtotal: Int = 0
    var commission_tax: Int = 0
    var customName: String?
    var itemPrice: Int?
    var cartId: Int?
    
    init(product_id: Int, outlet_id: Int, quantity: Int, subtotal: Int, commission_tax: Int, customName: String, itemPrice: Int, cartId: Int) {
        self.product_id = product_id
        self.outlet_id = outlet_id
        self.quantity = quantity
        self.subtotal = subtotal
        self.commission_tax = commission_tax
        self.customName = customName
        self.itemPrice = itemPrice
        self.cartId = cartId
    }
}
