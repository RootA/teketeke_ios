//
//  Product.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 13/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class Product:  NSObject{
    //defines the product details
    var productSlug: String?
    var productName: String?
    var productDescription: String?
    var productImage: String?
    var productPrice: String?
    var productID: Int?
    
    var product_Category: productCategory? //associates a product with its Category
    
    init(productSlug: String, productName: String, productDescription: String, productImage: String, productPrice: String, productID: Int) {
        self.productName = productName
        self.productDescription = productDescription
        self.productPrice = productPrice
        self.productImage = productImage
        self.productID = productID
    }
}

class productCategory: NSObject {
    var productCategoryName: String?
    var productCategorySlug: String?
    var productCategoryDesc: String?
    var productCategoryImage: String?
    
    init(productCategoryName: String, productCategorySlug: String,  productCategoryDesc: String,productCategoryImage: String){
        
        self.productCategoryName = productCategoryName
        self.productCategorySlug = productCategorySlug
        self.productCategoryDesc = productCategoryDesc
        self.productCategoryImage = productCategoryImage
    }
}

